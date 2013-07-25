//
//  FTAnnotationView.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTAnnotationView.h"
#import "FTAnnotation.h"
#import "UIImageView+AFNetworking.h"

@interface FTAnnotationView()
- (void) setupView;
@end


@implementation FTAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self setupView];
    }
    return self;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])){
        [self setupView];
    }
    
    return self;
}

- (void) setupView
{
    if (!self.annotation){
        NSLog(@"ERR: %@: annotation is not set (= <nil>)", NSStringFromClass([self class]));
        return;
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    CGRect frame = self.frame;
    frame.origin.y -= 10.f;
    [self setFrame:frame];
    //[self setFrame:CGRectMake(0, 0, FT_APPRNS_ANNOTATION_IMAGE_WIDTH, FT_APPRNS_ANNOTATION_IMAGE_HEIGHT)];
    [self setCanShowCallout:NO];
    
    FTAnnotation *ann = (FTAnnotation*)self.annotation;
    FTFSQAPIANNOTATIONTYPE tp = [ann type];
    
    self.image = [UIImage imageNamed:(tp == FSQANNTP_SPECIAL ?
                                      FT_APPRNS_ANNOTATION_SPECIAL_IMAGE_NAME
                                      :
                                      FT_APPRNS_ANNOTATION_REGULAR_IMAGE_NAME)];

    UIImageView *cat = [[UIImageView alloc] initWithFrame:CGRectMake(.0f, .0f, FT_APPRNS_ANNOTATION_IMAGE_WIDTH, FT_APPRNS_ANNOTATION_IMAGE_WIDTH /*yes, it is not a mistake*/)];
    [cat setImage:ann.image];
    
    [self addSubview:cat];
    
    [cat release];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
