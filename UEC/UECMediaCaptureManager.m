//
//  UECMediaCaptureManager.m
//  UEC
//
//  Created by Jad Osseiran on 13/10/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECMediaCaptureManager.h"

#import "UECMailManager.h"

@interface UECMediaCaptureManager () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) id controller;

@property (strong, nonatomic) UIPopoverController *imagePickerpopover;

@property (nonatomic) BOOL pickedFromPicker;

@end

@implementation UECMediaCaptureManager

+ (instancetype)sharedManager
{
    static __DISPATCH_ONCE__ id singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
}

- (void)launchCameraInController:(id)controller
{
    self.pickedFromPicker = NO;
    self.controller = controller;
    
    if (![self startCameraController]) {
        UIAlertView *noCameraAlertView = [[UIAlertView alloc] initWithTitle:@"No Camera"
                                                                    message:@"Your device does not appear to have a camera."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
        [noCameraAlertView show];
    }
}

- (void)launchCameraRollPickerInController:(id)controller
{
    self.controller = controller;
    self.pickedFromPicker = YES;

    if (![self startMediaBrowser]) {
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
    
    [self.controller presentViewController:cameraUI animated:YES completion:nil];
    
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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.imagePickerpopover.popoverVisible) {
            [self.imagePickerpopover dismissPopoverAnimated:YES];
        } else {
            NSDictionary *navAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
            [[UINavigationBar appearance] setTitleTextAttributes:navAttributes];
            
            self.imagePickerpopover = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
            
            
            [self.imagePickerpopover presentPopoverFromBarButtonItem:[[self.controller navigationItem] rightBarButtonItem] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        [self.controller presentViewController:mediaUI animated:YES completion:nil];
    }
    
    return YES;
}

#pragma mark - Image picker delegate

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDictionary *navAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:navAttributes];
    } else {
        [self.controller dismissViewControllerAnimated:YES completion:nil];
    }
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
    
    [self.controller dismissViewControllerAnimated:YES completion:^{
        [[UECMailManager sharedManager] showComposer:^(MFMailComposeViewController *mailComposer) {
            [mailComposer setToRecipients:@[@"thebse@uec.org.au"]];
            [mailComposer setSubject:@"Photo Phantom"];
            [mailComposer addAttachmentData:UIImageJPEGRepresentation(image, 1.0)
                                   mimeType:@"image/jpg"
                                   fileName:@"Phantom.jpg"];
            [mailComposer setMessageBody:@"UEC iOS app Phantom." isHTML:NO];
        } inController:self.controller];
    }];
}

@end
