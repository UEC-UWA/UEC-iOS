//
//  UECSegmentChildrenViewController.m
//  UEC
//
//  Created by Jad Osseiran on 6/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECSegmentChildrenViewController.h"

@interface UECSegmentChildrenViewController ()

// Segmented control to switch view controllers
@property (strong, nonatomic) UISegmentedControl *eventsDisplaySegmentControl;

@end

@implementation UECSegmentChildrenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Segment Control Setup

- (void)setupSegmentControlWithItems:(NSArray *)items
{
    self.eventsDisplaySegmentControl = [[UISegmentedControl alloc] initWithItems:items];
    [self.eventsDisplaySegmentControl addTarget:self
                                         action:@selector(indexDidChangeForSegmentedControl:)
                               forControlEvents:UIControlEventValueChanged];
    self.eventsDisplaySegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.eventsDisplaySegmentControl setTintColor:[UIColor darkGrayColor]];
    
//    // Setting the width to be a bit bigger.
//    CGRect frame = self.eventsDisplaySegmentControl.frame;
//    frame.size = CGSizeMake(200.0, frame.size.height);
//    self.eventsDisplaySegmentControl.frame = frame;
    
    [[self navigationItem] setTitleView:self.eventsDisplaySegmentControl];
    
    // Ensure a view controller is loaded
    self.eventsDisplaySegmentControl.selectedSegmentIndex = 0;
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
        
        // Set the new view controller frame
        [self setContainerFrame:newVC forDevice:[UIDevice currentDevice]];
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
    if (device.orientation == UIInterfaceOrientationPortraitUpsideDown &&
        [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return;
    
    [containerVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:containerVC.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *con2 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:containerVC.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *con3 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:0 toItem:containerVC.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint *con4 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:0 toItem:containerVC.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    NSArray *constraints = @[con1, con2, con3, con4];
    
    [self.view addConstraints:constraints];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification
{
    UIDevice *device = [notification object];
    [self setContainerFrame:self.currentViewController forDevice:device];
}

@end
