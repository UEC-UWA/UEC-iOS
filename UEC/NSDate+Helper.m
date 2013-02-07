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
    return [self dateComponentsForDate:self];
}

- (NSDateComponents *)dateComponentsForDate:(NSDate *)date
{
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
}

- (NSDate *)dateFromComponents:(NSDateComponents *)comps
{
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

#pragma mark - Public Methods

- (NSDate *)startOfCurrentYear
{
    NSDateComponents *comps = [self dateComponents];
    // The months start at 1, so in order to set January as 0 substract 1.
    return [self dateByRemovingNumberOfMonths:(comps.month - 1)];
}

- (NSDate *)endOfCurrentYear
{
    NSRange monthsRange = [[NSCalendar currentCalendar] rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:self];
    NSInteger numMonthsInYear = monthsRange.length;
    
    NSDateComponents *comps = [self dateComponents];
    
    return [self dateByAddingNumberOfMonths:(numMonthsInYear - comps.month)];
}

- (NSDate *)dateByAddingNumberOfMonths:(NSInteger)months
{
    NSDateComponents *comps = [self dateComponents];
    
    comps.month += months;
    
    return [self dateFromComponents:comps];
}

- (NSDate *)dateByRemovingNumberOfMonths:(NSInteger)months
{
    NSDateComponents *comps = [self dateComponents];
    
    comps.month -= months;
    
    return [self dateFromComponents:comps];
}

@end
