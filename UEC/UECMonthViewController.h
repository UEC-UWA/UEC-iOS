//
//  UECMonthViewController.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@protocol UECMonthViewControllerDelegate <NSObject>

- (void)didSelectEvent:(Event *)event;
- (void)didRefreshDataWithHeaderKey:(NSString *)headerKey completion:(void (^)(NSArray *data, NSArray *sectionNames))completionBlock;

@end

@interface UECMonthViewController : UIViewController

@property (weak, nonatomic) id <UECMonthViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *events;

@end
