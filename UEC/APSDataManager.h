//
//  APSDataManager.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <CoreData/CoreData.h>

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, APSDataManagerEntityRelationship) {
    APSDataManagerEntityRelationshipOneToOne,
    APSDataManagerEntityRelationshipOneToMany,
    APSDataManagerEntityRelationshipManyToOne,
    APSDataManagerEntityRelationshipManyToMany
};

@interface APSDataManager : NSObject

+ (APSDataManager *)sharedManager;

#pragma mark - Downloading

- (void)downloadFileAtURL:(NSURL *)url
             intoFilePath:(NSString *)filePath
    downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
               completion:(void (^)(NSURL *localURL))completionBlock;

- (void)downloadFileAtURL:(NSURL *)url
             intoFilePath:(NSString *)filePath
               completion:(void (^)(NSURL *localURL))completionBlock;

#pragma mark - Core Data

- (void)cacheEntityName:(NSString *)entityName completion:(void (^)(BOOL internetReachable))completionBlock;

- (NSFetchedResultsController *)fetchedResultsControllerWithRequest:(void (^)(NSFetchRequest *request))fetchRequestBlock
                                                         entityName:(NSString *)entityName
                                                 sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                          cacheName:(NSString *)cacheName;

- (void)saveContext;

@end
