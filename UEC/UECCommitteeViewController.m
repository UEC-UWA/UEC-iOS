//
//  UECCommitteeViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "UECCommitteeViewController.h"
#import "UECCommitteeMemberViewController.h"
#import "UECCommitteeMemberCell.h"

#import "APSDataManager.h"
#import "Person.h"

@interface UECCommitteeViewController ()

@end

static CGFloat kCellHeight = 55.0;

@implementation UECCommitteeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Committee";
    
    [[APSDataManager sharedManager] cacheEntityName:@"Person" completion:^{
        [self setCustomCommitteeOrder];
    }];
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *subcommitteeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"subcommittee" ascending:YES];
        NSSortDescriptor *orderSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSSortDescriptor *lastNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        request.sortDescriptors = @[subcommitteeSortDescriptor, orderSortDescriptor, lastNameSortDescriptor];
    } entityName:@"Person" sectionNameKeyPath:@"subcommittee" cacheName:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Person Detail Segue"]) {
        UECCommitteeMemberViewController *committeeMemberVC = [segue destinationViewController];
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:sender];
        committeeMemberVC.person = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    }
}

#pragma mark - Data Source Organising

- (void)setCustomCommitteeOrder
{
    NSMutableArray *seenSubcommittees = [[NSMutableArray alloc] init];
    
    NSArray *fetchedObjects = [self.fetchedResultsController fetchedObjects];
    
    [fetchedObjects enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
        if (![seenSubcommittees containsObject:person.subcommittee])
            [seenSubcommittees addObject:person.subcommittee];
        
        if ([person.subcommittee isEqualToString:@"Executive"])
            person.order = @(0);
        else
            person.order = @([seenSubcommittees indexOfObject:person.subcommittee] + 1);
        
        if ([person.position isEqualToString:@"President"]) {
            person.order = @(-1);
        }
        
    }];
    
    [[APSDataManager sharedManager] saveContext];
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
    static NSString *CellIdentifier = @"Committee Cell";
    UECCommitteeMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...    
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.pictureImageView setImageWithURL:[[NSURL alloc] initWithString:person.photoPath]
                          placeholderImage:[UIImage imageNamed:@"gentleman.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     
                                 }];

    cell.firstNameLabel.text = person.firstName;
    cell.lastNameLabel.text = person.lastName;
    cell.positionLabel.text = person.position;
    
    return cell;
}

@end
