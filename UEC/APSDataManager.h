//
//  APSDataManager.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import CoreData;

@import Foundation;

typedef NS_ENUM(NSInteger, APSDataManagerEntityRelationship) {
    APSDataManagerEntityRelationshipOneToOne,
    APSDataManagerEntityRelationshipOneToMany,
    APSDataManagerEntityRelationshipManyToOne,
    APSDataManagerEntityRelationshipManyToMany
};

@interface APSDataManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - Core Data

- (void)cacheEntityName:(NSString *)entityName completion:(void (^)(BOOL internetReachable))completionBlock;

- (NSFetchedResultsController *)fetchedResultsControllerWithRequest:(void (^)(NSFetchRequest *request))fetchRequestBlock
                                                         entityName:(NSString *)entityName
                                                 sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                          cacheName:(NSString *)cacheName;

@end
