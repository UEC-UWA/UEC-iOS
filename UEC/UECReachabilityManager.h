//
//  UECReachabilityManager.h
//  UEC
//
//  Created by Jad Osseiran on 2/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Reachability.h"

@interface UECReachabilityManager : NSObject

+ (UECReachabilityManager *)sharedManager;

- (void)handleReachabilityAlertOnRefresh:(BOOL)refresh;
- (void)handleReachbilityAlertViewWithBlock:(void (^)(UIAlertView *reachbilityAlertView))alertViewBlock onRefresh:(BOOL)refresh;

- (void)resetAlerts;

@end
