//
//  UECCommitteeMemberViewController.m
//  UEC
//
//  Created by Jad Osseiran on 16/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import "UECCommitteeMemberViewController.h"

#import "Person.h"

@interface UECCommitteeMemberViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel, *positionLabel, *subcommitteeLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (strong, nonatomic) IBOutlet UITextView *summaryTextView;

@property (nonatomic) BOOL pickedFromPicker;

@end

@implementation UECCommitteeMemberViewController

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

    NSString *fullName = [[NSString alloc] initWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
    self.title = fullName;
    self.nameLabel.text = fullName;
    self.positionLabel.text = self.person.position;
    self.subcommitteeLabel.text = self.person.subcommittee;
    
    self.emailCell.detailTextLabel.text = self.person.email;
    
    if ([self.person.subcommittee isEqualToString:@"Thebse"]) {
        UIBarButtonItem *phantomBarbuttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Phantom" style:UIBarButtonItemStyleBordered target:self action:@selector(phantom:)];
        phantomBarbuttonItem.tintColor = [UIColor darkGrayColor];
        
        self.navigationItem.rightBarButtonItem = phantomBarbuttonItem;
    }
    
    [self.pictureImageView setImageWithURL:[[NSURL alloc] initWithString:self.person.photoPath]
                          placeholderImage:[UIImage imageNamed:@"gentleman.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     
                                 }];
    self.pictureImageView.layer.cornerRadius = 5;
    self.pictureImageView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Email

- (void)sendEmail:(void (^)(MFMailComposeViewController *mailComposer))mailComposerBlock
{
    // Create a mail modal view.
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    if (mailComposerBlock) {
        mailComposerBlock(mailComposer);
    }
	// Present the modal view.
    [self presentViewController:mailComposer animated:YES completion:^{
        
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.emailCell isEqual:[tableView cellForRowAtIndexPath:indexPath]]) {
        [self sendEmail:^(MFMailComposeViewController *mailComposer) {
            [mailComposer setToRecipients:@[self.person.email]];
        }];
    }
}

#pragma mark - Phantom

- (void)phantom:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Send a Phantom to your lovely Thebses." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"I Just Need Words Thanks", nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
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


- (void)launchCamera
{
    if (![self startCameraController]) {
        self.pickedFromPicker = NO;
        
        UIAlertView *noCameraAlertView = [[UIAlertView alloc] initWithTitle:@"No Camera"
                                                                    message:@"Your device does not appear to have a camera."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [noCameraAlertView show];
    }
}

- (void)launchCameraRollPicker
{
    if (![self startMediaBrowser]) {
        self.pickedFromPicker = YES;

        UIAlertView *noMedia = [[UIAlertView alloc] initWithTitle:@"No Media"
                                                          message:@"Your device does not appear to have any images in its Camera roll."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [noMedia show];
    }
}

#pragma mark - Camera

- (BOOL)startCameraController
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:^{
        
    }];
    return YES;
}

#pragma mark - Camera roll picker

- (BOOL)startMediaBrowser
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:^{
        
    }];
    return YES;
}

#pragma mark - Image picker delegate

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *image = nil;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        image = (UIImage *)info[UIImagePickerControllerOriginalImage];
        
        // Save the new image (original or edited) to the Camera Roll
        if (!self.pickedFromPicker)
            UIImageWriteToSavedPhotosAlbum(image, nil, nil , nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self sendEmail:^(MFMailComposeViewController *mailComposer) {
            [mailComposer setToRecipients:@[@"thebse@uec.org.au"]];
            [mailComposer setSubject:@"Photo Phantom"];
            [mailComposer addAttachmentData:UIImageJPEGRepresentation(image, 1.0)
                                   mimeType:@"image/jpg"
                                   fileName:@"Phantom.jpg"];
            [mailComposer setMessageBody:@"UEC iOS app Phantom." isHTML:NO];
        }];
    }];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self launchCamera];
            break;
            
        case 1:
            [self launchCameraRollPicker];
            break;
            
        case 2:
            [self sendEmail:^(MFMailComposeViewController *mailComposer) {
                [mailComposer setToRecipients:@[@"thebse@uec.org.au"]];
                [mailComposer setSubject:@"Written Phantom"];
                [mailComposer setMessageBody:@"UEC iOS app Phantom." isHTML:NO];
            }];
            break;
            
        default:
            break;
    }
}

@end