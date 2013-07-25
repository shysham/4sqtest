//
//  FTAppDelegate.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTAppDelegate.h"
#import "FTViewController.h"
#import "FTDataManager.h"
#import "Reachability.h"

@implementation FTAppDelegate

@synthesize navigationController = _navigationController;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    // Scheduling necessary notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged)
                                                 name:kReachabilityChangedNotification object:nil];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    FTViewController *viewController = [[FTViewController alloc] initWithNibName:@"FTViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [viewController release];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

// Aux stuff
- (void) internetConnectionStatusChanged
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable){
        [FTUtilities showConnectionLostMessageInView:self.navigationController.view];
    }
    else {
        // Remove "connection lost" notifiaction immediately (if it is visible; otherwise – no-op)
        [FTUtilities removeNotificationFromView:self.navigationController.view];
    }
}

@end
