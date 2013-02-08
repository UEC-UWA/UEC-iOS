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

+ (NSDateFormatter *)formatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    return formatter;
}

#pragma mark - Public Methods

- (NSString *)stringValue
{    
    return [[self.class formatter] stringFromDate:self];
}

@end
