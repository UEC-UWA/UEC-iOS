//
//  UECCalendarViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import "UECCalendarViewController.h"

#import "UECMonthViewController.h"
#import "UECEventsListViewController.h"
#import "UECTicketsViewController.h"
#import "UECCalendarListViewController.h"

#import "APSDataManager.h"
#import "UECReachabilityManager.h"
#import "NSDate+Formatter.h"

#import "Event.h"


@interface UECCalendarViewController () <UECMonthViewControllerDelegate, UECCalendarListViewController>

@end

@implementation UECCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UECMonthViewController *monthsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECMonthViewController"];
    monthsVC.delegate = self;
    UECEventsListViewController *eventsListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECEventsListViewController"];
    eventsListVC.delegate = self;
    UECTicketsViewController *ticketsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECTicketsViewController"];
    ticketsVC.delegate = self;
    
    // Add the view controllers to the array
    self.allViewControllers = @[monthsVC, eventsListVC, ticketsVC];
    
    [self setupSegmentControlWithItems:@[@"Month", @"List", @"Tickets"]];
        
    [self refreshDataManually:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Data Refreshing

- (void)refreshDataManually:(BOOL)manualRefresh
{
    [self refreshDataManually:manualRefresh completion:nil];
}

- (void)refreshDataManually:(BOOL)manualRefresh completion:(void (^)(void))completionBlock
{
    [[APSDataManager sharedManager] cacheEntityName:@"Event" completion:^(BOOL internetReachable) {
        if (!internetReachable) {
            [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:manualRefresh];
        }
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - Touched Evvent Delegate

- (void)didSelectEvent:(Event *)event
{
    
}

- (void)didRequestDataOnManualRefresh:(BOOL)manualRefresh completion:(void (^)(void))completionBlock
{
    [self refreshDataManually:manualRefresh completion:completionBlock];
}

@end
