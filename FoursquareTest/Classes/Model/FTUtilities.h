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
+ (UIImage*) make4SQImageBackgroundTransparentForImage:(UIImage*)rawImage;
+ (NSString*) pathInDocumentsForFileName:(NSString*)name;
+ (BOOL) existsInDocumentsFileWithName:(NSString*)name;
+ (NSString*) encodeURLString:(NSString *)rawString;
+ (NSString*) niceReadableDistanceWithMeters:(CGFloat)meters;

@end
