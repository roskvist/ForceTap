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
@protocol AUDelegate;
@interface AUHelper : NSObject
@property (nonatomic, assign) id<AUDelegate> delegate;
@property AudioBuffer       destBuffer;
@property NSMutableArray    *destArr;


@property bool touchHasOccured;
@property int counter;

-(void)startAudioUnit;
-(void) stopProcessingAudio;
-(void)cleanUp;
-(void)processBuffer: (AudioBufferList*) audioBufferList;
-(void)drawSavedBuffer;
-(void)touchEvent;
@end

@protocol AUDelegate <NSObject>
@required
-(void)didReceiveAudioFrame:(SInt16*)aFrame withLength:(int)aLength;
-(void)drawButtons;
-(void)initData:(SInt16*)aFrame withLength:(int)aLength andCounter:(int)counter;
@end