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
    
    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:(1*1024*1024) diskCapacity:(5*1024*1024) diskPath:nil];
    [NSURLCache setSharedURLCache:urlCache];
    [urlCache release];
    
    // Scheduling necessary notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged)
                                                 name:kReachabilityChangedNotification object:nil];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    FTViewController *viewController = [[FTViewController alloc] initWithNibName:@"FTViewController" bundle:nil];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    
    [viewController release];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
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
