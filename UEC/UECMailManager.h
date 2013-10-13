//
//  UECMailManager.h
//  UEC
//
//  Created by Jad Osseiran on 13/10/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface UECMailManager : NSObject

+ (instancetype)sharedManager;

- (void)showComposer:(void (^)(MFMailComposeViewController *mailComposer))composerBlock
        inController:(id)controller;


@end
