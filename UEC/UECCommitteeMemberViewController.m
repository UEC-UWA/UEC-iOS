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

@property (nonatomic, weak) IBOutlet UIImageView *pictureImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel, *positionLabel, *subcommitteeLabel;
@property (nonatomic, weak) IBOutlet UITableViewCell *emailCell;
@property (nonatomic, weak) IBOutlet UITextView *summaryTextView;

@end

@implementation UECCommitteeMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // This is necessary as the table view will not capture the fact that it is in
    // landscape on viewDidLoad: and the dynamic cell resize will not work.
    // http://stackoverflow.com/questions/7631094/a-view-controller-is-in-landscape-mode-but-im-getting-the-frame-from-portrait
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View

- (void)configureView {
    if (!self.person)
        return;

    NSString *fullName = [[NSString alloc] initWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
    self.title = fullName;

    self.nameLabel.text = fullName;
    self.positionLabel.text = self.person.position;
    self.subcommitteeLabel.text = self.person.subcommittee;
    self.summaryTextView.text = self.person.summary;

    self.emailCell.detailTextLabel.text = self.person.email;

    if ([self.person.subcommittee isEqualToString:@"THEBSE"]) {
        UIBarButtonItem *phantomBarbuttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Phantom" style:UIBarButtonItemStyleDone target:self action:@selector(phantom:)];

        self.navigationItem.rightBarButtonItem = phantomBarbuttonItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }

    if (self.person.photoPath) {
        NSURL *imageURL = [[NSURL alloc] initWithString:self.person.photoPath];
        UIImage *placeHolderImage = [UIImage imageNamed:@"gentleman.png"];
        [self.pictureImageView sd_setImageWithURL:imageURL placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error != nil) {
                [error handle];
            }
        }];
    }

    self.pictureImageView.layer.cornerRadius = 5;
    self.pictureImageView.layer.masksToBounds = YES;
}

#pragma mark - Setters

- (void)setPerson:(Person *)person {
    if (_person != person) {
        _person = person;
        self.person = person;
    }

    [self configureView];
}

#pragma mark - Table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self.summaryTextView sizeToFit];
        return self.summaryTextView.frame.size.height + 3.0;
    }

    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.emailCell isEqual:[tableView cellForRowAtIndexPath:indexPath]]) {
        [[UECMailManager sharedManager] showComposer:^(MFMailComposeViewController *mailComposer) {
            [mailComposer setToRecipients:@[self.person.email]];
        } inController:self];
    }
}

#pragma mark - Phantom

- (void)phantom:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Send a Phantom to your lovely Thebses." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"I Just Need Words Thanks", nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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
