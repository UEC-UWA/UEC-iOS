//
//  UECPreviewItem.h
//  UEC
//
//  Created by Jad Osseiran on 3/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import Foundation;
@import QuickLook;

@interface UECPreviewItem : NSObject <QLPreviewItem>

@property (nonatomic, strong) NSString *documentTitle;
@property (nonatomic, strong) NSURL *localURL;

@end
