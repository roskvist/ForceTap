//
//  AppDelegate.m
//  ForceTap
//
//  Created by Kasper Andersen on 03/03/13.
//  Copyright (c) 2013 Kasper Andersen. All rights reserved.
//

#import "AppDelegate.h"
#import "BufferView.h"
#import "BufferViewController.h"
#import "AUHelper.h"

@implementation AppDelegate
@synthesize viewController  = _viewController;
@synthesize window          = _window;
@synthesize auHelper      =_auHelper;
@synthesize elapsedTime     =_elapsedTime;
@synthesize now             =_now;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    _window             = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _viewController     = [[BufferViewController alloc] init];
    _auHelper = [[AUHelper alloc]init];
    _auHelper.delegate  = _viewController.bufferView;
   
    _window.backgroundColor = [UIColor whiteColor];
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];;
    
    [_auHelper startAudioUnit];
    
   _now = [NSDate date];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   NSLog(@"applicationDidEnterBackground");
    [_auHelper stopProcessingAudio];
    [_auHelper cleanUp];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [_auHelper startAudioUnit];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    

    // NSLog(@"touchesBegan");
    [_auHelper touchEvent];
    [_auHelper stopProcessingAudio];
 
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    }

@end
