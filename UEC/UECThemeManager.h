//
//  UECThemeManager.h
//  UEC
//
//  Created by Jad Osseiran on 13/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UEC_YELLOW [UIColor colorWithRed:(249.0/255.0) green:(217.0/255.0) blue:(30.0/255.0) alpha:1.0]
#define UEC_BLACK [UIColor blackColor]

@protocol UECTheme <NSObject>
- (UIImage *)socialEventImage;
- (UIImage *)educationEventImage;
- (UIImage *)otherEventImage;
@end

@interface UECThemeManager : NSObject

+ (id<UECTheme>)sharedTheme;
+ (void)customiseAppAppearance;

@end
