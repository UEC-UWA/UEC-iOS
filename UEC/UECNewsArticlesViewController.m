//
//  UECNewsArticlesViewController.m
//  UEC
//
//  Created by Jad Osseiran on 6/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECNewsArticlesViewController.h"

#import "UECArticleViewController.h"
#import "UECNewsArticleCell.h"

#import "APSDataManager.h"
#import "UECReachabilityManager.h"
#import "NSDate+Formatter.h"

#import "NewsArticle.h"

@interface UECNewsArticlesViewController () <UISearchResultsUpdating, UISearchControllerDelegate>

// Searching
@property (nonatomic, strong) UISearchController *searchController;
@property (copy, nonatomic) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@property (strong, nonatomic) UINavigationController *detailNavController;

@end

static CGFloat kCellHeight = 120.0;

@implementation UECNewsArticlesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"News";

    // Add refresh control programmatically (not in NIB)
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:) forControlEvents:UIControlEventValueChanged];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:[[UITableViewController alloc] init]];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];

    // Restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm) {
        [self.searchController setActive:self.searchWasActive];
        [self.searchController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchController.searchBar setText:self.savedSearchTerm];

        self.savedSearchTerm = nil;
    }

//    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"UECNewsArticleCell" bundle:nil] forCellReuseIdentifier:@"News Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UECNewsArticleCell" bundle:nil] forCellReuseIdentifier:@"News Cell"];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    [self refreshInvoked:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //
    //    if (![defaults boolForKey:@"shownVersionInfo"]) {
    //
    //         UINavigationController *versionInfoNC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECVersionInfoNavController"];
    //
    //        if (IPAD) {
    //            versionInfoNC.modalPresentationStyle = UIModalPresentationFormSheet;
    //        }
    //
    //        [self presentViewController:versionInfoNC animated:YES completion:nil];
    //
    //        [defaults setBool:YES forKey:@"shownVersionInfo"];
    //        [defaults synchronize];
    //    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = self.searchController.active;
    self.savedSearchTerm = self.searchController.searchBar.text;
    self.savedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Management

- (void)refreshInvoked:(id)sender {
    BOOL manualRefresh = (sender != nil);

    [[APSDataManager sharedManager] cacheEntityName:@"NewsArticle" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:manualRefresh];
        }
        
        [self.refreshControl endRefreshing];
    }];

    self.fetchedResultsController = [self defaultFetchedResultsController];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return [self fetchedResultsControllerForSearching:nil withScope:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerForSearching:(NSString *)searchString withScope:(NSString *)scope {
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
        if (error != nil) {
            [error handle];
        }
    }

    return fetchResultsController;
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"News Cell";

    UECNewsArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NewsArticle *newsArticle = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Configure the cell...
    cell.titleLabel.text = newsArticle.title;
    cell.categoryLabel.text = newsArticle.category;
    cell.summaryLabel.text = newsArticle.summary;
    cell.dateLabel.text = [newsArticle.date stringShortValue];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsArticle *newsArticle = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UECArticleViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECArticleViewController"];
    detailVC.newsArticle = newsArticle;

    [self.navigationController pushViewController:detailVC animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    if (self.tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    self.fetchedResultsController = [self fetchedResultsControllerForSearching:searchText withScope:scope];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    UISearchBar *searchBar = self.searchController.searchBar;
    NSInteger scopeIndex = searchBar.selectedScopeButtonIndex;
    NSString *scope = searchBar.scopeButtonTitles[scopeIndex];

    [self filterContentForSearchText:searchBar.text scope:scope];
}

//- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
//    if (self.tableView.separatorStyle != UITableViewCellSeparatorStyleSingleLine) {
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    }
//
//    self.fetchedResultsController = [self defaultFetchedResultsController];
//}

@end
