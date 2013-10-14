//
//  UECThemeManager.m
//  UEC
//
//  Created by Jad Osseiran on 13/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECThemeManager.h"

#import "UECThemeResources.h"

@implementation UECThemeManager

+ (id<UECTheme>)sharedTheme
{
    static __DISPATCH_ONCE__ id singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Create and return the theme: (This line should change in the future to change the theme)
        singletonObject = [[UECThemeResources alloc] init];
    });
    
    return singletonObject;
}

+ (void)customiseAppAppearance
{    
    [[UINavigationBar appearance] setBarTintColor:UEC_YELLOW];
    NSDictionary *navAttributes = @{NSForegroundColorAttributeName : UEC_BLACK};
    [[UINavigationBar appearance] setTitleTextAttributes:navAttributes];
    
    [[UISearchBar appearance] setBarTintColor:UEC_YELLOW];
    
    [[UITabBar appearance] setTintColor:UEC_YELLOW];
    
    [[UITextView appearance] setTintColor:UEC_YELLOW];
}

// New Customization class methods.

@end
