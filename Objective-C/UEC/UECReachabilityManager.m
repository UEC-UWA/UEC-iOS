//
//  UECReachabilityManager.m
//  UEC
//
//  Created by Jad Osseiran on 2/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import UIKit;

#import "UECReachabilityManager.h"

@interface UECReachabilityManager () <UIAlertViewDelegate>

@property (nonatomic) BOOL shouldShowAlert;

@end

@implementation UECReachabilityManager

+ (instancetype)sharedManager {
    return [UECReachabilityManager sharedManagerWithDelegate:nil];
}

+ (instancetype)sharedManagerWithDelegate:(id)delegate;
{
    static __DISPATCH_ONCE__ UECReachabilityManager *singletonObject = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        singletonObject.shouldShowAlert = YES;
        singletonObject.delegate = delegate;
    });

    return singletonObject;
}

- (void)setNetworkStatus:(AFNetworkReachabilityStatus)networkStatus {
    if (_networkStatus != networkStatus) {
        _networkStatus = networkStatus;
        self.networkStatus = networkStatus;
    }

    [self.delegate reachability:self networkStatusHasChanged:self.networkStatus];
}

- (void)handleReachabilityAlertOnRefresh:(BOOL)refresh {
    [self handleReachbilityAlertViewWithBlock:nil onRefresh:refresh];
}

- (void)handleReachbilityAlertViewWithBlock:(void (^)(UIAlertView *reachbilityAlertView))alertViewBlock onRefresh:(BOOL)refresh {
    if (!(self.shouldShowAlert || refresh))
        return;

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NO_INTERNET_TITLE", @"No Internet Alertview Title")
                                                        message:@"You are not connected to the Internet. The app is using cached data."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    if (alertViewBlock) {
        alertViewBlock(alertView);
    }

    [alertView show];

    self.shouldShowAlert = NO;
}

- (void)resetAlerts {
    self.shouldShowAlert = YES;
}

@end
