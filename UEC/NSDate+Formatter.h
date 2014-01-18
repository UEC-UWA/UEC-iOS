//
//  NSDate+Formatter.h
//  UEC
//
//  Created by Jad Osseiran on 9/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatter)

+ (NSDateFormatter *)formatter:(void (^)(NSDateFormatter *formatter))formatterBlock;

- (NSString *)stringValue;
- (NSString *)stringNoTimeValue;
- (NSString *)stringNoDateValue;

@end
