//
//  AU.h
//  ForceTap
//
//  Created by Kasper Andersen on 08/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BufferViewController.h"
#include <Accelerate/Accelerate.h>
#include <AudioToolbox/AudioFile.h>
@protocol AUDelegate;
@interface AUHelper : NSObject
@property (nonatomic, assign) id<AUDelegate>    delegate;
@property float                                 loudestFrameValue;
@property int                                   loudestFrameNr;
@property bool                                  touchHasOccured;
@property bool                                  isReady;
@property int                                   counter;
@property float                                 globalFrameLength;
@property OSStatus                              status;
@property AudioComponentInstance                audioUnit;
@property AudioStreamBasicDescription           audioFormat;


-(void)startAudioUnit;
-(void) stopProcessingAudio;
-(void)cleanUp;
-(void)processBuffer: (AudioBufferList*) audioBufferList;
-(void)drawSavedBuffer;
-(void)touchEvent;
-(void)initFingerWav;
@end

@protocol AUDelegate <NSObject>
@required
-(void)didReceiveAudioFrame:(SInt16*)aFrame withLength:(int)aLength;
-(void)initData:(SInt16*)aFrame withLength:(int)aLength andCounter:(int)counter frameNr:(int)loudFrame
       loudestValue:(float)loudVal;
-(void)showLoudestFrame;
-(void)touchEvent;
-(float)calcTotalSum;
@end