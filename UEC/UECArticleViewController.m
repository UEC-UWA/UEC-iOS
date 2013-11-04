//
//  UECArticleViewController.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECArticleViewController.h"

#import "NewsArticle.h"

@interface UECArticleViewController ()

@property (strong, nonatomic) UIPopoverController *activityPopoverController;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UECArticleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
