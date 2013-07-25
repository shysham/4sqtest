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
#import "EGORefreshTableHeaderView.h"
#import "FTVenueTableCell.h"
#import "AFNetworking.h"
#import "FTAnnotation.h"
#import "FTAnnotationView.h"

@interface FTViewController () <UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate, EGORefreshTableHeaderDelegate,
                                UITableViewDataSource, UITableViewDelegate>{
    EGORefreshTableHeaderView*      _refreshHeaderView;
    BOOL                            _reloading;
}

@property (nonatomic, assign) CLLocationCoordinate2D lastKnownCoordinate;
@property (nonatomic, retain) NSArray *venues;

- (void) reloadTableViewDataSource;
- (void) doneLoadingTableViewData;
- (void) updateMap;

- (void) reloadDataForceEvenIfHasData:(BOOL)force;

- (void) setup;
- (void) cleanUp;
- (UITableViewCell*) getLoadingCell;

- (void) cancelPressed:(id)sender;
@end

@implementation FTViewController
@synthesize searchBar = _searchBar, mapView = _mapView, tableView = _tableView, lastKnownCoordinate = _lastKnownCoordinate;
@synthesize venues = _venues;

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
    
    [self reloadDataForceEvenIfHasData:YES];   // as far as it is nested
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
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    FTAnnotationView *annView = (FTAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:@"annView"];

    if (!annView) {
        annView = [[[FTAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"] autorelease];
    }
    else {
        annView.annotation = annotation;
    }
    
    return annView;
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
        return;
    
    CLLocationCoordinate2D coord = userLocation.coordinate;
    
    // This check is required, because after Internet connection break locator can navigate to the point of {-180.0; -180.0}
    //      which may cause crash during map adjustment.
    if (![FTUtilities areValidLatitude:coord.latitude longitude:coord.longitude])
        return;
    
    [self setLastKnownCoordinate:coord];
    [self reloadDataForceEvenIfHasData:NO];  // location change does not force venue list update. User must pull2refresh.
    
    //[mapView setCenterCoordinate:userLocation.coordinate zoomLevel:FT_APPRNS_MAP_DEFAULT_ZOOM_LEVEL animated:YES];
}

// Managing annotations
- (void) updateMap
{
    if (!self.venues)
        return;
    
    NSInteger zl = [FTDataManager calculateZoomFactorForVenueSet:self.venues forLocation:self.mapView.userLocation.location];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate zoomLevel:zl animated:YES];
    
    // Remove all old annotations
    @synchronized(self){
        NSMutableArray * wiped = [self.mapView.annotations mutableCopy];
        [wiped removeObject:self.mapView.userLocation];
        [self.mapView removeAnnotations:wiped];
        [wiped release];
    }
    
    // Show only those annotations that have valid (online) icon
    __block BOOL isSpecial;
    __block NSString *iconPath;
    
    NSNumber *tmp;
    
    for (__block NSDictionary *venue in self.venues){
        tmp = [venue valueForKeyPath:kFSQDicVenueSpecials];
        isSpecial = (tmp && [tmp integerValue] > 0);
        
        iconPath = [FTDataManager iconURLForImageType:FSQICONTP_ANNOTATION foreground:YES forVenue:venue];
        if (iconPath){
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:iconPath]];
            AFImageRequestOperation *operation = [AFImageRequestOperation
                                                  imageRequestOperationWithRequest:request
                                                  success:^(UIImage *image) {
                                                      if (image){
                                                          // Create annotation
                                                          CLLocationDegrees lat = [(NSNumber*)[venue valueForKeyPath:kFSQDicVenueLatitude] doubleValue];
                                                          CLLocationDegrees lng = [(NSNumber*)[venue valueForKeyPath:kFSQDicVenueLongitude] doubleValue];
                                                          
                                                          if ([FTUtilities areValidLatitude:lat longitude:lng]){
                                                              FTAnnotation *point = [[FTAnnotation alloc] initWithType:(isSpecial ? FSQANNTP_SPECIAL : FSQANNTP_REGULAR)
                                                                                                               iconURL:iconPath
                                                                                                                 image:image
                                                                                                            coordinate:CLLocationCoordinate2DMake(lat, lng)];
                                                              
                                                              [self.mapView addAnnotation:point];
                                                              
                                                              [point release];
                                                          }
                                                      }
                                                      
                                                  }];
            
            [[FTDataManager ftOperationQueue] addOperation:operation];
        }
    }
}

#pragma mark -
#pragma mark Action handlers
- (void) cancelPressed:(id)sender
{
    NSLog(@"Dummy: Cancel button pressed on main screen");
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.tableView)    // to prevent any search controller's activity
        return 0;
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [_refreshHeaderView setHidden:(!self.venues && [FTDataManager isNetworkAccessible])];   // first launch in session
    
    return (self.venues ? [self.venues count] : ([FTDataManager isNetworkAccessible] ? 1 : 0));
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.venues && [self.venues count]){
        NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
        NSInteger row = [indexPath row];
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FTVenueTableCell" owner:self options:nil];
        FTVenueTableCell *cell = [topLevelObjects objectAtIndex:0];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIImage *rowBackground;
        UIImage *selectionBackground;
        
        if (row == 0 && row == sectionRows - 1)
        {
            rowBackground = [UIImage imageNamed:@"table-cell-single.png"];
            selectionBackground = [UIImage imageNamed:@"table-cell-single-sel.png"];
        }
        else if (row == 0)
        {
            rowBackground = [UIImage imageNamed:@"table-cell-top.png"];
            selectionBackground = [UIImage imageNamed:@"table-cell-top-sel.png"];
        }
        else if (row == sectionRows - 1)
        {
            rowBackground = [UIImage imageNamed:@"table-cell-bottom.png"];
            selectionBackground = [UIImage imageNamed:@"table-cell-bottom-sel.png"];
        }
        else
        {
            rowBackground = [UIImage imageNamed:@"table-cell-middle.png"];
            selectionBackground = [UIImage imageNamed:@"table-cell-middle-sel.png"];
        }
        
        [cell setBackgroundView:[[[UIImageView alloc] initWithImage:rowBackground] autorelease]];
        [cell setSelectedBackgroundView:[[[UIImageView alloc] initWithImage:selectionBackground] autorelease]];
        
        // If venue IDs are the same for the cell, category image will not be updated
        [cell updateWithVenueData:[self.venues objectAtIndex:indexPath.row]];
        
        return cell;
    }
    else {
        // Show loading indicator
        return [self getLoadingCell];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((self.venues && [self.venues count]) ? FT_APPRNS_CELL_HEIGHT : FT_APPRNS_CELL_LOADING_HEIGHT);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"Dummy: Venue table cell tapped!");
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void) reloadDataForceEvenIfHasData:(BOOL)force
{
    if (self.lastKnownCoordinate.latitude == 0.0f && self.lastKnownCoordinate.longitude == 0.0)
        return;     // this means that map view hasn't initialized yet. Usually happens on startup
    
    if ((force || !self.venues || [self.venues count] == 0) && [FTDataManager isNetworkAccessible]){
        [self reloadTableViewDataSource];
    }
}

- (void) reloadTableViewDataSource
{
    if (_reloading){
        return;
    }
    
	_reloading = YES;
    
    [FTDataManager getVenuesForLocationCoordinate:self.lastKnownCoordinate
                                        withBlock:^(NSArray *venues, NSError *err) {
                                            if ((!err || [err code] == 0) && venues){
                                                self.venues = venues;
                                                
                                                [self updateMap];
                                            }
                                            else {
                                                NSLog(@"ERR: table view cannot be updated - failed to retrieve venues");
                                            }
                                            
                                            [self doneLoadingTableViewData];
                                        }];
}

- (void) doneLoadingTableViewData
{
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    [self.tableView reloadData];
    _reloading = NO;
}

- (void) cancelledLoadingTableViewData
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    _reloading = NO;
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    if (![FTDataManager isNetworkAccessible]){
        // ** MUST ** use delay, otherwise we'll get issue with the pull-2-refresh indicator staying visible. Known issue of EGO pull-2-refresh.
        [self performSelector:@selector(cancelledLoadingTableViewData) withObject:nil afterDelay:1.f];
        [FTUtilities showConnectionLostMessageInView:self.navigationController.view];
    }
    else {
        [self reloadTableViewDataSource];
    }
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading;
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
    
    self.tableView.backgroundView = nil;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"app-bg-pattern.png"]];
    self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,1.0f,1.0f)] autorelease];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        [view setBackgroundColor:[UIColor clearColor]];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
    
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
    
// These 3 do not prevent FULLY from mapView interaction, thus useless:
//    self.mapView.userInteractionEnabled = NO;
//    self.mapView.zoomEnabled = NO;
//    self.mapView.scrollEnabled = NO;
     
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeNone;
    
    // This trick is used to prohibit ANY interaction or UI repsonses with/from mapView.
    //      User cannot tap, pan, zoom and cannot invoke callout for "Current Location" (which most f*** damn weird)
    UIView *veil = [[UIView alloc] initWithFrame:self.mapView.frame];
    [veil setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:veil];
    [self.view bringSubviewToFront:veil];
    [veil release];
}

- (void) internetConnectionStatusChanged
{
    if ([FTDataManager isNetworkAccessible]){
        [self reloadDataForceEvenIfHasData:YES];     // connection problems force reloading
    }
}

- (void) cleanUp
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    _mapView.delegate = nil;
    
    [_venues release];  _venues = nil;
    
    _refreshHeaderView = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    [_searchBar release];       _searchBar = nil;
    [_mapView release];         _mapView = nil;
}

// This one was added to prevent search functionality and screen changes, as far as we need only one screen by the task
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
        return;
    
    searchBar.text = @"";
}

- (UITableViewCell*) getLoadingCell
{
    // Making this one manually
    
    NSString *loadingCellID = @"loadingCellID";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:loadingCellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellID] autorelease];
        
        NSString *title = NSLocalizedString(@"skTitleLoading", nil);
        UIFont *font = [UIFont fontWithName:FT_APPRNS_VENUE_INFO_FONT_NAME size:14.f];
        CGSize sz = [title sizeWithFont:font
                      constrainedToSize:CGSizeMake(100, 100)
                          lineBreakMode:UILineBreakModeWordWrap];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, sz.width, sz.height)];
        lbl.center = cell.center;
        lbl.text = title;
        lbl.font = font;
        lbl.textColor = FT_APPRNS_VENUE_INFO_FONT_COLOR;
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lbl];
        
        CGFloat spacing = 10.f, actSize = 20.f;
        
        UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [actView setFrame:CGRectMake(lbl.center.x - sz.width / 2.f - spacing - actSize, lbl.center.y - actSize / 2.f, actSize, actSize)];
        [actView startAnimating];
        [cell.contentView addSubview:actView];
        
        [actView release];
        [lbl release];
    }
    
    return cell;
}

@end
