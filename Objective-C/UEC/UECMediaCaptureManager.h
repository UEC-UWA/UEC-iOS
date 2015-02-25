//
//  UECMediaCaptureManager.h
//  UEC
//
//  Created by Jad Osseiran on 13/10/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import Foundation;
@import MobileCoreServices;

@interface UECMediaCaptureManager : NSObject

+ (instancetype)sharedManager;

- (void)launchCameraInController:(id)controller;
- (void)launchCameraRollPickerInController:(id)controller;

@end
