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

- (NSDateComponents *)dateComponents
{
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:self];
}

- (NSDate *)dateFromComponents:(NSDateComponents *)comps
{
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

#pragma mark - Public Methods

- (NSDate *)startOfCurrentYear
{
    NSDateComponents *comps = [self dateComponents];
    comps.month = 1;
    comps.day = 1;
    
    return [self dateFromComponents:comps];
}

- (NSDate *)endOfCurrentYear
{
    // Get the number of months till the end of the year.
    NSRange monthsRange = [[NSCalendar currentCalendar] rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self];
    NSInteger numMonthsInYear = monthsRange.length;
    
    // Save that last month date.
    NSDateComponents *comps = [self dateComponents];
    NSDate *endMonthDate = [self dateByAddingNumberOfMonths:(numMonthsInYear - comps.month)];
    
    // Get the number of days till the end of the last month.
    NSRange daysRange = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:endMonthDate];
    NSInteger numDaysInMonth = daysRange.length;
        
    return [endMonthDate dateByAddingNumberOfDays:(numDaysInMonth - comps.day)];
}

#pragma mark - Adding Methods

- (NSDate *)dateByAddingNumberOfMonths:(NSInteger)months
{
    NSDateComponents *comps = [self dateComponents];
    
    comps.month += months;
    
    return [self dateFromComponents:comps];
}

- (NSDate *)dateByAddingNumberOfDays:(NSInteger)days
{
    NSDateComponents *comps = [self dateComponents];
    
    comps.day += days;
    
    return [self dateFromComponents:comps];
}

#pragma mark - Removing Methods

- (NSDate *)dateByRemovingNumberOfMonths:(NSInteger)months
{
    NSDateComponents *comps = [self dateComponents];
    
    comps.month -= months;
    
    return [self dateFromComponents:comps];
}

- (NSDate *)dateByRemovingNumberOfDays:(NSInteger)days
{
    NSDateComponents *comps = [self dateComponents];
    
    comps.day -= days;
    
    return [self dateFromComponents:comps];
}

@end