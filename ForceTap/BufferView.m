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
@synthesize frameCount  = _frameCount;
@synthesize frameNumber = _frameNumber;
@synthesize sum         = _sum;
@synthesize frameSum    = _frameSum;

SInt16 *mdataArr[200];
int globalLength;
int globalCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       _frameCount = 0;
        
        _frameNumber = [[UILabel alloc]init];
        [_frameNumber setBackgroundColor:[UIColor clearColor]];
        _frameNumber.frame = CGRectMake(220.0, 60, 160.0, 40.0);
        _frameNumber.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [_frameNumber setTextColor:[UIColor whiteColor]];
        [_frameNumber setText:@"Frame number: "];
        [self addSubview:_frameNumber];
        
        _sum = [[UILabel alloc]init];
        [_sum setBackgroundColor:[UIColor clearColor]];
        _sum.frame = CGRectMake(220.0, 380, 160.0, 40.0);
        _sum.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [_sum setTextColor:[UIColor whiteColor]];
        [_sum setText:@"Frame sum: "];
        [self addSubview:_sum];
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
 
    for (int i = 0; i < _currLength; i++)
    {

               CGContextAddLineToPoint(_ctx, leftX + (i + 1) * stepX, centerY + (float)(_currBuffer[i]) / 128.0f);
        //NSLog(@"buffs %f",(float)(_currBuffer[i]));
    }
    
    CGContextAddLineToPoint(_ctx, leftX + (_currLength + 1) * stepX, centerY);
    CGContextAddLineToPoint(_ctx, 480.0f, centerY);
    
    CGContextStrokePath(_ctx);
   /*
    CGContextSetStrokeColorWithColor(_ctx, [[UIColor blueColor] CGColor]);
    
    float startY    = 320.0f;
    float endY      = 0.0f;
    CGContextMoveToPoint(_ctx, _startX, startY);
    CGContextAddLineToPoint(_ctx, _startX, endY);
    CGContextStrokePath(_ctx);
    */
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
-(void)drawButtons{
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nextButton addTarget:self
               action:@selector(showNextFrame)
     forControlEvents:UIControlEventTouchDown];
    [nextButton setTitle:@"Next frame" forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(-55.0, 380.0, 160.0, 40.0);
    nextButton.transform = CGAffineTransformMakeRotation(M_PI / 2);
    [self addSubview:nextButton];
    
    UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [prevButton addTarget:self
                   action:@selector(showPrevFrame)
         forControlEvents:UIControlEventTouchDown];
    [prevButton setTitle:@"Previous frame" forState:UIControlStateNormal];
    prevButton.frame = CGRectMake(-55.0, 60.0, 160.0, 40.0);
    prevButton.transform = CGAffineTransformMakeRotation(M_PI / 2);
    [self addSubview:prevButton];
    
    
}
-(void)showNextFrame{
    _frameCount++;
    
    if(_frameCount > globalCount){
        _frameCount = 0;
    }
    [self didReceiveAudioFrame:mdataArr[_frameCount]withLength:globalLength];
    [self updateSumLabel:mdataArr[_frameCount]];
    [self updateFrameNumberLabel];
}
-(void)showPrevFrame{
    
    _frameCount = _frameCount-1;
    if(_frameCount<0){
        _frameCount = globalCount;
        [self updateFrameNumberLabel];
        [self updateSumLabel:mdataArr[_frameCount]];
        [self didReceiveAudioFrame:mdataArr[_frameCount]withLength:globalLength];     
    }
    else {
        NSLog(@"frameCount = %i",_frameCount);
        [self didReceiveAudioFrame:mdataArr[_frameCount]withLength:globalLength];
        [self updateSumLabel:mdataArr[_frameCount]];
        [self updateFrameNumberLabel];
    }
}
-(void)initData:(SInt16*)aFrame withLength:(int)aLength andCounter:(int)counter{

    mdataArr[counter] = aFrame;
    globalLength = aLength;
    globalCount = counter;
    [self updateFrameNumberLabel];
  //  [self updateSumLabel:aFrame];
   
}
-(void)updateFrameNumberLabel{
    NSString * s = [NSString stringWithFormat:@"Frame number: %i",_frameCount+1];
   
    [_frameNumber setText:s];
}
-(void)updateSumLabel:(SInt16*)aFrame{
    
    float sum = 0.0;
    
    for(int i = 0;i<globalLength;i++){
        
        sum += (fabsf((float) aFrame[i])/128.0f);
    }
    
    NSString * s = [NSString stringWithFormat:@"Frame sum: %.2f",sum];
    
    [_sum setText:s];
}
@end
