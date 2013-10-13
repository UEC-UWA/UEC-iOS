//
//  UECAboutAppViewController.m
//  UEC
//
//  Created by Jad Osseiran on 12/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECAboutAppViewController.h"

#import "UECVersionInfoViewController.h"

#import "UECMailManager.h"

@interface UECAboutAppViewController ()

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
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"UECVersionInfoNavController"] animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }];
    } else if (indexPath.section == 1) {
        [[UECMailManager sharedManager] showComposer:^(MFMailComposeViewController *mailComposer) {
            [mailComposer setToRecipients:@[@"jad6@icloud.com"]];
            [mailComposer setSubject:@"UEC iOS app feedback"];
            [mailComposer setMessageBody:@"Hey Jad, \n\n Here is my feedback:" isHTML:NO];
        } inController:self];
    }
}

@end
