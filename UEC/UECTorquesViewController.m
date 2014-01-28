//
//  UECTorquesViewController.m
//  UEC
//
//  Created by Jad Osseiran on 27/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECTorquesViewController.h"

#import "UECTorquePreviewController.h"

#import "APSDataManager.h"
#import "APSDownloadManager.h"

#import "UECCoreDataManager.h"
#import "UECReachabilityManager.h"
#import "UECMailManager.h"

#import "UECPreviewItem.h"
#import "UECTorqueCell.h"
#import "UECDownloadingCell.h"

#import "Torque.h"

@interface UECTorquesViewController () <QLPreviewControllerDataSource, UECReachabilityManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UECPreviewItem *previewBend;
@property (strong, nonatomic) UECReachabilityManager *reachabilityManager;

@property (strong, nonatomic) NSString *invalidTorqueName;

@property (strong, nonatomic) NSMutableArray *activeDownloads;

@end

static NSInteger kPreviewTag = 100;

@implementation UECTorquesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDownloads:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.title = @"Torques";
    
    self.activeDownloads = [[NSMutableArray alloc] init];
    self.reachabilityManager = [UECReachabilityManager sharedManagerWithDelegate:self];
    
    [[APSDataManager sharedManager] cacheEntityName:@"Torque" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [self.reachabilityManager handleReachabilityAlertOnRefresh:NO];
        }
    }];
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Torque" sectionNameKeyPath:@"downloaded" cacheName:nil];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Torque Downloaded Cell"];
        
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Downloading

- (void)deleteToriques:(NSArray *)torques
{
    for (Torque *torque in torques) {
        torque.downloading = @(NO);
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:torque.localURLString error:&error]) {
            if (error) {
                [error handle];
            }
        }
        
        torque.localURLString = nil;
        torque.downloaded = @(NO);
    }
    
    [[UECCoreDataManager sharedManager] saveMainContext];
}

- (void)stopDownloads:(NSNotification *)notification
{
    [self deleteToriques:self.activeDownloads];
    [[APSDownloadManager sharedManager] stopCurrentDownloads];
}

- (NSString *)formattedSizeForBytes:(long long)bytes
{
    if (bytes == 0)
        return @"Unknown Size";
    
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

- (void)downloadTorque:(Torque *)torque
                inCell:(UECDownloadingCell *)cell
            completion:(void (^)(BOOL success))completionBlock;
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
            if (error) {
                [error handle];
            }
        }
    }
    
    NSString *fileName = [[torque.fileAddress pathComponents] lastObject];
    NSString *torquePath = [torquesPath stringByAppendingPathComponent:fileName];
    
    cell.widthConstraint.constant = 1.0;
    
    [[APSDownloadManager sharedManager] downloadFileAtURL:[[NSURL alloc] initWithString:torque.fileAddress]
                                         intoFilePath:torquePath
                                downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                    
                                    [self updateProgressOnCell:cell
                                                     bytesRead:bytesRead
                                                totalBytesRead:totalBytesRead
                                      totalBytesExpectedToRead:totalBytesExpectedToRead];
                                    
                                } completion:^(NSURL *localURL) {
                                    torque.downloading = @(NO);
                                    
                                    if (localURL) {
                                        torque.localURLString = [localURL path];
                                        
                                        [[UECCoreDataManager sharedManager] saveMainContext];
                                        
                                        if (completionBlock) {
                                            completionBlock(YES);
                                        }
                                    } else {
                                        if (completionBlock) {
                                            completionBlock(NO);
                                        }
                                    }
                                }];
}

- (void)downloadTorque:(id)sender
{
    id cell = [[[sender superview] superview] superview];
    
    if ([cell isKindOfClass:[UECTorqueCell class]]) {
        UECTorqueCell *torqueCell = (UECTorqueCell *)cell;
        
        Torque *torque = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:torqueCell]];
        
        [self.activeDownloads addObject:torque];
        
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:torqueCell];
        
        torque.downloading = @(YES);
        [[UECCoreDataManager sharedManager] saveMainContext];
        
        [self.tableView reloadData];
        
        UECDownloadingCell *downloadCell = (UECDownloadingCell *)[self.tableView cellForRowAtIndexPath:cellIndexPath];
        
        [self downloadTorque:torque inCell:downloadCell completion:^(BOOL success) {
            if (success) {
                torque.downloaded = @(YES);
                
                [self.activeDownloads removeObject:torque];
                
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Torque *torque = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];

    return ([torque.downloaded boolValue]) ? @"On Device" : @"Download";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Torque *torque = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = nil;
    
    if ([torque.downloading boolValue]) {
        CellIdentifier = @"Torque Download Cell";
        
        UECDownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.nameLabel.text = torque.name;
        cell.progressLabel.text = @"Staring Download...";
        
        [cell.downloadActivityView startAnimating];
        
        return cell;
    } 
    
    if ([torque.downloaded boolValue]) {
        CellIdentifier = @"Torque Downloaded Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = torque.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else {
        CellIdentifier = @"Torque Cell";
        
        UECTorqueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.nameLabel.text = torque.name;
        cell.sizeLabel.text = [self formattedSizeForBytes:[torque.size longLongValue]];
        
        [cell.downloadButton addTarget:self action:@selector(downloadTorque:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    Torque *torque = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return ([torque.downloaded boolValue] && torque.localURLString && ![torque.downloading boolValue]);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Torque *torque = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [self deleteToriques:@[torque]];
        
        [tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Torque *torque = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([torque.downloaded boolValue] && torque.localURLString) {
        self.previewBend = [[UECPreviewItem alloc] init];
        self.previewBend.localURL = [[NSURL alloc] initFileURLWithPath:torque.localURLString];
        self.previewBend.documentTitle = torque.name;
        
        if ([UECTorquePreviewController canPreviewItem:self.previewBend]) {
            UECTorquePreviewController *quickLookC = [[UECTorquePreviewController alloc] init];
            quickLookC.dataSource = self;
            [self.navigationController pushViewController:quickLookC animated:YES];
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"Cannot open %@. The file is probably corrupt. Please send an email to report this problem", torque.name];
            UIAlertView *previewAlertView = [[UIAlertView alloc] initWithTitle:@"Preview Error"
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:@"Dismiss"
                                                             otherButtonTitles:@"Email", nil];
            previewAlertView.tag = kPreviewTag;
            [previewAlertView show];
            
            self.invalidTorqueName = torque.name;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kPreviewTag) {
        if (buttonIndex == 1) {
            [[UECMailManager sharedManager] showComposer:^(MFMailComposeViewController *mailComposer) {
                NSString *subject = [[NSString alloc] initWithFormat:@"Error reading \"%@\" in the UEC app", self.invalidTorqueName];
                
                [mailComposer setToRecipients:@[@"webmaster@uec.org.au"]];
                [mailComposer setSubject:subject];
                [mailComposer setMessageBody:@"It may be due to a corrupt file or sending down a wrong file. \n Thanks for checking it out." isHTML:NO];
            } inController:self];
            
            self.invalidTorqueName = nil;
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

#pragma mark - Reachability

- (void)reachability:(UECReachabilityManager *)reachabilityManager networkStatusHasChanged:(AFNetworkReachabilityStatus)networkStatus
{
    if (networkStatus == AFNetworkReachabilityStatusNotReachable) {
        [self stopDownloads:nil];
    }
}

@end
