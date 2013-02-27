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

// Searching
@property (copy, nonatomic) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@end

static CGFloat kCellHeight = 120.0;

@implementation UECNewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"News";
    
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
    // During the fetch disable search.
    self.searchDisplayController.searchBar.userInteractionEnabled = NO;
    self.searchDisplayController.searchBar.alpha = 0.75;
    
    [[APSDataManager sharedManager] cacheEntityName:@"NewsArticle" completion:^{
        self.searchDisplayController.searchBar.userInteractionEnabled = YES;
        self.searchDisplayController.searchBar.alpha = 1.0;
    }];
    
    self.fetchedResultsController = [self defaultFetchedResultsController];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (void)refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self refreshData];

    [self.refreshControl endRefreshing];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)defaultFetchedResultsController
{
    return [self fetchedResultsControllerForSearching:nil withScope:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForSearching:(NSString *)searchString withScope:(NSString *)scope
{
    NSFetchedResultsController *fetchResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        NSPredicate *filterPredicate = nil;
        
        if (scope && ![scope isEqualToString:@"All"])
            filterPredicate = [NSPredicate predicateWithFormat:@"category LIKE %@", scope];
        
        NSMutableArray *predicateArray = [NSMutableArray array];
        if (searchString && searchString.length > 0) {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString]];
            if (filterPredicate) {
                filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
            } else {
                filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
            }
        }
        
        [request setPredicate:filterPredicate];
        [request setSortDescriptors:@[sortDescriptor]];
        
    } entityName:@"NewsArticle" sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![fetchResultsController performFetch:&error]) {
        // Handle error here.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return fetchResultsController;
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"News Cell"; 
    
    UECNewsArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NewsArticle *newsArticle = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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
    NewsArticle *newsArticle = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UECArticleViewController *articleVC = (UECArticleViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        articleVC.newsArticle = newsArticle;
        
        
    } else {
        UECArticleViewController *articleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECArticleViewController"];
        articleVC.newsArticle = newsArticle;
        
        [self.navigationController pushViewController:articleVC animated:YES];
    }
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    self.fetchedResultsController = [self fetchedResultsControllerForSearching:searchText withScope:scope];
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

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    self.fetchedResultsController = [self defaultFetchedResultsController];
}

@end
