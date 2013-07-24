//
//  FTVenueTableCell.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTVenueTableCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel *labelName;
@property (nonatomic, retain) IBOutlet UILabel *labelAddress;
@property (nonatomic, retain) IBOutlet UILabel *labelDistance;
@property (nonatomic, retain) IBOutlet UIImageView *imgvCategory;
@property (nonatomic, retain) IBOutlet UIImageView *imgvAux;
@property (nonatomic, retain) IBOutlet UIImageView *imgvSpecial;
@property (nonatomic, retain) IBOutlet UILabel *labelAux;

- (id) initWithVenueData:(NSDictionary*)aVenue reuseIdentifier:(NSString *)reuseIdentifier;
- (void) updateWithVenueData:(NSDictionary*)aVenue;
@end
