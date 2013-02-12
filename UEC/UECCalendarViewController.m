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

#import "UECUniversalAppManager.h"
#import "APSDataManager.h"
#import "Event.h"

#import "NSArray+TableViewOrdering.h"
#import "NSDate+Formatter.h"

@interface UECCalendarViewController () <UECMonthViewControllerDelegate, UECCalendarListViewController>
// Segmented control to switch view controllers
@property (strong, nonatomic) UISegmentedControl *eventsDisplaySegmentControl;
// Array of view controllers to switch between
@property (copy, nonatomic) NSArray *allViewControllers;
// Currently selected view controller
@property (strong, nonatomic) UIViewController *currentViewController;
@end

static NSInteger kMonthsDisplay = 0;

@implementation UECCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self setupSegmentControl];
    
    UIStoryboard *calendarStoryboard = [[UECUniversalAppManager sharedManager] deviceStroyboardFromTitle:@"Calendar"];
    UECMonthViewController *monthsVC = [calendarStoryboard instantiateViewControllerWithIdentifier:@"UECMonthViewController"];
    monthsVC.delegate = self;
    UECEventsListViewController *eventsListVC = [calendarStoryboard instantiateViewControllerWithIdentifier:@"UECEventsListViewController"];
    eventsListVC.delegate = self;
    UECTicketsViewController *ticketsVC = [calendarStoryboard instantiateViewControllerWithIdentifier:@"UECTicketsViewController"];
    ticketsVC.delegate = self;
    
    // Add the view controllers to the array
    self.allViewControllers = @[monthsVC, eventsListVC, ticketsVC];
    
    // Ensure a view controller is loaded
    self.eventsDisplaySegmentControl.selectedSegmentIndex = kMonthsDisplay;
    [self cycleFromViewController:self.currentViewController
                 toViewController:self.allViewControllers[self.eventsDisplaySegmentControl.selectedSegmentIndex]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data Refreshing

- (void)refreshDataWithHeaderKey:(NSString *)headerKey completion:(void (^)(NSArray *data, NSArray *sectionNames))completionBlock
{
    [[APSDataManager sharedManager] getDataForEntityName:@"Event" coreDataCompletion:^(NSArray *cachedObjects) {
        [self reloadDataWithNewObjects:cachedObjects withHeaderKey:headerKey completion:completionBlock];
    } downloadCompletion:^(BOOL needsReloading, NSArray *downloadedObjects) {
        if (needsReloading) {
        [self reloadDataWithNewObjects:downloadedObjects withHeaderKey:headerKey completion:completionBlock];
        }
    }];
}

- (void)reloadDataWithNewObjects:(NSArray *)newObjects
                   withHeaderKey:(NSString *)headerKey
                      completion:(void (^)(NSArray *data, NSArray *sectionNames))completionBlock
{
    if (newObjects.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else {
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:headerKey ascending:YES];
        NSArray *events = [newObjects sectionedArrayWithSplittingKey:headerKey withSortDescriptor:@[sortDescriptor]];
        NSArray *sectionHeaders = [events sectionHeaderObjectsForKey:headerKey sectionedArray:YES];
        
        NSMutableArray *sectionNames = [[NSMutableArray alloc] initWithCapacity:[sectionHeaders count]];
        for (NSDate *date in sectionHeaders)
            [sectionNames addObject:[date stringValue]];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (completionBlock) {
            completionBlock(events, sectionNames);
        }
    }
}
#pragma mark - Segment Control Setup

- (void)setupSegmentControl
{
    self.eventsDisplaySegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Month", @"List", @"Tickets"]];
    [self.eventsDisplaySegmentControl addTarget:self
                                         action:@selector(indexDidChangeForSegmentedControl:)
                               forControlEvents:UIControlEventValueChanged];
    self.eventsDisplaySegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.eventsDisplaySegmentControl setTintColor:[UIColor darkGrayColor]];
    
    // Setting the width to be a bit bigger.
    CGRect frame = self.eventsDisplaySegmentControl.frame;
    frame.size = CGSizeMake(200.0, frame.size.height);
    self.eventsDisplaySegmentControl.frame = frame;
    
    [[self navigationItem] setTitleView:self.eventsDisplaySegmentControl];
}


#pragma mark - View controller switching and saving

- (void)cycleFromViewController:(UIViewController *)oldVC toViewController:(UIViewController *)newVC
{
    // Do nothing if we are attempting to swap to the same view controller
    if (newVC == oldVC)
        return;
    
    // Check the newVC is non-nil otherwise expect a crash: NSInvalidArgumentException
    if (newVC) {
        // Set the new view controller frame
        [self setContainerFrame:newVC forDevice:[UIDevice currentDevice]];
        // Check the oldVC is non-nil otherwise expect a crash: NSInvalidArgumentException
        if (oldVC) {
            // Start both the view controller transitions
            [oldVC willMoveToParentViewController:nil];
            [self addChildViewController:newVC];
            // Swap the view controllers
            // No frame animations in this code but these would go in the animations block
            [self transitionFromViewController:oldVC
                              toViewController:newVC
                                      duration:0.3
                                       options:UIViewAnimationOptionLayoutSubviews
                                    animations:nil
                                    completion:^(BOOL finished) {
                                        // Finish both the view controller transitions
                                        [oldVC removeFromParentViewController];
                                        [newVC didMoveToParentViewController:self];
                                        // Store a reference to the current controller
                                        self.currentViewController = newVC;
                                    }];
        } else {
            // Otherwise we are adding a view controller for the first time
            // Start the view controller transition
            [self addChildViewController:newVC];
            // Add the new view controller view to the ciew hierarchy
            [self.view addSubview:newVC.view];
            // End the view controller transition
            [newVC didMoveToParentViewController:self];
            // Store a reference to the current controller
            self.currentViewController = newVC;
        }
    }
}

- (void)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender
{    
    NSUInteger index = sender.selectedSegmentIndex;
    
    if (UISegmentedControlNoSegment != index) {
        UIViewController *incomingViewController = [self.allViewControllers objectAtIndex:index];
        [self cycleFromViewController:self.currentViewController
                     toViewController:incomingViewController];
    }
}

#pragma mark - Rotation

- (void)setContainerFrame:(UIViewController *)containerVC forDevice:(UIDevice *)device
{
    if (device.orientation == UIInterfaceOrientationPortraitUpsideDown)
        return;
    
//    CGRect bounds = [UIScreen mainScreen].bounds;
//    
//    if (UIInterfaceOrientationIsLandscape(device.orientation))
//        bounds.size = CGSizeMake(bounds.size.height, bounds.size.width);
//    
//    containerVC.view.frame = bounds;
//    containerVC.view.frame = self.view.bounds;
    
    NSLayoutConstraint *wConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:containerVC.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:containerVC.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];

    [containerVC.view removeConstraints:containerVC.view.constraints];
    [containerVC.view addConstraints:@[wConstraint, hConstraint]];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification
{    
    UIDevice *device = [notification object];
    [self setContainerFrame:self.currentViewController forDevice:device];
}

#pragma mark - Touched Evvent Delegate

- (void)didSelectEvent:(Event *)event
{
    
}

- (void)didRefreshDataWithHeaderKey:(NSString *)headerKey completion:(void (^)(NSArray *, NSArray *))completionBlock
{
    [self refreshDataWithHeaderKey:headerKey completion:completionBlock];
}

@end
