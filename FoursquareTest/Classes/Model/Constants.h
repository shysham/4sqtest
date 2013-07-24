//
//  Constants.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

// Foursquare API-related
#define FT_FSQAPI_BASE_URL                          @"https://api.foursquare.com/v2"
#define FT_FSQAPI_CLIENT_ID                         @"FXNJRDH5EAP0ULGQ3ITSAYYEWKTCWJLHEKKHHESORR4UNFS2"
#define FT_FSQAPI_CLIENT_SECRET                     @"RN3WA5CHBFSMJ0YM3ULETP2XOBXWEI2AVHOTUMMN40OALVWV"

#define FT_FSQAPI_VENUES                            @"venues"

typedef enum _FTFSQAPIANNOTATIONTYPE {
    FSQANNTP_UNKNOWN        =   0,
    FSQANNTP_BLUEs,
    FSQANNTP_ORANGE
} FTFSQAPIANNOTATIONTYPE;


// Appearance
#define FT_APPRNS_CELL_HEIGHT                       (70.f)
#define FT_APPRNS_MAP_HEIGHT                        (200.f)
#define FT_APPRNS_CANCEL_BUTTON_INSET               (5.f)
#define FT_APPRNS_SEARCHFIELD_INSET                 (16.f)
#define FT_APPRNS_PULL2REFRESH_SLIDE_TIME           (.3f)

#define FT_APPRNS_VENUE_CELL_TEXT_SPACING           (4.f)
#define FT_APPRNS_VENUE_NAME_FONT_NAME              @"Helvetica"
#define FT_APPRNS_VENUE_NAME_FONT_SIZE              (12.f)
#define FT_APPRNS_VENUE_NAME_FONT_COLOR             [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]
#define FT_APPRNS_VENUE_ADDRESS_FONT_NAME           @"Gotham-Book"
#define FT_APPRNS_VENUE_ADDRESS_FONT_SIZE           (10.f)
#define FT_APPRNS_VENUE_ADDRESS_FONT_COLOR          [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]
#define FT_APPRNS_VENUE_INFO_FONT_NAME              @"Gotham-Book"
#define FT_APPRNS_VENUE_INFO_FONT_SIZE              (10.f)
#define FT_APPRNS_VENUE_INFO_FONT_COLOR             [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]
#define FT_APPRNS_VENUE_CELL_INFO_TEXT_SPACING      (4.f)

