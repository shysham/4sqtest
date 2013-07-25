//
//  FTUtilities.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTUtilities : NSObject

+ (BOOL) isRetina;
+ (NSString*) pathInDocumentsForFileName:(NSString*)name;
+ (BOOL) existsInDocumentsFileWithName:(NSString*)name;
+ (NSString*) niceReadableDistanceWithMeters:(CGFloat)meters;
+ (CGSize) scaleSize:(CGSize)size proportionalToSize:(CGSize)toSize;
+ (BOOL) areValidLatitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng;

+ (void) showNotificationOnView:(UIView*)aView withMessage:(NSString*)aMessage image:(UIImage*)anImage
                           size:(CGSize)aSize backColor:(UIColor*)aColor;
+ (void) removeNotificationFromView:(UIView*)aView;
+ (void) showConnectionLostMessageInView:(UIView*)aView;


@end
