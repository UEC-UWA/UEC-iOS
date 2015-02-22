//
//  UECNewsViewController.h
//  UEC
//
//  Created by Jad Osseiran on 22/02/2015.
//  Copyright (c) 2015 Appulse. All rights reserved.
//

#import "CoreDataTableViewController.h"

#import "UECArticleViewController.h"

#import "NewsArticle.h"

@interface UECNewsViewController : CoreDataTableViewController

- (void)refreshInvoked:(id)sender;

- (NSFetchedResultsController *)defaultFetchedResultsController;
- (NSFetchedResultsController *)fetchedResultsControllerForSearching:(NSString *)searchString withScope:(NSString *)scope;

@end
