//
//  Event+UEC.m
//  UEC
//
//  Created by Jad Osseiran on 12/02/2014.
//  Copyright (c) 2014 Appulse. All rights reserved.
//

#import "Event+UEC.h"

@implementation Event (UEC)

- (NSString *)facebookEventID
{
    NSRange range = [self.facebookLink rangeOfString:@"https://www.facebook.com/events/" options:NSCaseInsensitiveSearch];
    
    NSCharacterSet *nonDecimalDigitsCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *idString = [self.facebookLink stringByReplacingCharactersInRange:range withString:@""];
    idString = [idString stringByTrimmingCharactersInSet:nonDecimalDigitsCharacterSet];
    
    return idString;
}

@end
