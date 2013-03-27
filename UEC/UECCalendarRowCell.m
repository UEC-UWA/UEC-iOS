//
//  UECCalendarRowCell.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECCalendarRowCell.h"

#import "NSDate+Helper.h"

@interface TSQCalendarRowCell (AccessingPrivateStuff)
@property (strong, nonatomic) NSArray *dayButtons;

@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, assign) NSInteger indexOfTodayButton;
@end


@implementation UECCalendarRowCell

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect
{
    // Move down for the row at the top
    rect.origin.y += self.columnSpacing;
    rect.size.height -= (self.bottomRow ? 2.0f : 1.0f) * self.columnSpacing;
    [super layoutViewsForColumnAtIndex:index inRect:rect];
}

- (UIImage *)todayBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarTodaysDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)selectedBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarSelectedDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)notThisMonthBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarPreviousMonth.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (UIImage *)eventBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarEvent.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (UIImage *)noEventBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarNoEvent.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (UIImage *)backgroundImage
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"CalendarRow%@.png", self.bottomRow ? @"Bottom" : @""]];
}

- (void)changeDayButton:(void (^)(UIButton *dayButton))dayButtonBlock forDates:(NSArray *)dates
{
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        
        if ([dates count] > 0) {
            NSUInteger cellDateStartIndex = 0;
            for (NSUInteger cellDateIndex = cellDateStartIndex; cellDateIndex < [dates count]; cellDateIndex++) {
                NSDate *date = [dates[cellDateIndex] beginningOfDay];
                // Take 1 from the difference as the week index are 0-6.
                if (index == ([self.beginningDate daysDifferenceToDate:date] - 1)) {
                    
                    UIButton *button = self.dayButtons[index];
                    
                    if (dayButtonBlock) {
                        dayButtonBlock(button);
                    }
                    
                    cellDateStartIndex++;
                }
            }
            
            if ([[NSDate date] isBetweenDate:self.beginningDate andDate:[self.beginningDate dateByAddingNumberOfDays:self.daysInWeek]]) {
                UIButton *todayDayButton = self.dayButtons[self.indexOfTodayButton];
                self.todayButton.enabled = todayDayButton.enabled;
            }
        } else {
            UIButton *button = self.dayButtons[index];
            [button setBackgroundImage:[self noEventBackgroundImage] forState:UIControlStateNormal];
        }
    }
}

- (void)setEventDates:(NSArray *)eventDates
{
    [self changeDayButton:^(UIButton *dayButton) {
        [dayButton setBackgroundImage:[self eventBackgroundImage] forState:UIControlStateNormal];
    } forDates:eventDates];
}

@end
