//
//  APSDataManager+UEC.m
//  UEC
//
//  Created by Jad Osseiran on 11/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "APSDataManager+UEC.h"

@implementation APSDataManager (UEC)

- (NSDate *)dateForUECJSONValue:(id)UECJSONValue
{
    if ([UECJSONValue isKindOfClass:[NSString class]] && [UECJSONValue rangeOfString:@"date-"].location != NSNotFound) {
        __DISPATCH_ONCE__ NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        
        NSNumber *numSecondsSince1970 = [formatter numberFromString:[UECJSONValue stringByReplacingOccurrencesOfString:@"date-" withString:@""]];
        
        return [[NSDate alloc] initWithTimeIntervalSince1970:[numSecondsSince1970 doubleValue]];
    }
    
    return nil;
}

@end
