//
//  UECSegmentChildrenViewController.h
//  UEC
//
//  Created by Jad Osseiran on 6/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UECSegmentChildrenViewController : UIViewController

// Array of view controllers to switch between
@property (copy, nonatomic) NSArray *allViewControllers;
// Currently selected view controller
@property (strong, nonatomic) UIViewController *currentViewController;

- (void)setupSegmentControlWithItems:(NSArray *)items;

@end
