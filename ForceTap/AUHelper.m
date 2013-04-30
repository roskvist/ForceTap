//
//  AU.m
//  ForceTap
//
//  Created by Kasper Andersen on 08/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import "AUHelper.h"
#define kInputBus 1
#define kWavDataLength 512
#define kdataArrLength 3 //5
#define kbufferLength 1024


@implementation AUHelper
@synthesize counter           = _counter;
@synthesize touchHasOccured   = _touchHasOccured;
@synthesize loudestFrameNr    = _loudestFrameNr;
@synthesize loudestFrameValue = _loudestFrameValue;
@synthesize globalFrameLength = _globalFrameLength;
@synthesize status            = _status;
@synthesize audioUnit         = audioUnit;
@synthesize audioFormat       = audioFormat;
@synthesize isReady           = _isReady;

#pragma mark Global Variables       
SInt16 *mdataArr[kdataArrLength];
float wavDataArr[kWavDataLength];
float totalSignal[kbufferLength * kdataArrLength];

#pragma mark AUHelper init
-(id)init{
    self = [super init];
    if (self){
        _touchHasOccured   = NO;
        _counter           = 0;
        _loudestFrameValue = 0.0;
        _isReady           = NO;
         //[self correlation];
        
    }
    return self;
}

#pragma mark Audio init
-(void)initialiseAudio{
    // Describe audio component
    
   
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    _status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    // Enable IO for recording
    UInt32 flag = 1;
    _status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    
    // Describe format
    audioFormat.mSampleRate			= 44100.00;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 2;
    audioFormat.mBytesPerFrame		= 2;
    
    float aBufferLength = 0.02; // In seconds
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                            sizeof(aBufferLength), &aBufferLength);
    
    // Apply format
    _status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));

    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    _status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
        
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    _status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output, 
                                  kInputBus,
                                  &flag, 
                                  sizeof(flag));
    
    //Allocate our own buffers if we want
    
    // Initialise
    _status = AudioUnitInitialize(audioUnit);
  
}
#pragma mark Start/Stop AU
-(void)startAudioUnit{
    [self initialiseAudio];
    [self resetCounter];
    AudioOutputUnitStart(audioUnit);
    _isReady = YES;
    _touchHasOccured = NO;
}

-(void) stopProcessingAudio {
    AudioOutputUnitStop(audioUnit);
}
#pragma mark Clean up function
-(void)cleanUp{
    AudioComponentInstanceDispose(audioUnit);

}
#pragma mark Callback function
OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    // a variable where we check the status
    OSStatus status;
    
    //This is the reference to the object who owns the callback.
    AUHelper *au = (__bridge AUHelper*) inRefCon;
    
    AudioBuffer buffer;
    buffer.mDataByteSize = inNumberFrames * sizeof(SInt16); // sample size
    buffer.mNumberChannels = 1;                             // one channel
    buffer.mData = malloc(sizeof(float)* inNumberFrames);   // buffer size
    
    // we put our buffer into a bufferlist array for rendering
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    ioData = &bufferList;
    
    //AudioUnitRender passes a full buffer
    
    status = AudioUnitRender(au.audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames,&bufferList);
    
    if(status != noErr) {
        return status;
    }
    // process the bufferlist in the audio processor
    [au processBuffer:&bufferList];
     
    // process the bufferlist in the audio processor
    // clean up the buffer
    //free(bufferList.mBuffers[0].mData);
    
    return noErr;
    
}
#pragma mark processing

-(void)processBuffer: (AudioBufferList*) audioBufferList{
    if(!_touchHasOccured){
    AudioBuffer buffer = audioBufferList->mBuffers[0];
    SInt16 *audioFrame = (SInt16*)buffer.mData;
    
    _globalFrameLength = (buffer.mDataByteSize / 2);
    memcpy(&mdataArr[_counter], &audioFrame, sizeof(audioFrame));
    
    if([self calcLoudestFrame:audioFrame]){
        _loudestFrameNr = _counter;
    }
    [self incrementCounter];
        
  [self.delegate didReceiveAudioFrame:audioFrame withLength:(buffer.mDataByteSize / 2)]; 
    }
}

-(void)drawSavedBuffer{
    
    for(int i = 0;i<kdataArrLength;i++){
        SInt16 *audioFrame = mdataArr[i];
        [self.delegate initData:audioFrame withLength:kbufferLength andCounter:kdataArrLength frameNr:_loudestFrameNr loudestValue:[self calcTotalSum]];
    }
    //Show loudest frame self.delegate showLoudestFrame:globalLoud]
    [self.delegate showLoudestFrame];
    
}
-(float)calcTotalSum{
    float totalSum = 0.0;
    for(int i = 0;i<kdataArrLength;i++){
        SInt16 *audioFrame = mdataArr[i];
        totalSum += [self calcSum:audioFrame];
    }
    return totalSum;
}
#pragma mark Helper functions
-(void)touchEvent{
    if(!_touchHasOccured && _isReady){
        _touchHasOccured = YES;
        
        /*Summing method*/
        [self drawSavedBuffer];
        [self.delegate touchEvent];
        [self resetCounter];
        
        
        /*Correlation method
        [self initFingerWav];
        int counter = 0;
        for(int i = 0; i < kdataArrLength;i++){
            SInt16 *audioFrame = mdataArr[i];
            for(int j = 0; j<_globalFrameLength;j++){
                totalSignal[counter] = audioFrame[j]/128.0;
                counter++;
            }
            
        }
        
      //  NSLog(@"counter = %i",counter);
        [self correlation];*/
    }
}
-(void)incrementCounter{
    _counter++;
    if(_counter == kdataArrLength){
        _counter = 0;
    }
}
-(void)resetCounter{
    _counter = 0;
    _loudestFrameValue = 0;
}


-(float)calcSum:(SInt16*)aFrame{
    float sum = 0.0;
    
    for(int i = 0;i<_globalFrameLength;i++){
        
        sum += (fabsf((float) aFrame[i])/128.0f);
    }
    return sum;
}
-(bool)calcLoudestFrame:(SInt16*)aFrame{
    
    if(([self calcSum:aFrame])>_loudestFrameValue){
        _loudestFrameValue = ([self calcSum:aFrame]);
        return YES;
    }
    return NO;
}
-(void)correlation{
    
    float *signal, *filter, *result;
    int signalStride, filterStride, resultStride;
    int lenSignal, filterLength, resultLength;
    int counter = 0;
    filterLength = kWavDataLength;
    //filterLength = 5;
    resultLength = kbufferLength * kdataArrLength;
   // resultLength = filterLength*2 -1;
    lenSignal = filterLength + kbufferLength * kdataArrLength;
   // lenSignal = ((filterLength + 3) & 0xFFFFFFFC) + resultLength;
    
    
    
    signalStride = filterStride = resultStride = 1;
    
    
    
    printf("\nConvolution ( resultLength = %d, "
           
           "filterLength = %d )\n\n", resultLength, filterLength);
    
    
    
    /* Allocate memory for the input operands and check its availability. */
    
    signal = (float *) malloc(lenSignal * sizeof(float));
    
    filter = (float *) malloc(filterLength * sizeof(float));
    
    result = (float *) malloc(resultLength * sizeof(float));
    
    
    
    for (int i = 0; i < filterLength; i++)
        filter[i] = wavDataArr[i];
    
    
   
    for (int i = filterLength; i < lenSignal; i++){
        signal[i] = totalSignal[counter];
        counter++;
    }
            
    
    
    /* Correlation. */
    vDSP_conv(signal, signalStride, filter, filterStride,
              
              result, resultStride, resultLength, filterLength);
   /*vDSP_conv(signal, signalStride, filter, filterStride,
              
              result, resultStride, resultLength, filterLength);*/
  /*  printf("signal: ");
    for (int i = 0; i < lenSignal; i++)
       NSLog(@"i = %i %f ", i,signal[i]);
    
    
    printf("\n filter: ");
    for (int i = 0; i < filterLength; i++)
        NSLog(@"i = %i %f ", i,filter[i]);
    */
    
    float biggest = 0;
    int c = 0;
    int buffernumber = 0;
    printf("\n result: ");
    for (int i = 0; i < resultLength; i++){
        
        if(result[i]>biggest){
            biggest = result[i];
            c = i;
        }
      // NSLog(@"i = %i %f ", i,result[i]);
    }
    
    if(c < 1024){
        buffernumber = 1;
    }
    if(c < 2048 && c >=1024){
        buffernumber = 2;
    }
    if(c < 3072 && c >=2048){
        buffernumber = 3;
    }
    if(c < 4096 && c >=3072){
        buffernumber = 4;
    }
    if(c < 5120 && c >=4096){
        buffernumber = 5;
    }
    NSLog(@"biggest = %f and i = %i and buffernumber = %i",biggest,c,buffernumber);
    /*
    printf("signal: ");
    for (i = 0; i < lenSignal; i++)
        printf("%2.1f ", signal[i]);
    
    
    printf("\n filter: ");
    for (i = 0; i < filterLength; i++)
        printf("%2.1f ", filter[i]);
    
    printf("\n result: ");
    for (i = 0; i < resultLength; i++)
        printf("%2.1f ", result[i]);
    */
    /* Free allocated memory. */
    
    free(signal);
    
    free(filter);
    
    free(result);
}


-(void)initFingerWav{
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"fingerisolated" withExtension:@"wav"];
   
    ExtAudioFileRef eaf;
    
    OSStatus err;
    err = ExtAudioFileOpenURL((__bridge CFURLRef)(soundURL), &eaf);
     CheckError(err, "ExtAudioFileSetproperty error");
    if(noErr != err){
        NSLog(@"ExtAudioFileOpenURL ERROR");
    }
  
        
    AudioStreamBasicDescription anASBD;
    
    anASBD.mSampleRate			= 44100.00;
    anASBD.mFormatID			= kAudioFormatLinearPCM;
    anASBD.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    anASBD.mFramesPerPacket	= 1;
    anASBD.mChannelsPerFrame	= 1;
    anASBD.mBitsPerChannel		= 16;
    anASBD.mBytesPerPacket		= 2;
    anASBD.mBytesPerFrame		= 2;


    
    err = ExtAudioFileSetProperty(eaf, kExtAudioFileProperty_ClientDataFormat, sizeof(anASBD), &anASBD);
    
   
    if(noErr != err){
        NSLog(@"ExtAudioFileSetproperty error %ld",err);
    }
    /* Read the file contents using ExtAudioFileRead */
    
    
    AudioBuffer buffer;
    buffer.mDataByteSize = kWavDataLength * sizeof(SInt16); // sample size
    buffer.mNumberChannels = 1;                             // one channel
    buffer.mData = malloc(sizeof(float)*kWavDataLength);
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;

    UInt32 frameCount = buffer.mDataByteSize / anASBD.mBytesPerPacket;
    
    err = ExtAudioFileRead(eaf, &frameCount,&bufferList);
    
    if(noErr != err){
        NSLog(@"Couldn't read from input file");
        
    }
    SInt16 *aFrame = (SInt16*)buffer.mData;
    

    for(int i = 0;i<kWavDataLength;i++){
        wavDataArr[i] = ((float)aFrame[i]) / 128.0f;
    }
    
    //[self.delegate didReceiveAudioFrame:aFrame withLength:(buffer.mDataByteSize / 2)];
    
   }
static void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) { errorString[0] = errorString[5] = '\''; errorString[6] = '\0';}
    else
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString); exit(1);
}
@end
