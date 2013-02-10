//
//  UECCalendarListViewController.h
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@protocol UECCalendarListViewController <NSObject>

- (void)didSelectEvent:(Event *)event;
- (void)didRefreshDataWithCompletion:(void (^)(NSArray *objects))completionBlock;

@end

@interface UECCalendarListViewController : UITableViewController

@property (weak, nonatomic) id <UECCalendarListViewController> delegate;
@property (strong, nonatomic) NSArray *events, *eventDateTitles;

@end
