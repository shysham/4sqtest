//
//  FTViewController.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MKMapView+Zooming.h"
#import "Reachability.h"
#import "FTDataManager.h"

@interface FTViewController () <UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate>
- (void) setup;
- (void) cleanUp;

- (void) cancelPressed:(id)sender;
@end

@implementation FTViewController
@synthesize searchBar = _searchBar, mapView = _mapView, auxTableVC = _auxTableVC;

- (void) dealloc
{
    [self cleanUp];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // We'll need this to force reload when connection appears after break
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetConnectionStatusChanged)
                                                 name:kReachabilityChangedNotification object:nil];
    [self setup];
}

// For iOS < 6.0
- (void) viewDidUnload
{
    [self cleanUp];
    
    [super viewDidUnload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.auxTableVC reloadDataForceEvenIfHasData:YES];   // as far as it is nested
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Map view stuff
- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = (MKAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    if (!pinView) {
        pinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"] autorelease];
        pinView.image = [UIImage imageNamed:@"mappin-blue.png"];
        pinView.frame = CGRectMake(-30, 0, 70, 67.5);
        pinView.canShowCallout = NO;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
        
    } else {
        pinView.annotation = annotation;
    }
    if (annotation == mv.userLocation){
        return nil;
    }
    
    return pinView;
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
        return;
    
    CLLocationCoordinate2D coord = userLocation.coordinate;
    //if (coord.latitude > 90.f || coord.latitude < -90.f || coord.longitude > 180.f || coord.longitude < -180.f)
     //   return;
    
    [self.auxTableVC setLastKnownCoordinate:userLocation.coordinate];
    [self.auxTableVC reloadDataForceEvenIfHasData:NO];  // location change does not force venue list update. User must pull2refresh.
    
    [mapView setCenterCoordinate:userLocation.coordinate zoomLevel:14 animated:YES];
    
    // Add an annotation
    // •
    // •
    // •
    // •
    /*
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"Where am I?";
    point.subtitle = @"I'm here!!!";
    
    [self.mapView addAnnotation:point];
     */
}


#pragma mark -
#pragma mark Action handlers
- (void) cancelPressed:(id)sender
{
    NSLog(@"Dummy: Cancel button pressed on main screen");
}

#pragma mark -
#pragma mark Service
- (void) setup
{    
    [self.navigationController setNavigationBarHidden:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.title = NSLocalizedString(@"skTitleScreenCheckIn", nil);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"skTitleButtonCancel", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelPressed:)];
    self.auxTableVC.owner = self;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(.0, FT_APPRNS_SEARCHFIELD_INSET, .0, FT_APPRNS_SEARCHFIELD_INSET);
    [[UISearchBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"global-search-background.png"]];
    [self.searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"search-field.png"] resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"exp-toc-search-icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setPlaceholder:NSLocalizedString(@"skTitleSearchBar", nil)];
    
    [self.searchBar setPositionAdjustment:UIOffsetMake(FT_APPRNS_SEARCHBAR_ICON_X_OFFSET, 0) forSearchBarIcon:UISearchBarIconSearch];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(FT_APPRNS_SEARCHBAR_TEXT_X_OFFSET, 0)];

    insets = UIEdgeInsetsMake(.0, FT_APPRNS_CANCEL_BUTTON_INSET, .0, FT_APPRNS_CANCEL_BUTTON_INSET);
    [[UIBarButtonItem appearance]
            setBackgroundImage:[[UIImage imageNamed:@"cancel-bg.png"] resizableImageWithCapInsets:insets]
            forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance]
            setBackgroundImage:[[UIImage imageNamed:@"cancel-bg-pressed.png"] resizableImageWithCapInsets:insets]
            forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    self.mapView.userInteractionEnabled = NO;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = YES;
    /*
    [self.mapView.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:NULL];*/
}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self.mapView showsUserLocation]) {
        //[self moveOrZoomOrAnythingElse];
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
}
 */

- (void) internetConnectionStatusChanged
{
    if ([FTDataManager isNetworkAccessible]){
        [self.auxTableVC reloadDataForceEvenIfHasData:YES];     // connection problems force reloading
    }
}

- (void) cleanUp
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    _mapView.delegate = nil;
    
    [_searchBar release];       _searchBar = nil;
    [_mapView release];         _mapView = nil;
    [_auxTableVC release];      _auxTableVC = nil;
}

@end
