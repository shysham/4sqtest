//
//  FTViewController.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 23.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FTViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
- (void) setupScreen;
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
    
    [self setupScreen];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Action handlers
- (void) cancelPressed:(id)sender
{
    NSLog(@"Dummy: Cancel button pressed on main screen");
}

#pragma mark -
#pragma mark Service
- (void) setupScreen
{    
    [self.navigationController setNavigationBarHidden:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.title = NSLocalizedString(@"skTitleScreenCheckIn", nil);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"skTitleButtonCancel", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelPressed:)];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(.0, FT_APPRNS_SEARCHFIELD_INSET, .0, FT_APPRNS_SEARCHFIELD_INSET);
    [[UISearchBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"global-search-background.png"]];
    [self.searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"search-field.png"] resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"exp-toc-search-icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setPlaceholder:NSLocalizedString(@"skTitleSearchBar", nil)];

    insets = UIEdgeInsetsMake(.0, FT_APPRNS_CANCEL_BUTTON_INSET, .0, FT_APPRNS_CANCEL_BUTTON_INSET);
    [[UIBarButtonItem appearance]
            setBackgroundImage:[[UIImage imageNamed:@"cancel-bg.png"] resizableImageWithCapInsets:insets]
            forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance]
            setBackgroundImage:[[UIImage imageNamed:@"cancel-bg-pressed.png"] resizableImageWithCapInsets:insets]
            forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.zoomEnabled = YES;
    /*
    [self.mapView.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:NULL];*/
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self.mapView showsUserLocation]) {
        //[self moveOrZoomOrAnythingElse];
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
}

- (void) cleanUp
{
    _mapView.delegate = nil;
    
    [_searchBar release];       _searchBar = nil;
    [_mapView release];         _mapView = nil;
    [_auxTableVC release];      _auxTableVC = nil;
}

@end
