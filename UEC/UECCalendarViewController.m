//
//  UECCalendarViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECCalendarViewController.h"

#import "UECMonthViewController.h"
#import "UECEventsListViewController.h"

#import "UECUniversalAppManager.h"

@interface UECCalendarViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
// Segmented control to switch view controllers
@property (weak, nonatomic) IBOutlet UISegmentedControl *eventsDisplaySegmentControl;
// Array of view controllers to switch between
@property (nonatomic, copy) NSArray *allViewControllers;
// Currently selected view controller
@property (strong, nonatomic) UIViewController *currentViewController;
@end

static NSInteger kMonthsDisplay = 0;

@implementation UECCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIStoryboard *calendarStoryboard = [[UECUniversalAppManager sharedManager] deviceStroyboardFromTitle:@"Calendar"];
    UECMonthViewController *monthsVC = [calendarStoryboard instantiateViewControllerWithIdentifier:@"UECMonthViewController"];
    UECEventsListViewController *eventsListVC = [calendarStoryboard instantiateViewControllerWithIdentifier:@"UECEventsListViewController"];
    
    // Add the view controllers to the array
    self.allViewControllers = @[monthsVC, eventsListVC];
    
    // Ensure a view controller is loaded
    self.eventsDisplaySegmentControl.selectedSegmentIndex = kMonthsDisplay;
    [self cycleFromViewController:self.currentViewController
                 toViewController:self.allViewControllers[self.eventsDisplaySegmentControl.selectedSegmentIndex]];
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
        CGRect frame = self.view.frame;
        frame.origin.y += self.toolbar.frame.size.height;
        frame.size.height -= self.toolbar.frame.size.height;
        newVC.view.frame = frame;
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

- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender
{    
    NSUInteger index = sender.selectedSegmentIndex;
    
    if (UISegmentedControlNoSegment != index) {
        UIViewController *incomingViewController = [self.allViewControllers objectAtIndex:index];
        [self cycleFromViewController:self.currentViewController toViewController:incomingViewController];
    }
}


@end
