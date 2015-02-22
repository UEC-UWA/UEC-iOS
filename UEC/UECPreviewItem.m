//
//  UECPreviewItem.m
//  UEC
//
//  Created by Jad Osseiran on 3/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECPreviewItem.h"

@implementation UECPreviewItem

@synthesize previewItemTitle = _previewItemTitle;
@synthesize previewItemURL = _previewItemURL;

- (NSString *)previewItemTitle {
    if (!_previewItemTitle) {
        _previewItemTitle = self.documentTitle;
    }

    return _previewItemTitle;
}

- (NSURL *)previewItemURL {
    if (!_previewItemURL) {
        _previewItemURL = self.localURL;
    }

    return _previewItemURL;
}

@end
