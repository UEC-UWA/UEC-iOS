//
//  UECTheme.h
//  UEC
//
//  Created by Jad Osseiran on 13/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UECTheme <NSObject>

- (UIImage *)socialEventImage;
- (UIImage *)educationEventImage;
- (UIImage *)otherEventImage;

@end

@interface UECThemeManager : NSObject

+ (id<UECTheme>)sharedTheme;
+ (void)customiseAppAppearance;

@end
