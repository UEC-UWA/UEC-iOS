//
//  UECTicketsViewController.m
//  UEC
//
//  Created by Jad Osseiran on 9/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECTicketsViewController.h"

#import "Event.h"

#import "NSDate+Formatter.h"

@interface UECTicketsViewController ()

@end

@implementation UECTicketsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.delegate didRefreshDataWithHeaderKey:@"startSale" completion:^(NSArray *data, NSArray *sectionNames) {
        self.events = data;
        self.eventDateTitles = sectionNames;
        
        [self.tableView reloadData];
    }];
}

#pragma mark - Refresh

- (void)handleRefresh:(id)sender
{
    [self.delegate didRefreshDataWithHeaderKey:@"startSale" completion:^(NSArray *data, NSArray *sectionNames) {
        self.events = data;
        self.eventDateTitles = sectionNames;
        
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Ticket Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Event *event = self.events[indexPath.section][indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = event.name;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", [event.startSale stringNoTimeValue], [event.endSale stringNoTimeValue]];
    
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
