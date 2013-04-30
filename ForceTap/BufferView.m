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


SInt16 *mdataArr[5];
float sumArray[5];
int globalLength;
int globalCount;
int loudFrameNr;
float loudestValue;
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
        _sum.frame = CGRectMake(220.0, 200, 160.0, 40.0);
        _sum.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [_sum setTextColor:[UIColor whiteColor]];
        [_sum setText:@"Frame sum: "];
        [self addSubview:_sum];
        
        [_frameNumber setHidden:TRUE];
        [_sum setHidden:TRUE];
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
    
    CGContextRotateCTM(_ctx, 90 / 180.0 * M_PI);
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
        
    }
    
    CGContextAddLineToPoint(_ctx, leftX + (_currLength + 1) * stepX, centerY);
    CGContextAddLineToPoint(_ctx, 480.0f, centerY);
    
    
    
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
    SInt16 *aFrame = mdataArr[_frameCount];
    [self didReceiveAudioFrame:aFrame withLength:globalLength];
    [self updateSumLabel:[self calcSum:aFrame]];
    [self updateFrameNumberLabel:_frameCount];
    
    
   
}
-(void)showPrevFrame{
    
    
    if(_frameCount<0){
        _frameCount = globalCount;
    }
    SInt16 *aFrame = mdataArr[_frameCount];
    [self didReceiveAudioFrame:aFrame withLength:globalLength];
    [self updateSumLabel:[self calcSum:aFrame]];
    [self updateFrameNumberLabel:_frameCount];
    _frameCount = _frameCount-1;
}
-(void)initData:(SInt16*)aFrame withLength:(int)aLength andCounter:(int)counter frameNr:(int)loudFrame
loudestValue:(float)loudVal{

    mdataArr[counter] = aFrame;
    
    //sumArray[counter] = sum;
    loudFrameNr = loudFrame;
    loudestValue = loudVal;
    globalLength = aLength;
    globalCount = counter-1;
    [self updateFrameNumberLabel:counter];
    [self updateSumLabel:counter];
    
    [_frameNumber setHidden:FALSE];
    [_sum setHidden:FALSE];
    _frameCount = globalCount;
    
   
}
-(void)updateFrameNumberLabel:(int)count{
    NSString * s = [NSString stringWithFormat:@"Frame number: %i",count];
   
    [_frameNumber setText:s];
}
-(void)updateSumLabel:(float)val{
        
    NSString * s = [NSString stringWithFormat:@"Frame sum: %.2f",val];
    
    [_sum setText:s];
}
-(void)showLoudestFrame{

    SInt16 *audioFrame = mdataArr[loudFrameNr];

    [self updateSumLabel:[self calcSum:audioFrame]];
    [self updateFrameNumberLabel:loudFrameNr];
    [self didReceiveAudioFrame:audioFrame withLength:globalLength];
}
-(float)calcSum:(SInt16*)aFrame{
    float sum = 0.0;
    
    for(int i = 0;i<globalLength;i++){
        
        sum += (fabsf((float) aFrame[i])/128.0f);
    }
    return sum;
}
-(void)touchEvent{
    
    [self drawButtons];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"5 frames sumarized"
                                                    message:[NSString stringWithFormat:@"%f",loudestValue]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
