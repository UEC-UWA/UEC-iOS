//
//  UECAppDelegate.m
//  UEC
//
//  Created by Jad Osseiran on 6/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECAppDelegate.h"

#import "UECReachabilityManager.h"

@interface UECAppDelegate ()

@property (strong, nonatomic) Reachability *internetReach;

@end

@implementation UECAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [[UINavigationBar appearance] setTintColor:UEC_YELLOW];
    NSDictionary *navAttributes = @{UITextAttributeTextColor: [UIColor blackColor], UITextAttributeTextShadowColor : [UIColor clearColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navAttributes];
    
    NSDictionary *barButtonAttributes = @{UITextAttributeTextColor: [UIColor whiteColor]};
    [[UIBarButtonItem appearance] setTintColor:[UIColor darkGrayColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonAttributes forState:UIControlStateHighlighted];
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    self.internetReach = [Reachability reachabilityForInternetConnection];
	[self.internetReach startNotifier];
    
    // Override point for customization after application launch.
    return YES;
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

- (void)reachabilityChanged:(NSNotification *)notification
{
	Reachability *curReach = [notification object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    [[UECReachabilityManager sharedManager] resetAlerts];
    
    NetworkStatus networkStatus = [curReach currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [[UECReachabilityManager sharedManager] handleReachabilityAlertOnRefresh:NO];
    }
}

@end
