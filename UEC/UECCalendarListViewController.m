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
    
    [self.delegate didRequestDataRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Refresh

- (void)handleRefresh:(id)sender
{
    [self.delegate didRequestDataRefresh];
    
    [self.refreshControl endRefreshing];
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
    
    switch (self.listType) {
        case UECEventListTypeEvents:
            cell.eventDetailLabel.text = event.location;
            break;
            
        case UECEventListTypeTickets:
            cell.eventDetailLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", [event.startSale stringNoTimeValue], [event.endSale stringNoTimeValue]];
            break;
            
        default:
            break;
    }
    
    cell.eventLabel.text = event.name;
    
//    [cell.eventImageView setImageWithURL:nil placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        
//    }];
    
    NSString *imageName = nil;
    if ([event.type isEqualToString:@"Social"]) {
        imageName = @"redsolocup.png";
    } else if ([event.type isEqualToString:@"Educational"]) {
        imageName = @"gradhat.png";
    } else {
        imageName = @"hardhat.png";
    }
    
    [cell.categoryImageView setImage:[UIImage imageNamed:imageName]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    UECEventDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UECEventDetailViewController"];
    detailViewController.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
