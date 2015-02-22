//
//  NSDate+Helper.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

#pragma mark - Helper Methods

- (NSDateComponents *)dateComponents {
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:self];
}

- (NSDate *)dateFromComponents:(NSDateComponents *)comps {
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSDate *)dateByAddingUnitsToComps:(void (^)(NSDateComponents *comps))compsBlock {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    if (compsBlock) {
        compsBlock(comps);
    }
    return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

#pragma mark - Compare Methods

- (BOOL)isBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate {
    if ([self compare:beginDate] == NSOrderedAscending)
        return NO;

    if ([self compare:endDate] == NSOrderedDescending)
        return NO;

    return YES;
}

- (BOOL)isInSameDayAsDate:(NSDate *)date {
    return [self isBetweenDate:[date beginningOfDay] andDate:[date endOfDay]];
}

- (NSInteger)daysDifferenceToDate:(NSDate *)toDate {
    unsigned unitFlags = NSCalendarUnitDay;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:self toDate:toDate options:0];
    return [components day] + 1;
}

#pragma mark - Year Methods

- (NSDate *)startOfCurrentYear {
    NSDateComponents *comps = [self dateComponents];
    comps.month = 1;
    comps.day = 1;

    return [self dateFromComponents:comps];
}

- (NSDate *)endOfCurrentYear {
    // Get the number of months till the end of the year.
    NSRange monthsRange = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:self];
    NSInteger numMonthsInYear = monthsRange.length;

    // Save that last month date.
    NSDateComponents *comps = [self dateComponents];
    NSDate *endMonthDate = [self dateByAddingNumberOfMonths:(numMonthsInYear - comps.month)];

    // Get the number of days till the end of the last month.
    NSRange daysRange = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:endMonthDate];
    NSInteger numDaysInMonth = daysRange.length;

    return [endMonthDate dateByAddingNumberOfDays:(numDaysInMonth - comps.day)];
}

#pragma mark - Day Start & Ends

- (NSDate *)dayWithHour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second {
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:self];

    comps.hour = hour;
    comps.minute = minute;
    comps.second = second;

    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSDate *)beginningOfDay {
    return [self dayWithHour:0 minute:0 second:0];
}

- (NSDate *)endOfDay {
    return [self dayWithHour:23 minute:59 second:59];
}

#pragma mark - Adding Methods

- (NSDate *)dateByAddingNumberOfMonths:(NSInteger)months {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.month = months;
    }];
}

- (NSDate *)dateByAddingNumberOfDays:(NSInteger)days {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.day = days;
    }];
}

- (NSDate *)dateByAddingNumberOfHours:(NSInteger)hours {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.hour = hours;
    }];
}

- (NSDate *)dateByAddingNumberOfMinutes:(NSInteger)minutes {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.minute = minutes;
    }];
}

#pragma mark - Removing Methods

- (NSDate *)dateByRemovingNumberOfMonths:(NSInteger)months {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.month = -months;
    }];
}

- (NSDate *)dateByRemovingNumberOfDays:(NSInteger)days {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.day = -days;
    }];
}

- (NSDate *)dateByRemovingNumberOfHours:(NSInteger)hours {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.hour = -hours;
    }];
}

- (NSDate *)dateByRemovingNumberOfMinutes:(NSInteger)minutes {
    return [self dateByAddingUnitsToComps:^(NSDateComponents *comps) {
        comps.minute = -minutes;
    }];
}

@end
