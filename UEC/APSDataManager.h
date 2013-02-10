//
//  APSDataManager.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    APSDataManagerEntityRelationshipOneToOne,
    APSDataManagerEntityRelationshipOneToMany,
    APSDataManagerEntityRelationshipManyToOne,
    APSDataManagerEntityRelationshipManyToMany
} APSDataManagerEntityRelationship;

@class NSManagedObject;

@protocol APSDataManagerDataSource <NSObject>
@required
- (NSString *)coreDataXcodeDataModelName;
@end

@interface APSDataManager : NSObject

@property (weak, nonatomic) id <APSDataManagerDataSource> dataSource;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

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

@end
