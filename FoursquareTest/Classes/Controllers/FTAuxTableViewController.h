//
//  FTAuxTableViewController.h
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface FTAuxTableViewController : UITableViewController {
}

@property (nonatomic, assign) UIViewController *owner;
@property (nonatomic, assign) CLLocationCoordinate2D lastKnownCoordinate;

- (void) reloadDataForceEvenIfHasData:(BOOL)force;
@end
