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

#import "APSDataManager.h"
#import "Person.h"

#import "NSArray+TableViewOrdering.h"

@interface UECCommitteeViewController ()

@property (strong, nonatomic) NSArray *committeeMembers, *subcommittees;

@end

static CGFloat kCellHeight = 55.0;

@implementation UECCommitteeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[APSDataManager sharedManager] getDataForEntityName:@"Person" coreDataCompletion:^(NSArray *cachedObjects) {
        [self reloadDataWithNewObjects:cachedObjects];
    } downloadCompletion:^(BOOL needsReloading, NSArray *downloadedObjects) {
        if (needsReloading) {
            [self reloadDataWithNewObjects:downloadedObjects];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source Organising

- (NSArray *)customSortedArrayWithPositionOfExec:(NSInteger)execPosition inArray:(NSMutableArray *)array
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position LIKE %@", @"President"];
    Person *president = [[[array[execPosition] copy] filteredArrayUsingPredicate:predicate] lastObject];
    NSInteger presidentIndex = [array[execPosition] indexOfObject:president];
    
    NSMutableArray *execArray = [array[execPosition] mutableCopy];
    [execArray exchangeObjectAtIndex:presidentIndex withObjectAtIndex:0];
    array[execPosition] = execArray;
    
    [array exchangeObjectAtIndex:execPosition withObjectAtIndex:0];
    
    NSMutableArray *subcommittees = self.subcommittees.mutableCopy;
    [subcommittees exchangeObjectAtIndex:execPosition withObjectAtIndex:0];
    self.subcommittees = subcommittees;
    
    return array;
}

- (void)reloadDataWithNewObjects:(NSArray *)newObjects
{
    if (newObjects.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else {         
        NSString *sectionKey = @"subcommittee";
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sectionKey ascending:YES];
        NSArray *sectionedArray = [newObjects sectionedArrayWithSplittingKey:sectionKey withSortDescriptor:@[sortDescriptor]];
        NSMutableArray *data = [[NSMutableArray alloc] initWithArray:sectionedArray];
        self.subcommittees = [data sectionHeaderObjectsForKey:sectionKey sectionedArray:YES];
        
        NSInteger execPosition = [self.subcommittees indexOfObject:@"Executive"];
        // This next bit is to get the Exec and the president to be at the top.
        self.committeeMembers = [self customSortedArrayWithPositionOfExec:execPosition inArray:data];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.committeeMembers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.committeeMembers[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.subcommittees[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Committee Cell";
    __block UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...    
    Person *person = self.committeeMembers[indexPath.section][indexPath.row];
    
    [cell.imageView setImageWithURL:[[NSURL alloc] initWithString:person.photoPath]
                   placeholderImage:[UIImage imageNamed:@"gentleman.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              
                          }];
    cell.imageView.clipsToBounds = YES;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;

    // TODO: Make the first name bold.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    cell.detailTextLabel.text = person.position;
    
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
