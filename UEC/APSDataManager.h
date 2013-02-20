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

@protocol APSDataManagerDataSource <NSObject>
@required
- (NSString *)coreDataXcodeDataModelName;
@end

@interface APSDataManager : NSObject

@property (weak, nonatomic) id <APSDataManagerDataSource> dataSource;

+ (APSDataManager *)sharedManager;

- (void)getDataForEntityName:(NSString *)entityName
          coreDataCompletion:(void (^)(NSArray *cachedObjects))coreDataCompletionBlock
          downloadCompletion:(void (^)(BOOL needsReloading, NSArray *downloadedObjects))downloadCompletionBlock;

- (void)setRelationshipType:(APSDataManagerEntityRelationship)relationshipType
             fromEntityName:(NSString *)fromEntityName
               toEntityName:(NSString *)toEntityName
              fromAttribute:(NSString *)attribute
               relationship:(NSString *)relationship
        inverseRelationship:(NSString *)inverseRelationship
                 completion:(void (^)())completionBlock;

- (NSFetchedResultsController *)fetchedResultsControllerWithRequest:(void (^)(NSFetchRequest *request))fetchRequestBlock
                                                         entityName:(NSString *)entityName
                                                 sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                          cacheName:(NSString *)cacheName;

- (void)saveContext;

@end
