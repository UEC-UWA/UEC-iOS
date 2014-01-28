//
//  UECMailManager.m
//  UEC
//
//  Created by Jad Osseiran on 13/10/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECMailManager.h"

@interface UECMailManager () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) id controller;

@end

@implementation UECMailManager

+ (instancetype)sharedManager
{
    static __DISPATCH_ONCE__ id singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
}

- (void)showComposer:(void (^)(MFMailComposeViewController *mailComposer))composerBlock
        inController:(id)controller
{
    self.controller = controller;
    
    // Create a mail modal view.
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    mailComposer.view.tintColor = UEC_BLACK;
    
    if (composerBlock) {
        composerBlock(mailComposer);
    }
    
    // Present the modal view.
    [controller presentViewController:mailComposer animated:YES completion:nil];
}

/*
 Delegate method alerting when the email has finished.
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
    if (error) {
        [error handle];
    }
    
	[self.controller becomeFirstResponder];
    [self.controller dismissViewControllerAnimated:YES completion:nil];
}

@end
