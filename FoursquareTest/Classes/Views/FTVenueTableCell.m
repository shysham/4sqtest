//
//  FTVenueTableCell.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTVenueTableCell.h"
#import "UIImageView+AFNetworking.h"
#import "FTDataManager.h"

@interface FTVenueTableCell()
@property (nonatomic, retain) NSString *venueID;
- (void) setupLayoutWithVenueData:(NSDictionary*)aVenue;

@end

@implementation FTVenueTableCell
@synthesize venueID = _venueID;
@synthesize labelName = _labelName, labelAddress = _labelAddress, labelDistance = _labelDistance;
@synthesize imgvCategory = _imgvCategory, imgvSpecial = _imgvSpecial, imgvAux = _imgvAux, labelAux = _labelAux;

- (id) initWithVenueData:(NSDictionary*)aVenue reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLayoutWithVenueData:aVenue];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLayoutWithVenueData:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [_venueID release];
    [_labelName release];
    [_labelAddress release];
    [_labelDistance release];
    [_labelAux release];
    [_imgvAux release];
    [_imgvSpecial release];
    [_imgvCategory release];
    
    [super dealloc];
}

- (void) updateWithVenueData:(NSDictionary*)aVenue
{
    [self setupLayoutWithVenueData:aVenue];
}

- (void) setupLayoutWithVenueData:(NSDictionary*)aVenue
{
    // Check if cell UI is dirty
    BOOL shouldUpdateImage = (!self.venueID || [self.venueID caseInsensitiveCompare:[aVenue valueForKey:kFSQDicVenueID]] != NSOrderedSame);

    if (shouldUpdateImage){
        [self.imgvCategory setBackgroundColor:[UIColor clearColor]];
        [self.imgvCategory setImage:[UIImage imageNamed:@"category-none.png"]];
    }
    
    // Name / title
    self.labelName.text = [aVenue objectForKey:kFSQDicVenueName];
    self.labelName.textColor = FT_APPRNS_VENUE_NAME_FONT_COLOR;
    
    
    // Address
    [self.labelAddress setFont:[UIFont fontWithName:FT_APPRNS_VENUE_ADDRESS_FONT_NAME size:FT_APPRNS_VENUE_ADDRESS_FONT_SIZE]];
    self.labelAddress.textColor = FT_APPRNS_VENUE_ADDRESS_FONT_COLOR;
    
    NSString *fuzzed = [aVenue valueForKeyPath:kFSQDicVenueAddressFuzzed];
    NSString *addr = [aVenue valueForKeyPath:kFSQDicVenueAddress];
    NSString *cross = [aVenue valueForKeyPath:kFSQDicVenueCrossStreet];
    
    NSString *fullAddress = nil;
    if ((!fuzzed || [fuzzed isEqualToString:@"false"]) && addr){
        fullAddress = addr;
        if (cross && [cross length] != 0){
            fullAddress = [fullAddress stringByAppendingFormat:@" (%@)", cross];
        }
    }
    
    self.labelAddress.text = (fullAddress ? [fullAddress uppercaseString] : @"");
    [self.labelAddress setHidden:(fullAddress == nil)];
    
    
    // Distance
    NSNumber *dist = [aVenue valueForKeyPath:kFSQDicVenueDistance];
    NSString *distStr = (dist ? [FTUtilities niceReadableDistanceWithMeters:[dist floatValue]] : nil);
    
    [self.labelDistance setNumberOfLines:0];
    [self.labelDistance setFont:[UIFont fontWithName:FT_APPRNS_VENUE_INFO_FONT_NAME size:FT_APPRNS_VENUE_INFO_FONT_SIZE]];
    self.labelDistance.textColor = FT_APPRNS_VENUE_INFO_FONT_COLOR;
    self.labelDistance.text = (distStr ? distStr : @"");
    CGSize size = [self.labelDistance.text sizeWithFont:self.labelDistance.font];
    [self.labelDistance setFrame:CGRectMake(self.labelDistance.frame.origin.x,
                                            (fullAddress ? self.labelDistance.frame.origin.y : self.labelAddress.frame.origin.y +
                                                        (self.labelAddress.frame.size.height - self.labelDistance.frame.size.height)),
                                            size.width, self.labelDistance.frame.size.height)];
    [self.labelDistance setHidden:(distStr == nil)];
    
    
    // Here now
    NSNumber *hereNow = [aVenue valueForKeyPath:kFSQDicVenueHereNowCount];
    NSInteger iHN = ((hereNow && [hereNow integerValue] > 0) ? [hereNow integerValue] : 0);
    
    if (iHN > 0){
        CGRect rect = self.imgvAux.frame;
        rect.origin.x = (distStr ?
                         self.labelDistance.frame.origin.x + self.labelDistance.frame.size.width + FT_APPRNS_VENUE_CELL_INFO_TEXT_SPACING
                         :
                         self.labelName.frame.origin.x);
        rect.origin.y = self.labelDistance.frame.origin.y;
        [self.imgvAux setFrame:rect];
        
        rect = self.labelAux.frame;
        self.labelAux.text = [NSString stringWithFormat:@"%d", iHN];
        self.labelAux.textColor = FT_APPRNS_VENUE_INFO_FONT_COLOR;
        rect.origin.x = self.imgvAux.frame.origin.x + self.imgvAux.frame.size.width;
        rect.origin.y = self.labelDistance.frame.origin.y;
        [self.labelAux setFrame:rect];
    }
    
    [self.imgvAux setHidden:(iHN == 0)];
    [self.labelAux setHidden:(iHN == 0)];
    
    // Special marker
    NSNumber *spec = [aVenue valueForKeyPath:kFSQDicVenueSpecials];
    self.imgvSpecial.hidden = (!(spec && [spec integerValue] > 0));
    
    // Category icon
    if (shouldUpdateImage){
        NSString *iconPath = [FTDataManager iconURLForImageType:FSQICONTP_DESCRIPTION
                                                     foreground:NO
                                                       forVenue:aVenue];
        if (iconPath){
            [self.imgvCategory setImageWithURL:[NSURL URLWithString:iconPath] placeholderImage:[UIImage imageNamed:@"venue-img-bg.png"]];
        }
    }
}

/*
- (void) setupLayoutWithVenueData:(NSDictionary*)aVenue
{
    if (!self.labelName)    self.labelName = [[[UILabel alloc] init] autorelease];
    if (!self.labelAddress) self.labelAddress = [[[UILabel alloc] init] autorelease];
    if (!self.labelAux)     self.labelAux = [[[UILabel alloc] init] autorelease];
    if (!self.labelDistance)self.labelDistance = [[[UILabel alloc] init] autorelease];
    
    self.imageView.image = [UIImage imageNamed:@"category-none.png"];
    self.imageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"venue-img-bg.png"]];
    
    NSString *dummy = @"ABC";   // I'm interested only in heights currently, 'cause width is fixed and line will be just truncated
    CGFloat xOffset = self.imageView.image.size.width + self.indentationWidth * 2.f,
            yOffset = self.imageView.frame.origin.y + self.indentationWidth;
    CGFloat maxLabelWidth = self.contentView.frame.size.width - xOffset - self.imageView.frame.origin.x;    // margins on left and right
    CGSize
        sizeName = [dummy sizeWithFont:[UIFont fontWithName:FT_APPRNS_VENUE_NAME_FONT_NAME size:FT_APPRNS_VENUE_NAME_FONT_SIZE]],
        sizeAddress = [dummy sizeWithFont:[UIFont fontWithName:FT_APPRNS_VENUE_ADDRESS_FONT_NAME size:FT_APPRNS_VENUE_ADDRESS_FONT_SIZE]],
        sizeInfo = [dummy sizeWithFont:[UIFont fontWithName:FT_APPRNS_VENUE_INFO_FONT_NAME size:FT_APPRNS_VENUE_INFO_FONT_SIZE]];
    
    CGRect rectLineTop = CGRectMake(xOffset, yOffset, maxLabelWidth, sizeName.height);
    CGRect rectLineMiddle = CGRectMake(xOffset, rectLineTop.origin.y + FT_APPRNS_VENUE_CELL_TEXT_SPACING + sizeAddress.height, maxLabelWidth, sizeAddress.height);
    CGRect rectLineBottom = CGRectMake(xOffset, rectLineMiddle.origin.y + FT_APPRNS_VENUE_CELL_TEXT_SPACING + sizeInfo.height, maxLabelWidth, sizeInfo.height);
    
    self.labelName =
    [self setupLabel:self.labelName
        withFontName:FT_APPRNS_VENUE_NAME_FONT_NAME
            fontSize:FT_APPRNS_VENUE_NAME_FONT_SIZE
               color:FT_APPRNS_VENUE_NAME_FONT_COLOR
                text:NSLocalizedString(@"skTitleDefaultDummy", nil)
               frame:CGRectMake(xOffset, yOffset, maxLabelWidth, sizeName.height)];
    
    [self.contentView addSubview:self.labelName];
    
    self.labelAddress =
    [self setupLabel:self.labelName
        withFontName:FT_APPRNS_VENUE_NAME_FONT_NAME
            fontSize:FT_APPRNS_VENUE_NAME_FONT_SIZE
               color:FT_APPRNS_VENUE_NAME_FONT_COLOR
                text:NSLocalizedString(@"skTitleDefaultDummy", nil)
               frame:CGRectMake(xOffset, yOffset, maxLabelWidth, sizeName.height)];
    
    [self.contentView addSubview:self.labelName];
    
    self.labelName =
    [self setupLabel:self.labelName
        withFontName:FT_APPRNS_VENUE_NAME_FONT_NAME
            fontSize:FT_APPRNS_VENUE_NAME_FONT_SIZE
               color:FT_APPRNS_VENUE_NAME_FONT_COLOR
                text:NSLocalizedString(@"skTitleDefaultDummy", nil)
               frame:CGRectMake(xOffset, yOffset, maxLabelWidth, sizeName.height)];
    
    [self.contentView addSubview:self.labelName];
}
 */

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Auxiliary
- (UILabel*) setupLabel:(UILabel*)aLabel withFontName:(NSString*)aFN fontSize:(CGFloat)aFS color:(UIColor*)aCL text:(NSString*)aTXT frame:(CGRect)aFrame
{
    [aLabel setFont:[UIFont fontWithName:aFN size:aFS]];
    [aLabel setNumberOfLines:1];
    [aLabel setLineBreakMode:UILineBreakModeTailTruncation];
    [aLabel setTextAlignment:UITextAlignmentLeft];
    [aLabel setBackgroundColor:[UIColor clearColor]];
    [aLabel setTextColor:aCL];
    [aLabel setText:aTXT];
    [aLabel setFrame:aFrame];
    
    return aLabel;
}

@end
