//
//  UECNewsViewController.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECNewsViewController.h"

#import "UECNewsArticlesViewController.h"
#import "UECTorqueViewController.h"

@interface UECNewsViewController ()

@end

@implementation UECNewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UECNewsArticlesViewController *newsArticlesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECNewsArticlesViewController"];
    UECTorqueViewController *torqueVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UECTorqueViewController"];
    
    // Add the view controllers to the array
    self.allViewControllers = @[newsArticlesVC, torqueVC];
    
    [self setupSegmentControlWithItems:@[@"News", @"Torque"]];
}


@end
