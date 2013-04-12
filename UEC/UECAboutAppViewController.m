//
//  UECAboutAppViewController.m
//  UEC
//
//  Created by Jad Osseiran on 12/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "UECAboutAppViewController.h"

#import "UECVersionInfoViewController.h"

@interface UECAboutAppViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation UECAboutAppViewController 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"About The App";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"UECVersionInfoViewController"] animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }];
    }
    
    if (indexPath.section == 1) {
        // Create a mail modal view.
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        
        [mailComposer setToRecipients:@[@"jad6@icloud.com"]];
        [mailComposer setSubject:@"UEC iOS app feedback"];
        [mailComposer setMessageBody:@"Hey Jad, \n\n Here is my feedback:" isHTML:NO];
        
        // Present the modal view.
        [self presentViewController:mailComposer animated:YES completion:^{
            
        }];
    }
}

/*
 Delegate method alerting when the email has finished.
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
	[self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
