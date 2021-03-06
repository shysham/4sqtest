//
//  FTDataManager.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTDataManager : NSObject

+ (id) sharedManager;

+ (NSOperationQueue*) ftOperationQueue;

+ (void) getVenuesForLocationCoordinate:(CLLocationCoordinate2D)coord withBlock:(void(^)(NSArray* venues, NSError *err))block;
+ (void) getVenuesForLocationCoordinate:(CLLocationCoordinate2D)coord
                                  count:(NSUInteger)count
                           startingFrom:(NSUInteger)offset
                              withBlock:(void(^)(NSArray* venues, NSError *err))block;

+ (NSInteger) calculateZoomFactorForVenueSet:(NSArray*)venueSet forLocation:(CLLocation*)coord;

// Aux yet app-specific methods (that's why they're not in FTUtilities)
+ (NSString*) iconURLForImageType:(FTFSQAPIICONTYPE)imgType foreground:(BOOL)isFG forVenue:(NSDictionary*)aVenue;

// Other
+ (NSArray*) supportedLocalizationCodes;
+ (BOOL) isNetworkAccessible;

@end
