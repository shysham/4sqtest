//
//  FTVenueTableCell.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTVenueTableCell : UITableViewCell
- (id) initWithVenueData:(NSDictionary*)aVenue reuseIdentifier:(NSString *)reuseIdentifier;
- (void) updateWithVenueData:(NSDictionary*)aVenue;
@end
