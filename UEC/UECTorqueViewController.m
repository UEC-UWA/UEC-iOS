//
//  UECTorqueViewController.m
//  UEC
//
//  Created by Jad Osseiran on 6/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECTorqueViewController.h"

#import "APSDataManager.h"
#import "UECReachabilityManager.h"

#import "NSDate+Formatter.h"
#import "UECPreviewItem.h"
#import "UECAlertManager.h"

#import "Torque.h"

@interface UECTorqueViewController () <QLPreviewControllerDataSource>

@property (strong, nonatomic) UECPreviewItem *torquePreview;

@end

@implementation UECTorqueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[APSDataManager sharedManager] cacheEntityName:@"Torque" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:NO];
        }
    }];
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Torque" sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Downloading

- (void)downloadTorque:(Torque *)torque completion:(void (^)(NSURL *localURL))completionBlock;
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *torquesPath = [documentsPath stringByAppendingPathComponent:@"Torques"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:torquesPath]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:torquesPath
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:&error]) {
            NSLog(@"Error creating Torques directory");
        }
    }
    
    NSString *fileName = [[torque.fileAddress pathComponents] lastObject];
    NSString *torquePath = [torquesPath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:torque.localURLString]) {
        [[APSDataManager sharedManager] downloadFileAtURL:[[NSURL alloc] initWithString:torque.fileAddress] intoFilePath:torquePath completion:^(NSURL *localURL) {
            if (completionBlock) {
                completionBlock(localURL);
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock([[NSURL alloc] initFileURLWithPath:torquePath]);
        }
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Torque Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Torque *torque = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = torque.name;
    cell.detailTextLabel.text = [torque.date stringNoTimeValue];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = activityIndicator;
    
    Torque *torque = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    self.torquePreview = [[UECPreviewItem alloc] init];
    
    [self downloadTorque:torque completion:^(NSURL *localURL) {
        cell.accessoryView = nil;
        
        torque.localURLString = [localURL path];
        [[APSDataManager sharedManager] saveContext];
        
        self.torquePreview.documentTitle = torque.name;
        self.torquePreview.localURL = localURL;
        
        if ([QLPreviewController canPreviewItem:self.torquePreview]) {
            QLPreviewController *quickLookC = [[QLPreviewController alloc] init];
            quickLookC.dataSource = self;
            [self.navigationController pushViewController:quickLookC animated:YES];
        } else {
            [[UECAlertManager sharedManager] showPreviewAlertForFileName:@"About the UEC" inController:self];
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Quick Look

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index;
{
    return self.torquePreview;
}

@end
