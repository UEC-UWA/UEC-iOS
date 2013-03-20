//
//  UECCalendarListViewController.h
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreDataTableViewController.h"

#import "APSDataManager.h"
#import "NSDate+Formatter.h"

typedef NS_ENUM(NSInteger, UECEventListType) {
    UECEventListTypeEvents,
    UECEventListTypeTickets
};

@class Event;

@protocol UECCalendarListViewController <NSObject>

- (void)didSelectEvent:(Event *)event;
- (void)didRequestDataOnManualRefresh:(BOOL)manualRefresh completion:(void (^)(void))completionBlock;

@end

@interface UECCalendarListViewController : CoreDataTableViewController

@property (weak, nonatomic) id <UECCalendarListViewController> delegate;

@property (nonatomic) UECEventListType listType;

@end
