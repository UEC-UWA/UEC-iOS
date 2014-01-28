//
//  UECAppDelegate.m
//  UEC
//
//  Created by Jad Osseiran on 6/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECAppDelegate.h"

#import "AFNetworking.h"

#import "UECReachabilityManager.h"

#import "TestFlight.h"

@interface UECAppDelegate ()

@end

@implementation UECAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.tintColor = UEC_BLACK;
    [UECThemeManager customiseAppAppearance];
    
    [TestFlight takeOff:@"06760142-99fc-4b04-b984-727e2fc54aaa"];
    
    [self handleReachability];
    
#if PUSH
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                    UIRemoteNotificationTypeAlert |
                                                    UIRemoteNotificationTypeSound];
#endif
    
    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSDictionary *serverPaths = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServerConnections" ofType:@"plist"]];
    NSURL *URL = [NSURL URLWithString:serverPaths[@"PushNotifications"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request
                                                               fromData:deviceToken
                                                               progress:nil
                                                      completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                          if (error) {
                                                              [error handle];
                                                          }
                                                      }];
    [uploadTask resume];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@", userInfo);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Reachability

- (void)handleReachability
{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        UECReachabilityManager *reachabilityManager = [UECReachabilityManager sharedManager];
        [reachabilityManager resetAlerts];
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [reachabilityManager handleReachabilityAlertOnRefresh:NO];
        }
        reachabilityManager.networkStatus = status;
    }];
    [reachabilityManager startMonitoring];
}

@end
