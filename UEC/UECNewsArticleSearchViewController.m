//
//  UECNewsArticleSearchViewController.m
//  UEC
//
//  Created by Jad Osseiran on 22/02/2015.
//  Copyright (c) 2015 Appulse. All rights reserved.
//

#import "UECNewsArticleSearchViewController.h"

#import "UECNewsArticlesViewController.h"

@interface UECNewsArticleSearchViewController ()

@end

@implementation UECNewsArticleSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsArticle *article = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UINavigationController *presentingNavController = (UINavigationController *)self.presentingViewController;
    UECNewsArticlesViewController *newsArticleViewContrroller = (UECNewsArticlesViewController *)presentingNavController.topViewController;

    [newsArticleViewContrroller pushArticle:article];
}

@end
