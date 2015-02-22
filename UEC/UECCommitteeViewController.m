//
//  UECCommitteeViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "UECCommitteeViewController.h"
#import "UECCommitteeMemberViewController.h"
#import "UECCommitteeMemberCell.h"

#import "APSDataManager.h"
#import "UECCoreDataManager.h"
#import "UECReachabilityManager.h"

#import "Person.h"

@interface UECCommitteeViewController ()

@property (nonatomic, strong) UECCommitteeMemberViewController *detailViewController;

@end

static CGFloat kCellHeight = 55.0;

@implementation UECCommitteeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Committee";

    [[APSDataManager sharedManager] cacheEntityName:@"Person" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:NO];
        }
        
        [self setCustomCommitteeOrder];
    }];

    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *subcommitteeSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"subcommittee" ascending:YES];
        NSSortDescriptor *orderSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSSortDescriptor *lastNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        request.sortDescriptors = @[subcommitteeSortDescriptor, orderSortDescriptor, lastNameSortDescriptor];
    } entityName:@"Person" sectionNameKeyPath:@"subcommittee" cacheName:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Person Detail Segue"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:sender];

        self.detailViewController = [segue destinationViewController];
        self.detailViewController.person = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    }
}

#pragma mark - Data Source Organising

- (void)setCustomCommitteeOrder {
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

    [[UECCoreDataManager sharedManager] saveMainContext];
}

#pragma mark - Table view

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Committee Cell";
    UECCommitteeMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (person.photoPath) {
        NSURL *imageURL = [[NSURL alloc] initWithString:person.photoPath];
        UIImage *placeHolderImage = [UIImage imageNamed:@"gentleman.png"];
        [cell.pictureImageView sd_setImageWithURL:imageURL placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error != nil) {
                [error handle];
            }
        }];
    }

    cell.firstNameLabel.text = person.firstName;
    cell.lastNameLabel.text = person.lastName;
    cell.positionLabel.text = person.position;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
