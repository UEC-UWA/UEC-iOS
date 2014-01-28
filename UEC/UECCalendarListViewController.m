//
//  UECCalendarListViewController.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "UECCalendarListViewController.h"
#import "UECEventDetailViewController.h"

#import "UECEventCell.h"

#import "UECReachabilityManager.h"
#import "APSDataManager.h"
#import "NSDate+Formatter.h"

#import "Event.h"

@interface UECCalendarListViewController ()

@end

static CGFloat kCellHeight = 55.0;

@implementation UECCalendarListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Event" sectionNameKeyPath:@"startDate" cacheName:nil];
    [self handleRefresh:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Event Detail Segue"]) {
        // Navigation logic may go here. Create and push another view controller.
        UECEventDetailViewController *detailViewController = (UECEventDetailViewController *)segue.destinationViewController;
        detailViewController.event = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}

#pragma mark - Refresh

- (void)handleRefresh:(id)sender
{
    BOOL manualRefresh = (sender != nil);

    [[APSDataManager sharedManager] cacheEntityName:@"Event" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:manualRefresh];
        }
        [self.refreshControl endRefreshing];
    }];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *rawDateStr = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    //convert default date string to NSDate...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:rawDateStr];
    
    //convert NSDate to format we want...
    return [date stringValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Event Cell";
    
    UECEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.eventDetailLabel.text = event.location;
    cell.eventLabel.text = event.name;
    [cell.eventImageView setImageWithURL:[[NSURL alloc] initWithString:event.photoPath]
                        placeholderImage:[UIImage imageNamed:@"gentleman.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                   if (error) {
                                       [error handle];
                                   }
                               }];
    
//    [cell.eventImageView setImageWithURL:nil placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        
//    }];
    
    UIImage *image = nil;
    if ([event.type isEqualToString:@"Social"]) {
        image = [[UECThemeManager sharedTheme] socialEventImage];
    } else if ([event.type isEqualToString:@"Educational"]) {
        image = [[UECThemeManager sharedTheme] educationEventImage];
    } else {
        image = [[UECThemeManager sharedTheme] otherEventImage];
    }
    
    [cell.categoryImageView setImage:image];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
