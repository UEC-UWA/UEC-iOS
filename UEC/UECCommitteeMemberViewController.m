//
//  UECCommitteeMemberViewController.m
//  UEC
//
//  Created by Jad Osseiran on 16/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "UECCommitteeMemberViewController.h"

#import "UECMediaCaptureManager.h"
#import "UECMailManager.h"

#import "Person.h"

@interface UECCommitteeMemberViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel, *positionLabel, *subcommitteeLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;

@end

@implementation UECCommitteeMemberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    if (!self.person)
        return;
    
    NSString *fullName = [[NSString alloc] initWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
    self.title = fullName;
    
    self.nameLabel.text = fullName;
    self.positionLabel.text = self.person.position;
    self.subcommitteeLabel.text = self.person.subcommittee;
    self.summaryTextView.text = self.person.summary;
    
    self.emailCell.detailTextLabel.text = self.person.email;
    
    if ([self.person.subcommittee isEqualToString:@"Thebse"]) {
        UIBarButtonItem *phantomBarbuttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Phantom" style:UIBarButtonItemStyleDone target:self action:@selector(phantom:)];
        
        self.navigationItem.rightBarButtonItem = phantomBarbuttonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self.pictureImageView setImageWithURL:[[NSURL alloc] initWithString:self.person.photoPath]
                          placeholderImage:[UIImage imageNamed:@"gentleman.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     
                                 }];
    
    self.pictureImageView.layer.cornerRadius = 5;
    self.pictureImageView.layer.masksToBounds = YES;
}

#pragma mark - Setters

- (void)setPerson:(Person *)person
{
    if (_person != person) {
        _person = person;
        self.person = person;
    }
    
    [self configureView];
}

#pragma mark - Table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self.summaryTextView sizeToFit];
        return self.summaryTextView.frame.size.height + 3.0;
    }
    
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.emailCell isEqual:[tableView cellForRowAtIndexPath:indexPath]]) {
        [[UECMailManager sharedManager] showComposer:^(MFMailComposeViewController *mailComposer) {
            [mailComposer setToRecipients:@[self.person.email]];
        } inController:self];
    }
}

#pragma mark - Phantom

- (void)phantom:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Send a Phantom to your lovely Thebses." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"I Just Need Words Thanks", nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[UECMediaCaptureManager sharedManager] launchCameraInController:self];
            break;
            
        case 1:
            [[UECMediaCaptureManager sharedManager] launchCameraRollPickerInController:self];
            break;
            
        case 2:
            
            [[UECMailManager sharedManager] showComposer:^(MFMailComposeViewController *mailComposer) {
                [mailComposer setToRecipients:@[@"thebse@uec.org.au"]];
                [mailComposer setSubject:@"Written Phantom"];
                [mailComposer setMessageBody:@"UEC iOS app Phantom." isHTML:NO];
            } inController:self];
            break;
            
        default:
            break;
    }
}

@end
