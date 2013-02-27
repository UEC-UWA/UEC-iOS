//
//  NSDate+Helper.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (BOOL)isInSameDayAsDate:(NSDate *)date;

- (NSDate *)startOfCurrentYear;
- (NSDate *)endOfCurrentYear;

- (NSDate *)dateByAddingNumberOfMonths:(NSInteger)months;
- (NSDate *)dateByAddingNumberOfDays:(NSInteger)days;
- (NSDate *)dateByAddingNumberOfHours:(NSInteger)hours;
- (NSDate *)dateByAddingNumberOfMinutes:(NSInteger)minutes;

- (NSDate *)dateByRemovingNumberOfMonths:(NSInteger)months;
- (NSDate *)dateByRemovingNumberOfDays:(NSInteger)days;
- (NSDate *)dateByRemovingNumberOfHours:(NSInteger)hours;
- (NSDate *)dateByRemovingNumberOfMinutes:(NSInteger)minutes;

@end
