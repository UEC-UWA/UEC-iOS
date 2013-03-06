//
//  UECTorquePreviewController.m
//  UEC
//
//  Created by Jad Osseiran on 6/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECTorquePreviewController.h"

@interface UECTorquePreviewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation UECTorquePreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.splitViewController.presentsWithGesture = YES;
    self.splitViewController.delegate = self;
}

#pragma mark - Split view

- (void)showMaster:(id)sender
{
    
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"News";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
