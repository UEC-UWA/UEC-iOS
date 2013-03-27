//
//  UECCalendarView.m
//  UEC
//
//  Created by Jad Osseiran on 27/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECCalendarView.h"

#import "UECCalendarRowCell.h"

#import "NSDate+Helper.h"

@interface TSQCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;

- (NSIndexPath *)indexPathForRowAtDate:(NSDate *)date;
- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UECCalendarView ()

@property (strong, nonatomic) NSArray *eventDates;

@end

@implementation UECCalendarView

- (void)reloadCalendar
{
    if (!self.eventDates && [self.dataSource respondsToSelector:@selector(calendarViewEventDates)]) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        self.eventDates = [[self.dataSource calendarViewEventDates] sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[self rowCellClass]]) {
        UECCalendarRowCell *uecCell = (UECCalendarRowCell *)cell;
        
        if (uecCell.beginningDate) {
            NSDate *cellEndDate = [uecCell.beginningDate dateByAddingNumberOfDays:uecCell.daysInWeek];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self >= %@) AND (self <= %@)", uecCell.beginningDate, cellEndDate];
            
            [uecCell setEventDates:[self.eventDates filteredArrayUsingPredicate:predicate]];
        }
    }
}
@end
