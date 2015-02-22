//
//  APSDownloadManager.h
//  UEC
//
//  Created by Jad Osseiran on 7/12/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import Foundation;
#import <AFNetworking/AFNetworking.h>

@interface APSDownloadManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *currentDownloads;

+ (instancetype)sharedManager;

- (void)downloadFileAtURL:(NSURL *)url
             intoFilePath:(NSString *)filePath
    downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
               completion:(void (^)(NSURL *localURL))completionBlock;

- (void)downloadFileAtURL:(NSURL *)url
             intoFilePath:(NSString *)filePath
               completion:(void (^)(NSURL *localURL))completionBlock;

- (void)stopCurrentDownloads;

@end
