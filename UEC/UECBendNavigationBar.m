//
//  UECBendNavigationBar.m
//  UEC
//
//  Created by Jad Osseiran on 4/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECBendNavigationBar.h"

@implementation UECBendNavigationBar

- (UINavigationItem *)topItem
{
    UINavigationItem *item = [super topItem];
    item.rightBarButtonItem = nil;
    if ([item respondsToSelector:@selector(setRightBarButtonItems:)])
        item.rightBarButtonItems = nil;
    return item;
}

@end
