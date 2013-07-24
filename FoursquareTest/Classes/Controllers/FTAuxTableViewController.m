//
//  FTAuxTableViewController.m
//  FoursquareTest
//
//  Created by Egor Dovzhenko on 24.07.13.
//  Copyright (c) 2013 Egor Dovzhenko. All rights reserved.
//

#import "FTAuxTableViewController.h"
#import "FTVenueTableCell.h"

@interface FTAuxTableViewController () <EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView*      _refreshHeaderView;
    BOOL                            _reloading;
}

- (void) reloadTableViewDataSource;
- (void) doneLoadingTableViewData;

- (void) setupScreen;
- (void) cleanUp;
@end

@implementation FTAuxTableViewController

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
    // •
    // •
    // •
    
    return 14;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *cellID;
    NSInteger sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
    NSInteger row = [indexPath row];
    
    if (row == 0 && row == sectionRows - 1)         cellID = @"cellIDSingle";
    else if (row == 0)                              cellID = @"cellIDTop";
    else if (row == sectionRows - 1)                cellID = @"cellIDBottom";
    else                                            cellID = @"cellIDMiddle";
    
    FTVenueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
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
    
    [cell updateWithVenueData:nil];
    
    if (row == 1)
        cell.imgvSpecial.hidden = NO;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FT_APPRNS_CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"Dummy: Venue table cell tapped!");
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void) reloadTableViewDataSource
{
	_reloading = YES;
    
    // •
    // •
    // Reloading data
    // •
    // •
}

- (void) doneLoadingTableViewData
{
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
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
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
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
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"app-bg-pattern.png"]];
    
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
    _refreshHeaderView = nil;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
