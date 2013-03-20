//
//  bufferView.h
//  ForceTap
//
//  Created by Kasper Andersen on 04/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUHelper.h"

@interface BufferView : UIView<AUDelegate>
@property SInt16* currBuffer;
@property CGContextRef ctx;
@property  int currLength;
@property  float startX;
@property int frameCount;
@property UILabel *frameNumber;
@property UILabel *sum;
@property float frameSum;
-(void)didReceiveAudioFrame:(SInt16*)aFrame withLength:(int)aLength;
-(void)drawButtons;
-(void)initData:(SInt16*)aFrame withLength:(int)aLength andCounter:(int)counter;
@end
