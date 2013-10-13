//
//  UECAlertManager.h
//  UEC
//
//  Created by Jad Osseiran on 4/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UECAlertManager : NSObject

+ (instancetype)sharedManager;

- (void)showPreviewAlertForFileName:(NSString *)fileName inController:(UIViewController *)controller;

@end
