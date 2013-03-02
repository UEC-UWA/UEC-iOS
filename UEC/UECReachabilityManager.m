//
//  UECReachabilityManager.m
//  UEC
//
//  Created by Jad Osseiran on 2/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIAlertView.h>

#import "UECReachabilityManager.h"

@interface UECReachabilityManager () <UIAlertViewDelegate>

@property (nonatomic) BOOL shouldShowAlert;

@end

static NSInteger kReachbilityAlertViewTag = 66;

@implementation UECReachabilityManager

+ (UECReachabilityManager *)sharedManager
{
    static __DISPATCH_ONCE__ UECReachabilityManager *singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        singletonObject.shouldShowAlert = YES;
    });
    
    return singletonObject;
}

- (void)handleReachabilityAlertOnRefresh:(BOOL)refresh
{
    [self handleReachbilityAlertViewWithBlock:nil onRefresh:refresh];
}

- (void)handleReachbilityAlertViewWithBlock:(void (^)(UIAlertView *reachbilityAlertView))alertViewBlock onRefresh:(BOOL)refresh
{
    if (!(self.shouldShowAlert || refresh))
        return;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
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

- (void)resetAlerts
{
    self.shouldShowAlert = YES;
}

#pragma mark - Alert view delegate

@end
