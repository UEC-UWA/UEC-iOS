//
//  UECArticleViewController.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECArticleViewController.h"

#import "NewsArticle.h"

@interface UECArticleViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController, *activityPopoverController;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UECArticleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.splitViewController.presentsWithGesture = YES;
    self.splitViewController.delegate = self;
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)]];
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View

- (void)configureView
{
    if (self.newsArticle) {
        self.title = self.newsArticle.title;
        [self.webView loadHTMLString:self.newsArticle.content baseURL:nil];
    }
}

#pragma mark - Setters

- (void)setNewsArticle:(NewsArticle *)newsArticle
{
    if (_newsArticle != newsArticle) {
        _newsArticle = newsArticle;
        self.newsArticle = newsArticle;
    }
    
    [self configureView];

    if (self.masterPopoverController) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - Actions

- (void)share:(id)sender
{
    NSArray *items = @[self.newsArticle.link];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll];
    
    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@" activityType: %@", activityType);
        NSLog(@" completed: %i", completed);
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.activityPopoverController.popoverVisible) {
            [self.activityPopoverController dismissPopoverAnimated:YES];
        } else {
            self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            
            [self.activityPopoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
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
