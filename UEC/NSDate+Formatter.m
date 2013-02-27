//
//  NSDate+Formatter.m
//  UEC
//
//  Created by Jad Osseiran on 9/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

#pragma mark - Helper Methods

+ (NSDateFormatter *)formatterWithStyle:(void (^)(NSDateFormatter *formatter))formatterBlock
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (formatterBlock) {
        formatterBlock(dateFormatter);
    }
    return dateFormatter;
}

#pragma mark - Public Methods

- (NSString *)stringValue
{    
    return [[self.class formatterWithStyle:^(NSDateFormatter *formatter) {
        formatter.dateStyle = NSDateFormatterLongStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    }] stringFromDate:self];
}

- (NSString *)stringNoTimeValue
{
    return [[self.class formatterWithStyle:^(NSDateFormatter *formatter) {
        formatter.dateStyle = NSDateFormatterLongStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    }] stringFromDate:self];
}

- (NSString *)stringNoDateValue
{
    return [[self.class formatterWithStyle:^(NSDateFormatter *formatter) {
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    }] stringFromDate:self];
}

@end
