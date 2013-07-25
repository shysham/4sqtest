//
//  FTAnnotation.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Wisebit, Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FTAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString* iconURL;
@property (nonatomic, assign) FTFSQAPIANNOTATIONTYPE type;

- (id) initWithType:(FTFSQAPIANNOTATIONTYPE)annType iconURL:(NSString*)fsqIconURL coordinate:(CLLocationCoordinate2D)aCoord;
@end
