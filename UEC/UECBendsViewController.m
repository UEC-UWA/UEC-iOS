//
//  UECBendsViewController.m
//  UEC
//
//  Created by Jad Osseiran on 3/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECBendsViewController.h"

#import "APSDataManager.h"
#import "UECReachabilityManager.h"
#import "UECAlertManager.h"

#import "UECPreviewItem.h"
#import "UECBendCell.h"
#import "UECDownloadingCell.h"

#import "Bend.h"

@interface UECBendsViewController () <QLPreviewControllerDataSource>

@property (strong, nonatomic) UECPreviewItem *previewBend;

@end

@implementation UECBendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Bends";

    [[APSDataManager sharedManager] cacheEntityName:@"Bend" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:NO];
        }
    }];
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Bend" sectionNameKeyPath:nil cacheName:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restorePurchases:)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Bend Bought Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Downloading

- (NSString *)formattedSizeForBytes:(long long)bytes
{    
    CGFloat kiloBytes = bytes / 1000.0;
    if (kiloBytes < 1.0)
        return [[NSString alloc] initWithFormat:@"%lld Bytes", bytes];
    
    CGFloat megaBytes = kiloBytes / 1000.0;
    if (megaBytes < 1.0)
        return [[NSString alloc] initWithFormat:@"%.2f KB", kiloBytes];
    
    CGFloat gigaBytes = megaBytes / 1000.0;
    if (gigaBytes < 1.0)
        return [[NSString alloc] initWithFormat:@"%.2f MB", megaBytes];
    
    CGFloat teraBytes = gigaBytes / 1000.0;
    if (teraBytes < 1.0)
        return [[NSString alloc] initWithFormat:@"%.2f GB", gigaBytes];
    
    return @"Unknown Size";
}

- (void)updateProgressOnCell:(UECDownloadingCell *)cell
                   bytesRead:(NSUInteger)bytesRead
              totalBytesRead:(long long)totalBytesRead
    totalBytesExpectedToRead:(long long)totalBytesExpectedToRead
{
    CGFloat increment = (cell.frame.size.width * bytesRead) / totalBytesExpectedToRead;
    
    cell.progressLabel.text = [[NSString alloc] initWithFormat:@"%@ of %@",
                               [self formattedSizeForBytes:totalBytesRead],
                               [self formattedSizeForBytes:totalBytesExpectedToRead]];
    
    cell.widthConstraint.constant += increment;
}

- (void)downloadBend:(Bend *)bend inCell:(UECDownloadingCell *)cell completion:(void (^)())completionBlock;
{    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *bendsPath = [documentsPath stringByAppendingPathComponent:@"Bends"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:bendsPath]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:bendsPath
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:&error]) {
            NSLog(@"Error creating Bends directory");
        }
    }
    
    NSString *fileName = [[bend.fileAddress pathComponents] lastObject];
    NSString *bendPath = [bendsPath stringByAppendingPathComponent:fileName];
    
    cell.widthConstraint.constant = 1.0;
    
    [[APSDataManager sharedManager] downloadFileAtURL:[[NSURL alloc] initWithString:bend.fileAddress]
                                         intoFilePath:bendPath
                                downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                    
                                    [self updateProgressOnCell:cell
                                                     bytesRead:bytesRead
                                                totalBytesRead:totalBytesRead
                                      totalBytesExpectedToRead:totalBytesExpectedToRead];
                                    
                                } completion:^(NSURL *localURL) {
                                    bend.purchased = @(YES);
                                    bend.downloading = @(NO);
                                    bend.localURLString = [localURL path];
                                                                        
                                    [[APSDataManager sharedManager] saveContext];
                                                                    
                                    if (completionBlock) {
                                        completionBlock();
                                    }
                                }];
}

#pragma mark - In-app purchase

- (void)restorePurchases:(id)sender
{
    
}

- (void)purchaseBend:(id)sender
{
    UECBendCell *cell = (UECBendCell *)[[sender superview] superview];
    
    Bend *bend = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    // TODO: Here handle the in-app purchase.
    // if (successfullPurchase) {
    [cell.purchaseButton removeFromSuperview];
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    
    bend.downloading = @(YES);
    [[APSDataManager sharedManager] saveContext];
    
    [self.tableView reloadData];
    
    UECDownloadingCell *downloadCell = (UECDownloadingCell *)[self.tableView cellForRowAtIndexPath:cellIndexPath];
    
    [self downloadBend:bend inCell:downloadCell completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"UEC Bends";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bend *bend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = nil;
    
    if ([bend.downloading boolValue]) {
        CellIdentifier = @"Bend Download Cell";
        
        UECDownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.nameLabel.text = bend.title;
        cell.progressLabel.text = @"Staring Download...";
        
        [cell.downloadActivityView startAnimating];
        
        return cell;
    }
    
    if ([bend.purchased boolValue]) {
        CellIdentifier = @"Bend Bought Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = bend.title;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else {
        CellIdentifier = @"Bend Cell";
        
        UECBendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.nameLabel.text = bend.title;
        cell.sizeLabel.text = [self formattedSizeForBytes:[bend.size longLongValue]];
        
        [cell.purchaseButton addTarget:self action:@selector(purchaseBend:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bend *bend = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([bend.purchased boolValue]) {
        self.previewBend = [[UECPreviewItem alloc] init];
        self.previewBend.localURL = [[NSURL alloc] initFileURLWithPath:bend.localURLString];
        self.previewBend.documentTitle = bend.title;
        
        if ([QLPreviewController canPreviewItem:self.previewBend]) {

            
            QLPreviewController *quickLookC = [[QLPreviewController alloc] init];
            quickLookC.dataSource = self;
            
            [self.navigationController pushViewController:quickLookC animated:YES];
        } else {
            [[UECAlertManager sharedManager] showPreviewAlertForFileName:bend.title inController:self];
        }
    }
}

#pragma mark - Quick Look

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index;
{
    return self.previewBend;
}

@end
