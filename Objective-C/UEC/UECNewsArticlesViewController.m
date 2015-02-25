//
//  UECNewsArticlesViewController.m
//  UEC
//
//  Created by Jad Osseiran on 6/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECNewsArticlesViewController.h"

#import "UECNewsArticleSearchViewController.h"

@interface UECNewsArticlesViewController () <UISearchResultsUpdating, UISearchControllerDelegate>

// Searching
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic, strong) UINavigationController *detailNavController;

@end

@implementation UECNewsArticlesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"News";

    // Add refresh control programmatically (not in NIB)
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:) forControlEvents:UIControlEventValueChanged];

    UINavigationController *searchResultsController = [self.storyboard instantiateViewControllerWithIdentifier:@"ArticlesSearchResultsNavController"];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];

    // Restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm) {
        [self.searchController setActive:self.searchWasActive];
        [self.searchController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchController.searchBar setText:self.savedSearchTerm];

        self.savedSearchTerm = nil;
    }

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

- (void)pushArticle:(NewsArticle *)newsArticle {
    if (self.presentedViewController != nil) {
        self.searchController.searchBar.text = nil;
        self.searchController.active = NO;
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }

    UECArticleViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UECArticleViewController"];
    detailViewController.newsArticle = newsArticle;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsArticle *newsArticle = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self pushArticle:newsArticle];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    if (self.searchController.searchResultsController != nil) {
        UINavigationController *navigationController = (UINavigationController *)self.searchController.searchResultsController;

        UECNewsArticleSearchViewController *articlesSearchViewController = (UECNewsArticleSearchViewController *)navigationController.topViewController;
        articlesSearchViewController.fetchedResultsController = [self fetchedResultsControllerForSearching:searchText withScope:scope];
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    UISearchBar *searchBar = self.searchController.searchBar;
    NSInteger scopeIndex = searchBar.selectedScopeButtonIndex;
    NSString *scope = searchBar.scopeButtonTitles[scopeIndex];

    [self filterContentForSearchText:searchBar.text scope:scope];
}

@end
