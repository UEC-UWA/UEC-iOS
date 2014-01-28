//
//  APSDownloadManager.h
//  UEC
//
//  Created by Jad Osseiran on 7/12/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "APSDownloadManager.h"

@interface APSDownloadManager ()

@property (strong, nonatomic) NSMutableArray *currentDownloads;

@end

@implementation APSDownloadManager

+ (instancetype)sharedManager
{
    static __DISPATCH_ONCE__ APSDownloadManager *singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        
        singletonObject.currentDownloads = [[NSMutableArray alloc] init];
    });
    
    return singletonObject;
}

#pragma mark - Downloading

- (void)downloadFileAtURL:(NSURL *)url
             intoFilePath:(NSString *)filePath
    downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
               completion:(void (^)(NSURL *localURL))completionBlock
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
    
    dispatch_async(downloadQueue, ^{
        AFNetworkReachabilityStatus internetStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        
        if (internetStatus != AFNetworkReachabilityStatusNotReachable) {
            
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
            [operation setDownloadProgressBlock:progressBlock];
            
            [self.currentDownloads addObject:operation];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.currentDownloads removeObject:operation];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock([NSURL fileURLWithPath:filePath]);
                    }
                });
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.currentDownloads removeObject:operation];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [error handle];
                    }
                    
                    if (completionBlock) {
                        completionBlock(nil);
                    }
                });
            }];
            
            [operation start];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Download File" message:@"You are not connected to the Internet. Try downloading the file when you have an active connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(nil);
                    }
                });
            });
        }
    });
}

- (void)downloadFileAtURL:(NSURL *)url
             intoFilePath:(NSString *)filePath
               completion:(void (^)(NSURL *localURL))completionBlock;
{
    [self downloadFileAtURL:url
               intoFilePath:filePath
      downloadProgressBlock:nil
                 completion:completionBlock];
}

- (void)stopCurrentDownloads
{
    for (AFHTTPRequestOperation *operation in self.currentDownloads)
        [operation cancel];
    
    [self.currentDownloads removeAllObjects];
}

@end
