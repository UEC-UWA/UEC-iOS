//
//  UECPreviewItem.h
//  UEC
//
//  Created by Jad Osseiran on 3/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface UECPreviewItem : NSObject <QLPreviewItem>

@property (strong, nonatomic) NSString *documentTitle;
@property (strong, nonatomic) NSURL *localURL;

@end
