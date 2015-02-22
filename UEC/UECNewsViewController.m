//
//  UECNewsViewController.m
//  UEC
//
//  Created by Jad Osseiran on 22/02/2015.
//  Copyright (c) 2015 Appulse. All rights reserved.
//

#import "UECNewsViewController.h"

#import "APSDataManager.h"
#import "UECReachabilityManager.h"

#import "UECNewsArticleCell.h"

#import "NSDate+Formatter.h"

static CGFloat const kCellHeight = 120.0;

@interface UECNewsViewController ()

@end

@implementation UECNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = kCellHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"UECNewsArticleCell" bundle:nil] forCellReuseIdentifier:@"News Cell"];
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

@end
