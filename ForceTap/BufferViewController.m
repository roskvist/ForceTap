//
//  ViewController.m
//  ForceTap
//
//  Created by Kasper Andersen on 03/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import "BufferViewController.h"
#import "BufferView.h"

@implementation BufferViewController
@synthesize bufferView  = _bufferView;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
   
        _bufferView = [[BufferView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.view = _bufferView;
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
