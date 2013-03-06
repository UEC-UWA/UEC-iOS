//
//  UECAboutViewController.m
//  UEC
//
//  Created by Jad Osseiran on 20/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "UECAboutViewController.h"

#import "APSDataManager.h"
#import "UECReachabilityManager.h"
#import "UECAlertManager.h"

#import "UECPreviewItem.h"

#import "Sponsor.h"

@interface UECAboutViewController () <QLPreviewControllerDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UECPreviewItem *aboutPreview;

@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property (nonatomic) BOOL beganUpdates;

@end

static NSUInteger kNumSections = 3;

@implementation UECAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"About";
    
    [[APSDataManager sharedManager] cacheEntityName:@"Sponsor" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:NO];
        }
    }];
    
    self.fetchedResultsController = [[APSDataManager sharedManager] fetchedResultsControllerWithRequest:^(NSFetchRequest *request) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        request.sortDescriptors = @[sortDescriptor];
    } entityName:@"Sponsor" sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2)
        return @"Sponsors";
    else
        return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return kNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
        case 1:
            return 1;
            break;
            
        case 2:
            return [self.fetchedResultsController.fetchedObjects count];
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"About Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"About The UEC";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case 1:
            cell.textLabel.text = @"About The App";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case 2: {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            Sponsor *sponsor = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                                  inSection:0]];
            cell.textLabel.text = sponsor.name;
            
            [cell.imageView setImageWithURL:[[NSURL alloc] initWithString:sponsor.logoPath] placeholderImage:[UIImage imageNamed:@"gentleman.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
            }];
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == 0) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = activityIndicator;
        
        [self downloadAboutUECFile:^(NSURL *localURL) {
            cell.accessoryView = nil;
            
            self.aboutPreview = [[UECPreviewItem alloc] init];
            self.aboutPreview.localURL = localURL;
            self.aboutPreview.documentTitle = @"About the UEC";
            
            if ([QLPreviewController canPreviewItem:self.aboutPreview]) {
                QLPreviewController *quickLookC = [[QLPreviewController alloc] init];
                quickLookC.dataSource = self;
                [self.navigationController pushViewController:quickLookC animated:YES];
            } else {
                [[UECAlertManager sharedManager] showPreviewAlertForFileName:@"About the UEC" inController:self];
            }
        }];
    }
    
    if (indexPath.section == 2) {
        Sponsor *sponsor = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                               inSection:0]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sponsor.websitePath]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Downloading

- (BOOL)needsDownloadingWithLastUpdate:(NSDate *)lastUpdate
                            atFilePath:(NSString *)filePath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDownload = [userDefaults objectForKey:@"lastDownloadAboutUEC"];
    
    // if lastDownload is later than lastUpdate no need to download.
    if ([lastDownload compare:lastUpdate] == NSOrderedDescending &&
        [[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return NO;
    
    lastDownload = [NSDate date];
    [userDefaults setObject:lastDownload forKey:@"lastDownloadAboutUEC"];
    [userDefaults synchronize];
    
    return YES;
}

- (void)downloadAboutUECFile:(void (^)(NSURL *localURL))completionBlock;
{
    NSDictionary *aboutUEC = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DummyAboutUEC" ofType:@"plist"]];
    
    NSString *fileAddress = aboutUEC[@"url"];
    NSDate *lastUpdate = aboutUEC[@"last_update"];
#if LOCAL_DATA

#else
//    NSDictionary *serverConnections = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServerConnections" ofType:@"plist"]];
//    NSString *serverAddress = serverConnections[@"AboutUEC"];
//    
//    // Handle the JSON response here.
//    NSDictionary *aboutUEC =
#endif
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [[fileAddress pathComponents] lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
    if ([self needsDownloadingWithLastUpdate:lastUpdate atFilePath:filePath]) {
        [[APSDataManager sharedManager] downloadFileAtURL:[[NSURL alloc] initWithString:fileAddress] intoFilePath:filePath completion:completionBlock];
    } else {
        if (completionBlock) {
            completionBlock([[NSURL alloc] initFileURLWithPath:filePath]);
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
    return self.aboutPreview;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:2];
    newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:2];
    
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

@end
