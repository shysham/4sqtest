//
//  FTDataManager.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTDataManager.h"
#import "AFNetworking.h"
#import "Reachability.h"

static FTDataManager *sharedDataManager = nil;

@interface FTDataManager()
+ (NSURL*) aux_urlForResource:(NSString*)res parameters:(NSDictionary*)params;
@end


@implementation FTDataManager

+ (NSOperationQueue*) ftOperationQueue
{
    static NSOperationQueue *ftopqu = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        ftopqu = [[NSOperationQueue alloc] init];
        [ftopqu setMaxConcurrentOperationCount:FT_SYS_MAX_CONCURRENT_OPERATIONS];
    });
    
    return ftopqu;
}

+ (void) getVenuesForLocationCoordinate:(CLLocationCoordinate2D)coord withBlock:(void(^)(NSArray* venues, NSError *err))block
{
    [FTDataManager getVenuesForLocationCoordinate:coord
                                            count:FT_FSQSPEC_DEFAULT_VENUE_COUNT
                                     startingFrom:0u
                                        withBlock:^(NSArray *venues, NSError *err) {
                                            block(venues, err);
                                        }];
}

+ (void) getVenuesForLocationCoordinate:(CLLocationCoordinate2D)coord
                                  count:(NSUInteger)count
                           startingFrom:(NSUInteger)offset
                              withBlock:(void(^)(NSArray* venues, NSError *err))block
{
    NSURL *url = [FTDataManager aux_urlForResource:[FT_FSQAPI_BASE_URL stringByAppendingString:FT_FSQAPI_VENUES_SEARCH]
                                        parameters:@{kFSQAPIRequestVenueExploreLatLong: [NSString stringWithFormat:@"%f,%f", coord.latitude, coord.longitude],
                                                       kFSQAPIRequestVenueExploreLimit: [NSString stringWithFormat:@"%u", count],
                                                      kFSQAPIRequestVenueExploreOffset: [NSString stringWithFormat:@"%u", offset],
                                                      kFSQAPIRequestVenueExploreIntent: @"checkin"}];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
           success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
               NSDictionary *json = (NSDictionary*)JSON;
               NSDictionary *resp = [json objectForKey:kFSQAPIResponse];
               if (json && resp){
                   NSArray *arr = [resp objectForKey:kFSQDicVenuesSearched];
                   block (arr, nil);
               }
               else {
                   block (nil, [NSError errorWithDomain:@"FTDataManager::remote call does not contain response data" code:1 userInfo:json]);
               }
           }
           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
               NSLog(@"ERR: Failed to download venues from server");
               block (nil, error);
           }];
    
    [operation start];
}


// Method recalculates necessary (optimal) zoom factor basing on how many places are right close to the location
+ (NSInteger) calculateZoomFactorForVenueSet:(NSArray*)venueSet forLocation:(CLLocation*)loc
{    
    NSInteger numOfVenuesNear = 0;
    
    if (venueSet && [FTUtilities areValidLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude]){
        CLLocation *venueLoc;
        
        for (NSDictionary *venue in venueSet){
            CLLocationDegrees lat = [(NSNumber*)[venue valueForKeyPath:kFSQDicVenueLatitude] doubleValue];
            CLLocationDegrees lng = [(NSNumber*)[venue valueForKeyPath:kFSQDicVenueLongitude] doubleValue];
            
            if ([FTUtilities areValidLatitude:lat longitude:lng]){
                venueLoc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                if ([venueLoc distanceFromLocation:loc] < FT_APPRNS_LOCATION_NEAR_RADIUS){
                    ++numOfVenuesNear;
                }
                [venueLoc release];
            }
        }
    }
    
    // Simple selector :)
    //  We also could use more complex logic: e.g., calculate region which has not more than, say, 10 venues.
    //  But let's do thet next time, during working day in Astra Stu dio :)
    NSInteger zl;
    
    if (numOfVenuesNear > (FT_FSQSPEC_DEFAULT_VENUE_COUNT * 0.75f))         zl = 12;
    else if (numOfVenuesNear > (FT_FSQSPEC_DEFAULT_VENUE_COUNT * 0.5f))     zl = 11;
    else if (numOfVenuesNear > (FT_FSQSPEC_DEFAULT_VENUE_COUNT * 0.25f))    zl = 10;
    else zl = FT_APPRNS_MAP_DEFAULT_ZOOM_LEVEL;
    
    return zl;
}


// Aux
+ (NSString*) iconURLForImageType:(FTFSQAPIICONTYPE)imgType foreground:(BOOL)isFG forVenue:(NSDictionary*)aVenue
{
    if (!aVenue)
        return nil;
    
    NSArray *cats = [aVenue objectForKey:kFSQDicVenueCategories];
    if (!cats || [cats count] == 0)
        return nil;
    
    NSDictionary *imgPrefix = nil, *imgSfx = nil;
    NSString *prim;
    for (NSDictionary *dic in cats){
        prim = [dic objectForKey:kFSQDicVenueCategoryPrimary];
        if (prim && [(NSNumber*)prim boolValue]){
            imgPrefix = [dic valueForKeyPath:kFSQDicVenueCategoryIconPrefix];
            imgSfx = [dic valueForKeyPath:kFSQDicVenueCategoryIconSuffix];
            break;
        }
    }
    
    if (!imgPrefix || !imgSfx)
        return nil;
    
    BOOL isRetina = [FTUtilities isRetina];
    
    NSString *specifier = @"";
    switch (imgType){
        case FSQICONTP_ANNOTATION:
            specifier = (isRetina ? @"64" : @"32");
            break;
            
        default:        // this one includes FSQICONTP_DESCRIPTION
            specifier = (isRetina ? @"44" : @"88");
    }
    
    NSString *ret = [[[NSString alloc] initWithFormat:@"%@%@%@%@", imgPrefix, (isFG ? @"" : @"bg_"), specifier, imgSfx] autorelease];
    
    ///NSLog(@"FTDataManager::iconURL2 prepared as: %@", ret);
    
    return ret;
}

+ (NSArray*) supportedLocalizationCodes
{
    return @[@"en", @"ru"];     // English, Russian
}

+ (BOOL) isNetworkAccessible
{
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

// This method automatically adds client ID and secret to the URL, as well localization (if possible)
+ (NSURL*) aux_urlForResource:(NSString*)res parameters:(NSDictionary*)params
{
    if (!res)
        return nil;
    
    // Checking and setting up localization. We are not using Accept-Language HTTP header but rather just a parameter
    NSString *finalCode = @"en";    // by default
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    for (NSString *c in [FTDataManager supportedLocalizationCodes]){
        if ([c isEqualToString:language]){
            finalCode = c;
            break;
        }
    }
    
    // Setting up URL string
    NSString *urlString = [res stringByAppendingFormat:@"?v=%@&locale=%@&&%@=%@&%@=%@",
                           FT_FSQAPI_DATE_API_LAST_VERIFIED,
                           finalCode,
                           kFSQAPIRequestClientID, FT_FSQAPI_CLIENT_ID,
                           kFSQAPIRequestClientSecret, FT_FSQAPI_CLIENT_SECRET];
    
    if (params && [params count] != 0){        
        // Processing custom user parameters
        NSString *val = nil;
        for (NSString* key in [params allKeys]){
            val = [params objectForKey:key];
            if (!val)
                continue;
            
            urlString = [urlString stringByAppendingFormat:@"&%@=%@", key, val];
        }
    }
    
    NSString *encoded = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[[NSURL alloc] initWithString:encoded] autorelease];
    
    return url;
}


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

