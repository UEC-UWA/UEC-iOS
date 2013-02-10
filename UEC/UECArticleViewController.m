//
//  UECArticleViewController.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECArticleViewController.h"

#import "UECActivity.h"

#import "NewsArticle.h"

@interface UECArticleViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UECArticleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = self.newsArticle.title;
    [self.webView loadHTMLString:self.newsArticle.content baseURL:nil];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)]];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor darkGrayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)share:(id)sender
{
    NSArray *items = @[self.newsArticle.link];
    
    UECActivity *activity = [[UECActivity alloc] init];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[activity]];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll];
    
    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@" activityType: %@", activityType);
        NSLog(@" completed: %i", completed);
    };
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
