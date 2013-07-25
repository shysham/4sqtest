//
//  Constants.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

// Foursquare API-related
#define FT_FSQAPI_DATE_API_LAST_VERIFIED            @"20132307"

#define FT_FSQAPI_BASE_URL                          @"https://api.foursquare.com/v2/"
#define FT_FSQAPI_CLIENT_ID                         @"FXNJRDH5EAP0ULGQ3ITSAYYEWKTCWJLHEKKHHESORR4UNFS2"
#define FT_FSQAPI_CLIENT_SECRET                     @"RN3WA5CHBFSMJ0YM3ULETP2XOBXWEI2AVHOTUMMN40OALVWV"

#define FT_FSQAPI_VENUES_SEARCH                     @"venues/search"
#define FT_FSQAPI_VENUES_CATEGORIES                 @"venues/categories"

#define kFSQAPIRequestClientID                      @"client_id"
#define kFSQAPIRequestClientSecret                  @"client_secret"
#define kFSQAPIResponse                             @"response"
#define kFSQAPIResponseMeta                         @"meta"
#define kFSQDicResponseCode                         @"code"

#define kFSQAPIResponseVenueCategories              @"categories"
#define kFSQDicVenueCategoryID                      @"id"
#define kFSQDicVenueCategoryIcon                    @"icon"

#define kFSQAPIRequestVenueExploreLatLong           @"ll"
#define kFSQAPIRequestVenueExploreLimit             @"limit"
#define kFSQAPIRequestVenueExploreOffset            @"offset"
#define kFSQDicVenuesSearched                       @"venues"

#define kFSQDicVenueName                            @"name"
#define kFSQDicVenueAddressFuzzed                   @"location.isFuzzed"
#define kFSQDicVenueAddress                         @"location.address"
#define kFSQDicVenueCrossStreet                     @"location.crossStreet"
#define kFSQDicVenueDistance                        @"location.distance"
#define kFSQDicVenueLatitude                        @"location.lat"
#define kFSQDicVenueLongitude                       @"location.lng"
#define kFSQDicVenueHereNowCount                    @"hereNow.count"
#define kFSQDicVenueSpecials                        @"specials.count"
#define kFSQDicVenueCategories                      @"categories"
#define kFSQDicVenueCategoryPrimary                 @"primary"
#define kFSQDicVenueCategoryIconPrefix              @"icon.prefix"
#define kFSQDicVenueCategoryIconSuffix              @"icon.suffix"


typedef enum _FTFSQAPIANNOTATIONTYPE {
    FSQANNTP_UNKNOWN        =   0,
    FSQANNTP_REGULAR,
    FSQANNTP_SPECIAL
} FTFSQAPIANNOTATIONTYPE;

typedef enum _FTFSQAPIICONTYPE {
    FSQICONTP_ANNOTATION    =   0,
    FSQICONTP_DESCRIPTION
} FTFSQAPIICONTYPE;


// Other Foursquare-specific
#define FT_FSQSPEC_ICON_BG_COLOR                    [UIColor colorWithRed:(196.f/255.f) green:(195.f/255.f) blue:(188.f/255.f) alpha:1.0]
#define FT_FSQSPEC_ICON_BG_COLOR_INACCURACY         (0.1f)      // required to make icon background transparent
#define FT_FSQSPEC_DEFAULT_VENUE_COUNT              (30)


// Appearance
#define FT_APPRNS_CELL_HEIGHT                       (70.f)
#define FT_APPRNS_MAP_HEIGHT                        (200.f)
#define FT_APPRNS_CANCEL_BUTTON_INSET               (5.f)
#define FT_APPRNS_SEARCHFIELD_INSET                 (16.f)
#define FT_APPRNS_PULL2REFRESH_SLIDE_TIME           (.3f)
#define FT_APPRNS_SEARCHBAR_ICON_X_OFFSET           (-12.f)
#define FT_APPRNS_SEARCHBAR_TEXT_X_OFFSET           (-6.f)

#define FT_APPRNS_VENUE_CELL_TEXT_SPACING           (4.f)
#define FT_APPRNS_VENUE_NAME_FONT_NAME              @"Helvetica"
#define FT_APPRNS_VENUE_NAME_FONT_SIZE              (14.f)
#define FT_APPRNS_VENUE_NAME_FONT_COLOR             [UIColor colorWithRed:(100.f/255.f) green:(89.f/255.f) blue:(89.f/255.f) alpha:1.0]
#define FT_APPRNS_VENUE_ADDRESS_FONT_NAME           @"Gotham-Book"
#define FT_APPRNS_VENUE_ADDRESS_FONT_SIZE           (10.f)
#define FT_APPRNS_VENUE_ADDRESS_FONT_COLOR          [UIColor colorWithRed:(134.f/255.f) green:(127.f/255.f) blue:(118.f/255.f) alpha:1.0]
#define FT_APPRNS_VENUE_INFO_FONT_NAME              @"Gotham-Book"
#define FT_APPRNS_VENUE_INFO_FONT_SIZE              (10.f)
#define FT_APPRNS_VENUE_INFO_FONT_COLOR             [UIColor colorWithRed:(134.f/255.f) green:(127.f/255.f) blue:(118.f/255.f) alpha:1.0]
#define FT_APPRNS_VENUE_CELL_INFO_TEXT_SPACING      (4.f)

#define FT_APPRNS_ANNOTATION_IMAGE_WIDTH            (26.f)
#define FT_APPRNS_ANNOTATION_IMAGE_HEIGHT           (32.f)
#define FT_APPRNS_ANNOTATION_SPECIAL_IMAGE_NAME     @"mappin-orange.png"
#define FT_APPRNS_ANNOTATION_REGULAR_IMAGE_NAME     @"mappin-blue.png"


// Cache-related
#define FT_DATA_CATEGORIES_EXPIRATION_PERIOD        (7)     // 7 days max by default, as recommended by 4sq (https://developer.foursquare.com/docs/venues/categories)
#define kFTCategoriesLastUpdateTimestamp            @"kFTCategoriesLastUpdateTimestamp"
#define FT_DATA_CATEGORIES_LOCAL_FILE_NAME          @"categories.txt"


// Common
#define FT_SECONDS_PER_DAY                          (86400)

