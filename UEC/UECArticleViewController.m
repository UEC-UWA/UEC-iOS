//
//  UECArticleViewController.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>

#import "UECArticleViewController.h"

#import "NewsArticle.h"

@interface UECArticleViewController () <UIWebViewDelegate, UIAlertViewDelegate, NJKWebViewProgressDelegate>

@property (strong, nonatomic) UIPopoverController *activityPopoverController;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NJKWebViewProgress *progressProxy;
@property (strong, nonatomic) NJKWebViewProgressView *progressView;

@property (strong, nonatomic) NSURL *clikcedURL;

@end

@implementation UECArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)]];

    self.title = self.newsArticle.title;

    [self setupProgressView];

    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;

    NSURL *URL = [NSURL URLWithString:self.newsArticle.link];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (void)setupProgressView {
    CGFloat progressBarHeight = 2.5f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.progressView.progressBarView.backgroundColor = UEC_BLACK;
}

#pragma mark - Actions

- (void)share:(id)sender {
    NSArray *items = @[ self.newsArticle.link ];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];

    activityVC.excludedActivityTypes = @[ UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll ];

    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@" activityType: %@", activityType);
        NSLog(@" completed: %i", completed);
    };

    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Link Alert

- (void)showLinkAlert {
    UIAlertView *linkAV = [[UIAlertView alloc] initWithTitle:@"Opening Link" message:@"You are about to navigate to a new page. Would you like to exit the app and open Safari?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [linkAV show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:self.clikcedURL];
    }
}

#pragma mark - UIWebView

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress;
{
    [self.progressView setProgress:progress animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *requestURL = [request URL];
    if (navigationType == UIWebViewNavigationTypeLinkClicked &&
        [[UIApplication sharedApplication] canOpenURL:requestURL]) {
        self.clikcedURL = requestURL;
        [self showLinkAlert];

        return NO;
    }

    return YES;
}

@end
