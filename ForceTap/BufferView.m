//
//  BufferView.m
//  ForceTap
//
//  Created by Kasper Andersen on 04/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import "BufferView.h"


@implementation BufferView

@synthesize currBuffer  = _currBuffer;
@synthesize currLength  = _currLength;
@synthesize ctx         = _ctx;
@synthesize startX      = _startX;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect)rect{
 
  
    // Drawing code
   _ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(_ctx, [[UIColor blackColor] CGColor]);
    CGContextFillRect(_ctx, rect);
    
    CGContextRotateCTM(_ctx, 90/ 180.0 * M_PI);
    CGContextTranslateCTM(_ctx, 0.0f, -320.0f);
    
    // draw baseline
    CGContextSetStrokeColorWithColor(_ctx, [[UIColor grayColor] CGColor]);
    
    CGContextMoveToPoint(_ctx, 0.0f, 160.0f);
    CGContextAddLineToPoint(_ctx, 480.0f, 160.0f);
    
    CGContextStrokePath(_ctx);
    
    // draw the graph
    CGContextSetStrokeColorWithColor(_ctx, [[UIColor greenColor] CGColor]);
    CGContextSetLineWidth(_ctx, 3.0);
    
    float centerX = 240.0f;
    float centerY = 160.0f;
    float windowSize = 480.0f;
    
    float leftX = centerX - windowSize / 2.0f;
    float stepX = windowSize / (float)_currLength;
    
    CGContextMoveToPoint(_ctx, 0.0f, centerY);
    CGContextAddLineToPoint(_ctx, leftX, centerY);
    int count = 1;
    
    for (int i = 0; i < _currLength; i++)
    {
        
       
               CGContextAddLineToPoint(_ctx, leftX + (i + 1) * stepX, centerY + (float)(_currBuffer[i]) / 64.0f);
        
    }
    
    CGContextAddLineToPoint(_ctx, leftX + (_currLength + 1) * stepX, centerY);
    CGContextAddLineToPoint(_ctx, 480.0f, centerY);
    
    CGContextStrokePath(_ctx);
    
    CGContextSetStrokeColorWithColor(_ctx, [[UIColor blueColor] CGColor]);
    
    float startY    = 320.0f;
    float endY      = 0.0f;
    CGContextMoveToPoint(_ctx, _startX, startY);
    CGContextAddLineToPoint(_ctx, _startX, endY);
    CGContextStrokePath(_ctx);
    
}

- (void)didReceiveAudioFrame:(SInt16*)aFrame withLength:(int)aLength{
    
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(main_queue, ^{
       
        _currLength = aLength;
        _currBuffer = aFrame;
        dispatch_async(main_queue, ^{
           [self setNeedsDisplay];
        });
    });
}

-(void)setStartX:(float)startX{
    
    _startX = startX;
    
}


@end
