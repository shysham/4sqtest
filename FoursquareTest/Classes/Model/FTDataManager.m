//
//  FTDataManager.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTDataManager.h"

static FTDataManager *sharedDataManager = nil;

@implementation FTDataManager




#pragma mark -
#pragma mark Singleton stuff
+ (FTDataManager*) sharedManager
{
    @synchronized(self){
        if (sharedDataManager == nil) {
            sharedDataManager = [[super alloc] init];
        }
    }
    
    return sharedDataManager;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}

- (oneway void) release
{
}

- (id) autorelease
{
    return self;
}

@end

