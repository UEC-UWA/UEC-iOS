//
//  UECNewsViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import "UECNewsViewController.h"

#import "UECArticleViewController.h"
#import "UECNewsArticleCell.h"
#import "APSDataManager.h"

#import "NewsArticle.h"

#import "NSDate+Formatter.h"

@interface UECNewsViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSArray *newsArticles;

// Searching
@property (strong, nonatomic) NSMutableArray *filteredListContent;
@property (copy, nonatomic) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@end

static CGFloat kCellHeight = 120.0;

@implementation UECNewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Add refresh control programmatically (not in NIB)
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
    // Restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm) {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }

    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"UECNewsArticleCell" bundle:nil] forCellReuseIdentifier:@"News Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UECNewsArticleCell" bundle:nil] forCellReuseIdentifier:@"News Cell"];

    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Management

- (void)refreshData
{
    [[APSDataManager sharedManager] getDataForEntityName:@"NewsArticle" coreDataCompletion:^(NSArray *cachedObjects) {
        [self reloadDataWithNewObjects:cachedObjects];
    } downloadCompletion:^(BOOL needsReloading, NSArray *downloadedObjects) {
        if (needsReloading) {
            [self reloadDataWithNewObjects:downloadedObjects];
        }
    }];
}

- (void)reloadDataWithNewObjects:(NSArray *)newObjects
{
    if (newObjects.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        self.searchDisplayController.searchBar.userInteractionEnabled = NO;
        self.searchDisplayController.searchBar.alpha = 0.75;
    } else {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        self.newsArticles = [newObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        // create a filtered list that will contain products for the search results table.
        self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.newsArticles count]];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        self.searchDisplayController.searchBar.userInteractionEnabled = YES;
        self.searchDisplayController.searchBar.alpha = 1.0;
        
        [self.tableView reloadData];
    }
}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self refreshData];

    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent count];
    } else {
        return [self.newsArticles count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"News Cell"; 
    
    UECNewsArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NewsArticle *newsArticle = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        newsArticle = self.filteredListContent[indexPath.row];
    } else {
        newsArticle = self.newsArticles[indexPath.row];
    }
    
    // Configure the cell...
    cell.titleLabel.text = newsArticle.title;
    cell.categoryLabel.text = newsArticle.category;
    cell.summaryLabel.text = newsArticle.summary;
    cell.dateLabel.text = [newsArticle.date stringValue];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsArticle *newsArticle = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        newsArticle = self.filteredListContent[indexPath.row];
    } else {
        newsArticle = self.newsArticles[indexPath.row];
    }
    
    UECArticleViewController *articleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECArticleViewController"];
    articleVC.newsArticle = newsArticle;
    
    [self.navigationController pushViewController:articleVC animated:YES];
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    // First clear the filtered array.
	[self.filteredListContent removeAllObjects];
	
	// Search the main list for products whose type matches the scope (if selected)
    // and whose name matches searchText; add items that match to the filtered array.
	for (NewsArticle *article in self.newsArticles) {
		if ([scope isEqualToString:@"All"] || [article.category isEqualToString:scope]) {
            unsigned options = (NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch);
            NSRange range = NSMakeRange(0, [searchText length]);
			NSComparisonResult result = [article.title compare:searchText
                                                       options:options
                                                         range:range];
            if (result == NSOrderedSame)
				[self.filteredListContent addObject:article];
		}
	}
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
