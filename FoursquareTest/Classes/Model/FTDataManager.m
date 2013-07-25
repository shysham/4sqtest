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
+ (void) aux_downloadCategoriesWithBlock:(void(^)(NSDictionary* info, NSError *err))block;
+ (void) aux_saveCategoriesToDisk:(NSDictionary*)cats;
+ (NSDictionary*) aux_loadCategoriesFromDisk;
@end


@implementation FTDataManager

+ (BOOL) isExpiredCategoriesList
{
    if (![FTUtilities existsInDocumentsFileWithName:FT_DATA_CATEGORIES_LOCAL_FILE_NAME])
        return YES;     // file is absent, needs to be downloaded
    
    NSDate *lastDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kFTCategoriesLastUpdateTimestamp];
    
    if (!lastDate)
        return YES;     // there were no updates yet, so it's like the list has expired
    
    return (fabs([lastDate timeIntervalSinceNow]) >= (FT_SECONDS_PER_DAY * FT_DATA_CATEGORIES_EXPIRATION_PERIOD));
}

+ (void) getCategoriesWithBlock:(void(^)(NSDictionary* info, NSError *err))block
{
    // Updates if necessary
    if ([FTDataManager isExpiredCategoriesList]){
        // Load from 4SQ
        [FTDataManager aux_downloadCategoriesWithBlock:^(NSDictionary *info, NSError *err) {
            if (!err || [err code] == 0){
                [FTDataManager aux_saveCategoriesToDisk:info];
            }
            else {
                NSLog(@"ERR: Failed to retrieve categories with error: %@", [err description]);
            }
            
            block(info, err);
        }];
    }
    else {
        // Retrieve from disk
        NSDictionary *dic = [FTDataManager aux_loadCategoriesFromDisk];
        block (dic, nil);
    }
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
                                                      kFSQAPIRequestVenueExploreOffset: [NSString stringWithFormat:@"%u", offset]}];
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


// Aux
/*
+ (NSString*) iconURLForImageType:(FTFSQAPIICONTYPE)imgType withBaseURL:(NSString*)baseURL
{
    // Makes URLs only background images (i.e. with "bg" prefix)
    if (!baseURL)
        return nil;
    
    NSRange rg = [baseURL rangeOfString:@"." options:NSBackwardsSearch];
    if (rg.location == NSNotFound)
        return nil;
    
    BOOL isRetina = [FTUtilities isRetina];
    
    NSString *specifier = @".";
    switch (imgType){
        case FSQICONTP_ANNOTATION:
            specifier = (isRetina ? @"_bg_64." : @"_bg_32.");
            break;
        
        default:        // this one includes FSQICONTP_DESCRIPTION
            specifier = (isRetina ? @"_bg_44." : @"_bg_88.");
    }
    
    NSString *ret = [[[NSString alloc] initWithString:
                      [baseURL stringByReplacingOccurrencesOfString:@"." withString:specifier options:NSBackwardsSearch range:rg]] autorelease];
    
    NSLog(@"FTDataManager::iconURL prepared as: %@", ret);
    
    return ret;
}
*/

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
        if (prim && [prim isEqualToString:@"true"]){
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
    
    NSLog(@"FTDataManager::iconURL2 prepared as: %@", ret);
    
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

+ (void) aux_downloadCategoriesWithBlock:(void(^)(NSDictionary* info, NSError *err))block
{
    NSURL *url = [FTDataManager aux_urlForResource:[FT_FSQAPI_BASE_URL stringByAppendingString:FT_FSQAPI_VENUES_CATEGORIES] parameters:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
              block ((NSDictionary*)JSON, nil);
          }
          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
              NSLog(@"ERR: Failed to download categories from server");
              block (nil, error);
          }];
    
    [operation start];
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

+ (void) aux_saveCategoriesToDisk:(NSDictionary*)cats
{
    if (!cats)
        return;

    if ([cats writeToFile:[FTUtilities pathInDocumentsForFileName:FT_DATA_CATEGORIES_LOCAL_FILE_NAME] atomically:YES]){
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kFTCategoriesLastUpdateTimestamp];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSDictionary*) aux_loadCategoriesFromDisk
{
    NSDictionary *res = [[[NSDictionary alloc] initWithContentsOfFile:[FTUtilities pathInDocumentsForFileName:FT_DATA_CATEGORIES_LOCAL_FILE_NAME]] autorelease];

    if (!res)
        NSLog(@"ERR: Failed to load categories from disk");
    
    return res;
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

