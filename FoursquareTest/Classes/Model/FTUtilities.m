//
//  FTUtilities.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTUtilities.h"

@implementation FTUtilities

+ (BOOL) isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && ([[UIScreen mainScreen] scale] == 2.0));
}

+ (UIImage*) make4SQImageBackgroundTransparentForImage:(UIImage *)rawImage
{
    if (!rawImage)
        return nil;
    
    CGFloat red, green, blue, alpha, d = FT_FSQSPEC_ICON_BG_COLOR_INACCURACY;
    [(UIColor*)FT_FSQSPEC_ICON_BG_COLOR getRed:&red green:&green blue:&blue alpha:&alpha];
    
    const float colorMasking[6] = {(red - d), (red + d), (green - d), (green + d), (blue - d), (blue + d)};
    UIImage *image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(rawImage.CGImage, colorMasking)];
    
    return image;
}

+ (NSString*) pathInDocumentsForFileName:(NSString *)name
{
    NSString *ret = nil;
    
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([sysPaths count] == 0)
        return nil;
    
    ret = [[[[sysPaths objectAtIndex:0] stringByAppendingPathComponent:name] retain] autorelease];
    
    return ret;
}

+ (BOOL) existsInDocumentsFileWithName:(NSString*)name
{
    NSString *path = [FTUtilities pathInDocumentsForFileName:name];
    
    if (!path || [path length] == 0)
        return NO;
    
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    return (exists && !isDir);
}

+ (NSString*) encodeURLString:(NSString *)rawString
{
    NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)rawString,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8);
    return encodedString;
}

+ (NSString*) niceReadableDistanceWithMeters:(CGFloat)meters
{
    NSString *meas = @"";
    
    if (meters < 100){
        meas = NSLocalizedString(@"skTitleMeters", nil);
    }
    else {
        meas = NSLocalizedString(@"skTitleKilometers", nil);
        meters /= 1000.f;
    }

    static NSNumberFormatter *numFormatter = nil;
    if (!numFormatter) {
        numFormatter = [[NSNumberFormatter alloc] init];    // will be released on app termination
        [numFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numFormatter setLocale:[NSLocale currentLocale]];
        [numFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numFormatter setRoundingMode:NSNumberFormatterRoundHalfEven];
        [numFormatter setMaximumFractionDigits:1];
        [numFormatter setMinimumFractionDigits:0];
    }
    
    NSString *ret = [[[NSString alloc]
                      initWithFormat:@"%@ %@", [numFormatter stringFromNumber:[NSNumber numberWithFloat:meters]], meas]
                     autorelease];
    
    return ret;
}

@end
