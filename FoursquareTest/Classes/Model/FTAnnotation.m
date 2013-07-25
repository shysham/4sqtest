//
//  FTAnnotation.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTAnnotation.h"

@interface FTAnnotation()
@end

@implementation FTAnnotation
@synthesize coordinate = _coordinate, iconURL = _iconURL, type = _type;

- (id) init
{
    if ((self = [super init])){
        [self auxInitializeWithType:FSQANNTP_UNKNOWN iconURL:@"" coordinate:CLLocationCoordinate2DMake(0.f, 0.f)];
    }
    
    return self;
}

- (id) initWithType:(FTFSQAPIANNOTATIONTYPE)annType iconURL:(NSString*)fsqIconURL coordinate:(CLLocationCoordinate2D)aCoord
{
    if ((self = [super init])){
        [self auxInitializeWithType:annType iconURL:fsqIconURL coordinate:aCoord];
    }
    
    return self;
}

- (void) dealloc
{
    [_iconURL release];
    
    [super dealloc];
}

- (void) auxInitializeWithType:(FTFSQAPIANNOTATIONTYPE)annType iconURL:(NSString*)fsqIconURL coordinate:(CLLocationCoordinate2D)aCoord
{
    self.type = annType;
    self.iconURL = fsqIconURL;
    [self setCoordinate:aCoord];
}

@end
