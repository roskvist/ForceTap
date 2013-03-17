//
//  AppDelegate.h
//  ForceTap
//
//  Created by Kasper Andersen on 03/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUHelper.h"
@class BufferViewController;
@class AUHelper;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BufferViewController *viewController;
@property (strong, nonatomic) AUHelper *recordera;
@property NSTimeInterval elapsedTime;
@property NSDate *now;
@end
