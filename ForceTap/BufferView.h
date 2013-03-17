//
//  bufferView.h
//  ForceTap
//
//  Created by Kasper Andersen on 04/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AU.h"

@interface BufferView : UIView<AUDelegate>
@property SInt16* currBuffer;
//@property float currBuffer;
@property CGContextRef ctx;
@property  int currLength;
@property  float startX;
-(void)setStartX:(float)startX;
-(void)didReceiveAudioFrame:(SInt16*)aFrame withLength:(int)aLength;
@end
