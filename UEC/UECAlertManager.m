//
//  UECAlertManager.m
//  UEC
//
//  Created by Jad Osseiran on 4/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIAlertView.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "UECAlertManager.h"

@interface UECAlertManager () <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) UIViewController *viewController;

@end

static NSInteger kPreviewTag = 100;

@implementation UECAlertManager

+ (UECAlertManager *)sharedManager
{
    static __DISPATCH_ONCE__ UECAlertManager *singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
}

- (void)showPreviewAlertForFileName:(NSString *)fileName inController:(UIViewController *)controller
{
    self.viewController = controller;
    self.fileName = fileName;
    
    NSString *message = [[NSString alloc] initWithFormat:@"Cannot open %@. The file is probably corrupt. Please send an email to report this problem", self.fileName];
    UIAlertView *previewAlertView = [[UIAlertView alloc] initWithTitle:@"Preview Error" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Email", nil];
    
    previewAlertView.tag = kPreviewTag;
    
    [previewAlertView show];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kPreviewTag) {
        if (buttonIndex == 1) {
            [self sendEmail];
        }
    }
}

#pragma mark - Email

- (void)sendEmail
{    
    // Create a mail modal view.
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    NSString *subject = [[NSString alloc] initWithFormat:@"Error reading \"%@\" in the UEC app", self.fileName];
    
    [mailComposer setToRecipients:@[@"webmaster@uec.org.au"]];
    [mailComposer setSubject:subject];
    [mailComposer setMessageBody:@"It may be due to a corrupt file or sending down a wrong file. \n Thanks for checking it out." isHTML:NO];
    
	// Present the modal view.
    [self.viewController presentViewController:mailComposer animated:YES completion:^{
        
    }];
}

/*
 Delegate method alerting when the email has finished.
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
	[self.viewController becomeFirstResponder];
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
