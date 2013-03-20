//
//  UECTheme.m
//  UEC
//
//  Created by Jad Osseiran on 13/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECTheme.h"

#import "UECTheme_iOS6.h"

#define UEC_YELLOW [UIColor colorWithRed:(249.0/255.0) green:(217.0/255.0) blue:(30.0/255.0) alpha:1.0]

@implementation UECThemeManager

+ (id <UECTheme>)sharedTheme
{
    static id <UECTheme> sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Create and return the theme: (This line should change in the future to change the theme)
        sharedTheme = [[UECTheme_iOS6 alloc] init];
    });
    
    return sharedTheme;
}

+ (void)customiseAppAppearance
{    
    [[UINavigationBar appearance] setTintColor:UEC_YELLOW];
    NSDictionary *navAttributes = @{UITextAttributeTextColor: [UIColor blackColor], UITextAttributeTextShadowColor : [UIColor clearColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navAttributes];
    
    NSDictionary *barButtonAttributes = @{UITextAttributeTextColor: [UIColor whiteColor]};
    [[UIBarButtonItem appearance] setTintColor:[UIColor darkGrayColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:barButtonAttributes forState:UIControlStateHighlighted];
}

// New Customization class methods.

@end
