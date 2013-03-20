//
//  AU.m
//  ForceTap
//
//  Created by Kasper Andersen on 08/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import "AUHelper.h"
#define kInputBus 1

@implementation AUHelper

@synthesize destBuffer      = _destBuffer;
@synthesize destArr         = _destArr;
@synthesize counter         = _counter;
@synthesize touchHasOccured = _touchHasOccured;

#pragma mark Global Variables
OSStatus status;
AudioComponentInstance audioUnit;
AudioStreamBasicDescription audioFormat;
//AudioBuffer bArr[10];
SInt16 *mdataArr[200];
int globalDat;
float *convertedSampleBuffer = NULL;

#pragma mark Object init
-(id)init{
    self = [super init];
    if (self){
        _touchHasOccured = NO;
        _counter         = 0;
        _destArr = [[NSMutableArray alloc]init];
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
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
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
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));

    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
        
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output, 
                                  kInputBus,
                                  &flag, 
                                  sizeof(flag));
    
    // TODO: Allocate our own buffers if we want
    if(convertedSampleBuffer == NULL) {
        // Lazy initialization of this buffer is necessary because we don't
        // know the frame count until the first callback
        convertedSampleBuffer = (float*)malloc(sizeof(float) * 1024);
    }
    // Initialise
    status = AudioUnitInitialize(audioUnit);
  
}

-(void)startAudioUnit{
    [self initialiseAudio];
    [self resetCounter];
    AudioOutputUnitStart(audioUnit);
    _touchHasOccured = NO;
}

-(void) stopProcessingAudio {
    AudioOutputUnitStop(audioUnit);
}

-(void)cleanUp{
    AudioComponentInstanceDispose(audioUnit);

}

OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    
    //FillOutAudioTimeStampWithSampleTime(inTimeStamp,44100.00);
    
    //AudioTimeStamp aT = *inTimeStamp;
    
    
    // a variable where we check the status
    OSStatus status;
    
    /**
     This is the reference to the object who owns the callback.
     */
    AUHelper *au = (__bridge AUHelper*) inRefCon;
    
    AudioBuffer buffer;
    buffer.mDataByteSize = inNumberFrames * sizeof(SInt16); // sample size
    
    
    
    buffer.mNumberChannels = 1; // one channel
    buffer.mData = malloc(sizeof(float)* inNumberFrames); // buffer size
   
    // we put our buffer into a bufferlist array for rendering
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    ioData = &bufferList;
    //AudioUnitRender passes a full buffer
    status = AudioUnitRender(audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames,&bufferList);
    if(status != noErr) {
        return status;
    }
    

    // process the bufferlist in the audio processor
    
    [au processBuffer:&bufferList];
     
    // process the bufferlist in the audio processor
    
    // clean up the buffer
    //free(bufferList.mBuffers[0].mData);
    
/*
    //inRefCon to access our interface object to do stuff
    AU *au = (__bridge AU *)inRefCon;
    
    AudioUnit rioUnit = audioUnit;
  
    AudioBufferList list;

    convertedSampleBuffer = (float*)malloc(sizeof(float) * inNumberFrames);
    
  
	list.mNumberBuffers = 1;
	list.mBuffers[0].mData = convertedSampleBuffer;
	list.mBuffers[0].mDataByteSize = 2* inNumberFrames;
	list.mBuffers[0].mNumberChannels = 1;
	
	ioData = &list;
    NSLog(@"Test , %li",(sizeof(float)));
    AudioUnitRender(rioUnit, ioActionFlags, inTimeStamp, kInputBus, inNumberFrames, ioData);
   
  
    for (int i = 0; i < ioData->mNumberBuffers; i++)
    {
        AudioBuffer buffer = ioData->mBuffers[i];
        SInt16 *audioFrame = (SInt16*)buffer.mData;
            [au.delegate didReceiveAudioFrame:audioFrame withLength:(buffer.mDataByteSize / 2)];
        
    }
 */
    return noErr;
    
}
#pragma mark processing

-(void)processBuffer: (AudioBufferList*) audioBufferList{

    AudioBuffer buffer = audioBufferList->mBuffers[0];
    SInt16 *audioFrame = (SInt16*)buffer.mData;
    
    memcpy(&mdataArr[_counter], &audioFrame, sizeof(audioFrame));

    [self incrementCounter];
    if([self checkCounter]){
        
        [self resetCounter];
    }

    [self.delegate didReceiveAudioFrame:audioFrame withLength:(buffer.mDataByteSize / 2)];
    
    
    globalDat = (buffer.mDataByteSize / 2);
    
    
}
-(void)drawSavedBuffer{
   
    for(int i = 0;i<_counter;i++){
         
        SInt16 *audioFrame = mdataArr[i];
        
       /*
        for(int i = 0; i<globalDat;i++){
            NSLog(@"%f",(float)audioFrame[i]);
        }*/
        [self.delegate initData:audioFrame withLength:globalDat andCounter:_counter];
        [self.delegate didReceiveAudioFrame:audioFrame withLength:globalDat];
    }
    
}

-(void)touchEvent{
    if(!_touchHasOccured){
        _touchHasOccured = YES;
        [self drawSavedBuffer];
        [self.delegate drawButtons];
        [self resetCounter];
        
    }
}
-(void)incrementCounter{
    
    _counter++;
}
-(void)resetCounter{
    _counter = 0;
}
-(bool)checkCounter{
    if(_counter == 200){
        return TRUE;
            }
    return NO;
}
@end
