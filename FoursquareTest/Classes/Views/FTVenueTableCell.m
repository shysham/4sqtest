//
//  FTVenueTableCell.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTVenueTableCell.h"

@interface FTVenueTableCell()
@property (nonatomic, retain) UILabel *labelName;
@property (nonatomic, retain) UILabel *labelAddress;
@property (nonatomic, retain) UILabel *labelDistance;
@property (nonatomic, retain) UIImageView *imgvAux;
@property (nonatomic, retain) UILabel *labelAux;

- (void) setupLayoutWithVenueData:(NSDictionary*)aVenue;

@end

@implementation FTVenueTableCell
@synthesize labelName = _labelName, labelAddress = _labelAddress, labelDistance = _labelDistance, imgvAux = _imgvAux, labelAux = _labelAux;

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
    [_labelName release];
    [_labelAddress release];
    [_labelDistance release];
    [_labelAux release];
    [_imgvAux release];
    
    [super dealloc];
}

- (void) updateWithVenueData:(NSDictionary*)aVenue
{
    [self setupLayoutWithVenueData:aVenue];
}

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
