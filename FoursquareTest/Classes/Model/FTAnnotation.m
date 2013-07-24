//
//  FTAnnotation.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Wisebit, Ltd. All rights reserved.
//

#import "FTAnnotation.h"

@interface FTAnnotation()
@end

@implementation FTAnnotation
@synthesize coordinate = _coordinate, category = _category, type = _type, annotationView = _annotationView;

- (id) init
{
    if ((self = [super init])){
        [self auxInitializeWithType:FSQANNTP_UNKNOWN categoryID:@"" coordinate:CLLocationCoordinate2DMake(0.f, 0.f)];
    }
    
    return self;
}

- (id) initWithType:(FTFSQAPIANNOTATIONTYPE)annType categoryID:(NSString*)fsqCatID coordinate:(CLLocationCoordinate2D)aCoord
{
    if ((self = [super init])){
        [self auxInitializeWithType:annType categoryID:fsqCatID coordinate:aCoord];
    }
    
    return self;
}

- (void) dealloc
{
    [_category release];
    [_annotationView release];
    
    [super dealloc];
}

- (void) auxInitializeWithType:(FTFSQAPIANNOTATIONTYPE)annType categoryID:(NSString*)fsqCatID coordinate:(CLLocationCoordinate2D)aCoord
{
    // •
    // •
    // •
}

@end
