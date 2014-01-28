//
//  APSDataManager+UEC.m
//  UEC
//
//  Created by Jad Osseiran on 11/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "APSDataManager+UEC.h"

#import "NSDate+Formatter.h"

@implementation APSDataManager (UEC)

- (NSDate *)dateForUECJSONValue:(id)UECJSONValue
{
    if (![UECJSONValue isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSDateFormatter *dateFormatter = [NSDate formatter:^(NSDateFormatter *formatter) {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }];
    NSDate *date = [dateFormatter dateFromString:UECJSONValue];
    if (date) {
        return date;
    }
    
    return nil;
}

@end
