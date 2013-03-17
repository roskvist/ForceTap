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
@property SInt16 *conversionBuffer;	

-(void)startAudioUnit;
-(void) stopProcessingAudio;
-(void)cleanUp;

@end

@protocol AUDelegate <NSObject>
@required
-(void)didReceiveFrame:(float)aFrame;
-(void)setStartX:(float)startX;
-(void)didReceiveAudioFrame:(SInt16*)aFrame withLength:(int)aLength;
@end