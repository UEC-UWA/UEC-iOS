//
//  UECCalendarView.h
//  UEC
//
//  Created by Jad Osseiran on 27/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <TimesSquare/TimesSquare.h>

@class UECCalendarView;

@protocol UECCalendarViewDataSource <NSObject>
@optional
- (NSArray *)calendarViewEventDates;
@end

@interface UECCalendarView : TSQCalendarView

@property (weak, nonatomic) id<UECCalendarViewDataSource> dataSource;

- (void)reloadCalendar;

@end
