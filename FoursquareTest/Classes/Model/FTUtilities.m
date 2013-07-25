//
//  FTUtilities.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation FTUtilities

+ (BOOL) isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && ([[UIScreen mainScreen] scale] == 2.0));
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

+ (CGSize) scaleSize:(CGSize)size proportionalToSize:(CGSize)toSize
{
    CGFloat ratio = 1.f, mult = 1.f;
    
    if (size.width > size.height)
    {
        ratio = (size.width / size.height);
        
        if (toSize.height * ratio > toSize.width){
            mult = (toSize.width / (toSize.height * ratio));
        }
        toSize = CGSizeMake(ratio * toSize.height * mult, toSize.height * mult);
    }
    else
    {
        ratio = (size.height / size.width);
        
        if (toSize.width * ratio > toSize.height){
            mult = (toSize.height / (toSize.width * ratio));
        }
        
        toSize = CGSizeMake(toSize.width * mult, ratio * toSize.width * mult);
    }
    
    return toSize;
}

+ (BOOL) areValidLatitude:(CLLocationDegrees)lat longitude:(CLLocationDegrees)lng
{
    return (!(lat > 90.f || lat < -90.f || lng > 180.f || lng < -180.f));
}

// Notification popup
+ (void) showNotificationOnView:(UIView*)aView withMessage:(NSString*)aMessage image:(UIImage*)anImage
                           size:(CGSize)aSize backColor:(UIColor*)aColor
{
    // Removing previous notification immediately (if any)
    [self removeNotificationFromView:aView];
    
    // Creating indicator
    CGRect rect = CGRectMake(0, 0, aSize.width, aSize.height);
    CGFloat labelHeight = 40.f, gap = 2.f;
    
    UIView *container = [[UIView alloc] initWithFrame:rect];
    container.tag = FT_APPRNS_NOTIFICATION_MSG_INDICATOR_TAG;
    container.alpha = 0.7f;
    container.backgroundColor = aColor;
    container.layer.cornerRadius = 10.0f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(container.layer.cornerRadius,
                                                               rect.size.height - labelHeight - gap - container.layer.cornerRadius,
                                                               rect.size.width - 2.f * container.layer.cornerRadius,
                                                               labelHeight)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:FT_APPRNS_NOTIFICATION_TEXT_FONT_NAME size:FT_APPRNS_NOTIFICATION_TEXT_FONT_SIZE]];
    [label setMinimumFontSize:FT_APPRNS_NOTIFICATION_MIN_TEXT_FONT_SIZE];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setNumberOfLines:2];
    [label setText:(aMessage ? aMessage : @"")];
    
    if (anImage){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:anImage];
        CGSize imgNewS = [FTUtilities scaleSize:anImage.size proportionalToSize:CGSizeMake(aSize.width - 2.f * container.layer.cornerRadius,
                                                                                     aSize.height - 2.f * container.layer.cornerRadius - labelHeight - gap)];
        [imageView setFrame:CGRectMake(0, 0, imgNewS.width, imgNewS.height)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setCenter:CGPointMake(container.center.x, container.center.y - ((labelHeight + gap) / 2.f))];
        
        [container addSubview:imageView];
        
        [imageView release];
    }
    
    [container addSubview:label];
    
    container.center = aView.center;
    
    [aView addSubview:container];
    [aView bringSubviewToFront:container];
    
    [label release];
    
    // Launching deferred dismissal
    [NSTimer scheduledTimerWithTimeInterval:FT_APPRNS_NOTIFICATION_SHOW_DURATION
                                     target:self
                                   selector:@selector(removeNotificationSlowlyFromView:)
                                   userInfo:[NSDictionary dictionaryWithObject:container forKey:@"indicator"]
                                    repeats:NO];
    
    [container release];
}

+ (void) removeNotificationSlowlyFromView:(NSTimer*)timer
{
    UIView *container = nil;
    if (timer && [timer userInfo]){
        container = [[timer userInfo] objectForKey:@"indicator"];
    }
    
    if (!container)
        return;
    
    [UIView animateWithDuration:FT_APPRNS_NOTIFICATION_DISAPPEARANCE_TIME delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [container setAlpha:0.f];
    } completion:^(BOOL finished) {
        [container removeFromSuperview];
    }];
}

+ (void) removeNotificationFromView:(UIView*)aView
{
    [self performSelector:@selector(removeNotificationFromViewSeparately:) withObject:aView];
}

+ (void) removeNotificationFromViewSeparately:(UIView*)aView
{
    @autoreleasepool {
        for (UIView *v in [aView subviews]){
            if (v.tag == FT_APPRNS_NOTIFICATION_MSG_INDICATOR_TAG){
                [v removeFromSuperview];
            }
        }
    }
}

+ (void) showConnectionLostMessageInView:(UIView*)aView
{
    [FTUtilities showNotificationOnView:aView
                            withMessage:NSLocalizedString(@"skTitleConnectionLost", nil)
                                  image:[UIImage imageNamed:@"alert-warning.png"] size:CGSizeMake(200, 140)
                              backColor:[UIColor blackColor]];
}

@end
