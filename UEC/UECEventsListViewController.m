//
//  UECEventListViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECEventsListViewController.h"

#import "Event.h"

@interface UECEventsListViewController ()

@end

@implementation UECEventsListViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    [self.delegate didRefreshDataWithHeaderKey:@"startDate" completion:^(NSArray *data, NSArray *sectionNames) {
        self.events = data;
        self.eventDateTitles = sectionNames;
        
        [self.tableView reloadData];
    }];
}

#pragma mark - Refresh

- (void)handleRefresh:(id)sender
{
    [self.delegate didRefreshDataWithHeaderKey:@"startDate" completion:^(NSArray *data, NSArray *sectionNames) {
        self.events = data;
        self.eventDateTitles = sectionNames;
        
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Event Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    Event *event = self.events[indexPath.section][indexPath.row];
    
    cell.textLabel.text = event.name;
    cell.detailTextLabel.text = event.location;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
