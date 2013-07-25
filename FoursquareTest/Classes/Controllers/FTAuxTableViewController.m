//
//  FTAuxTableViewController.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTAuxTableViewController.h"
#import "FTVenueTableCell.h"
#import "FTDataManager.h"

@interface FTAuxTableViewController () <EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView*      _refreshHeaderView;
    BOOL                            _reloading;
}

@property (nonatomic, retain) NSArray *venues;

- (void) reloadTableViewDataSource;
- (void) doneLoadingTableViewData;

- (void) setupScreen;
- (void) cleanUp;
- (UITableViewCell*) getLoadingCell;
@end

@implementation FTAuxTableViewController
@synthesize venues = _venues, owner = _owner, lastKnownCoordinate = _lastKnownCoordinate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This one was added to prevent search functionality and screen changes, as far as we need only one screen by the task
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
        return;
    
    searchBar.text = @"";
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
    return (self.venues ? [self.venues count] : ([FTDataManager isNetworkAccessible] ? 1 : 0));
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.venues && [self.venues count]){
        NSString *cellID;
        NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
        NSInteger row = [indexPath row];
        
        /*
        if (row == 0 && row == sectionRows - 1)         cellID = @"cellIDSingle";
        else if (row == 0)                              cellID = @"cellIDTop";
        else if (row == sectionRows - 1)                cellID = @"cellIDBottom";
        else                                            cellID = @"cellIDMiddle";
         */
        
        FTVenueTableCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            //cell = [[[FTVenueTableCell alloc] initWithVenueData:nil reuseIdentifier:cellID] autorelease];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FTVenueTableCell" owner:self options:nil];
            cell = [topLevelObjects objectAtIndex:0];
            
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
        }
        
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
    if ((force || !self.venues || [self.venues count]) && [FTDataManager isNetworkAccessible]){
        [self reloadTableViewDataSource];
    }
}

- (void) reloadTableViewDataSource
{
	_reloading = YES;
    
    [FTDataManager getVenuesForLocationCoordinate:self.lastKnownCoordinate
                                        withBlock:^(NSArray *venues, NSError *err) {
                                            if ((!err || [err code] == 0) && venues){
                                                self.venues = venues;
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
        [FTUtilities showConnectionLostMessageInView:self.owner.navigationController.view];
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

- (void) setupScreen
{
    self.tableView.backgroundView = nil;
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"app-bg-pattern.png"]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,1.0f,1.0f)];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        [view setBackgroundColor:[UIColor clearColor]];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
}

- (void) cleanUp
{
    self.owner = nil;
    
    [_venues release];  _venues = nil;
    
    _refreshHeaderView = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
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
