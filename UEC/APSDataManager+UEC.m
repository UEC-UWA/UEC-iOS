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
    
    if ([UECJSONValue rangeOfString:@"date-"].location != NSNotFound) {
        __DISPATCH_ONCE__ NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        
        NSNumber *numSecondsSince1970 = [formatter numberFromString:[UECJSONValue stringByReplacingOccurrencesOfString:@"date-" withString:@""]];
        
        return [[NSDate alloc] initWithTimeIntervalSince1970:[numSecondsSince1970 doubleValue]];
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
