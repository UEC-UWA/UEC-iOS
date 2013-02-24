//
//  UECActivity.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECActivity.h"

@interface UECActivity ()

@property (strong, nonatomic) NSString *url;

@end

@implementation UECActivity

- (NSString *)activityType
{
    return @"UEC.Review.App";
}

- (NSString *)activityTitle
{
    return @"Open In Safari";
}

- (UIImage *)activityImage
{
    return nil;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    self.url = [activityItems lastObject];
}

- (UIViewController *)activityViewController
{
    return nil;
}

- (void)performActivity
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    [self activityDidFinish:YES];
}

@end
