//
//  UECAppDelegate.m
//  UEC
//
//  Created by Jad Osseiran on 6/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECAppDelegate.h"

#import "UECUniversalAppManager.h"

@implementation UECAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard *mainStroyboard = [[UECUniversalAppManager sharedManager] deviceStroyboardFromTitle:@"Main"];
    UITabBarController *tabBarController = [mainStroyboard instantiateInitialViewController];
    
    NSArray *tabBarItems = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TabBarItems" ofType:@"plist"]];
    NSMutableArray *tabBarVCs = [[NSMutableArray alloc] initWithCapacity:tabBarItems.count];
    
    for (NSString *tabBarItemTitle in tabBarItems) {
        UIViewController *viewController = [[[UECUniversalAppManager sharedManager] deviceStroyboardFromTitle:tabBarItemTitle] instantiateInitialViewController];
        UINavigationController *tabBarItem = [[UINavigationController alloc] initWithRootViewController:viewController];
        tabBarItem.title = tabBarItemTitle;
        tabBarItem.topViewController.title = tabBarItemTitle;
        
        [tabBarVCs addObject:tabBarItem];
    }
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:(249.0/255.0) green:(217.0/255.0) blue:(30.0/255.0) alpha:1.0]];
    NSDictionary *attributes = @{UITextAttributeTextColor: [UIColor blackColor], UITextAttributeTextShadowColor : [UIColor clearColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    [tabBarController setViewControllers:tabBarVCs];
    
    [self.window setRootViewController:tabBarController];
    
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

@end
