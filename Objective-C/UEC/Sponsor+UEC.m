//
//  Sponsor+UEC.m
//  UEC
//
//  Created by Jad Osseiran on 12/02/2014.
//  Copyright (c) 2014 Appulse. All rights reserved.
//

#import "Sponsor+UEC.h"

@implementation Sponsor (UEC)

- (NSURL *)safariLinkURL {
    NSString *path = self.websitePath;

    if ([self.websitePath rangeOfString:@"http" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        path = [[NSString alloc] initWithFormat:@"http://%@", self.websitePath];
    }

    return [[NSURL alloc] initWithString:path];
}

@end
