//
//  UECReachabilityManager.h
//  UEC
//
//  Created by Jad Osseiran on 2/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import Foundation;

#import "AFNetworkReachabilityManager.h"

@class UECReachabilityManager;
@protocol UECReachabilityManagerDelegate <NSObject>
- (void)reachability:(UECReachabilityManager *)reachabilityManager networkStatusHasChanged:(AFNetworkReachabilityStatus)networkStatus;
@end

@interface UECReachabilityManager : NSObject

@property (weak, nonatomic) id<UECReachabilityManagerDelegate> delegate;

@property (nonatomic) AFNetworkReachabilityStatus networkStatus;

+ (instancetype)sharedManager;
+ (instancetype)sharedManagerWithDelegate:(id)delegate;

- (void)handleReachabilityAlertOnRefresh:(BOOL)refresh;
- (void)handleReachbilityAlertViewWithBlock:(void (^)(UIAlertView *reachbilityAlertView))alertViewBlock onRefresh:(BOOL)refresh;

- (void)resetAlerts;

@end
