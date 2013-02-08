//
//  NSDate+Helper.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (NSDate *)startOfCurrentYear;
- (NSDate *)endOfCurrentYear;

- (NSDate *)dateByAddingNumberOfMonths:(NSInteger)months;
- (NSDate *)dateByAddingNumberOfDays:(NSInteger)days;

- (NSDate *)dateByRemovingNumberOfMonths:(NSInteger)months;
- (NSDate *)dateByRemovingNumberOfDays:(NSInteger)days;

@end
