//
//  APSDataManager.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "APSDataManager.h"

#import "UECCoreDataManager.h"

#import "NSManagedObject+Appulse.h"
#import "APSDataManager+UEC.h"

#define MAPPING_DICTIONARIES [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MappingDictionaries" ofType:@"plist"]]

@interface APSDataManager ()

@property (nonatomic, strong) NSDictionary *mappingDictionaries;
@property (nonatomic, strong) UECCoreDataManager *coreDataManager;

@end

@implementation APSDataManager

+ (instancetype)sharedManager {
    static __DISPATCH_ONCE__ APSDataManager *singletonObject = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        
        singletonObject.mappingDictionaries = MAPPING_DICTIONARIES;
        
        UECCoreDataManager *coreDataManager = [UECCoreDataManager sharedManager];
        [coreDataManager setupCoreData];
        singletonObject.coreDataManager = coreDataManager;
    });

    return singletonObject;
}

#pragma mark - Public Methods

- (void)cacheEntityName:(NSString *)entityName completion:(void (^)(BOOL internetReachable))completionBlock {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSMutableSet *coreDataObjectsIDs = [[NSMutableSet alloc] init];
    NSMutableSet *downloadedObjectsIDs = [[NSMutableSet alloc] init];

    for (id coreDataObject in [[self class] findAllForEntityName:entityName inContext:self.coreDataManager.mainContext]) {
        [coreDataObjectsIDs addObject:[coreDataObject objectID]];
    }

    // Create a new ManagedObjectContext for multi threading core data operations.
    NSManagedObjectContext *threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    threadContext.parentContext = self.coreDataManager.mainContext;

    dispatch_queue_t downloadingQueue = dispatch_queue_create("downloadingQueue", NULL);
    dispatch_async(downloadingQueue, ^{

        AFNetworkReachabilityStatus internetStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        if (internetStatus == AFNetworkReachabilityStatusNotReachable) {
            // Make sure to wait just enough time to finish the animation of the "Pull to refresh"
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                if (completionBlock) {
                    completionBlock(NO);
                }
                
                return;
                                                                                 });
        }

        NSDictionary *serverPaths = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServerConnections" ofType:@"plist"]];

        NSMutableString *path = [[NSMutableString alloc] initWithString:serverPaths[@"BasePath"]];
        [path appendString:serverPaths[entityName]];
        
#if SERVER
        //build NSURLRequest
        NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:path]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                             initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
#else
        NSString *plistName = [[NSString alloc] initWithFormat:@"Dummy%@", entityName];
        NSArray *responseObject = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
#endif
        [threadContext performBlock:^{
                NSDictionary *entityMappingDict = self.mappingDictionaries[entityName];
                
                for (NSDictionary *dataObject in responseObject) {
                    id downloadedObject = [[self class] newEntityWithName:entityName inContext:threadContext idAttribute:@"identifier" value:dataObject[@"id"] onInsert:^(NSManagedObject *entity) {
                        [entityMappingDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            if (![key isEqualToString:@"identifier"]) {
                                
                                NSDate *date = [self dateForUECJSONValue:dataObject[obj]];
                                id value = (date) ? date : dataObject[obj];
                                if ([value isKindOfClass:[NSNull class]]) {
                                    value = nil;
                                }
                                
                                [entity setValue:value forKey:key];
                            }
                        }];
                    }];
                    
                    [downloadedObjectsIDs addObject:[downloadedObject objectID]];
                }
                
                [self.coreDataManager saveContext:threadContext];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![coreDataObjectsIDs isEqualToSet:downloadedObjectsIDs]) {
                        [coreDataObjectsIDs minusSet:downloadedObjectsIDs];
                        for (id objectID in coreDataObjectsIDs) {
                            NSError *error = nil;
                            NSManagedObject *object = [self.coreDataManager.mainContext existingObjectWithID:objectID error:&error];
                            
                            if (!error) {
                                [self.coreDataManager.mainContext deleteObject:object];
                            } else {
                                [error handle];
                            }
                        }
                    }
                    
                    [self.coreDataManager saveMainContext];
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                });
        }];
#if SERVER
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    [error handle];
                }                
                if (completionBlock) {
                    completionBlock(YES);
                }
                       });
        }];

        [operation start];
#endif
    });
}

- (void)setRelationshipType:(APSDataManagerEntityRelationship)relationshipType
             fromEntityName:(NSString *)fromEntityName
               toEntityName:(NSString *)toEntityName
              fromAttribute:(NSString *)attribute
               relationship:(NSString *)relationship
        inverseRelationship:(NSString *)inverseRelationship {
    id value = [fromEntityName valueForKey:attribute];

    NSArray *fromObjects = [[self class] findAllByAttribute:attribute value:value inContext:self.coreDataManager.mainContext forEntityName:fromEntityName];
    if ([fromObjects count] > 0) {
        NSArray *toObjects = [[self class] findAllByAttribute:@"identifier" value:value inContext:self.coreDataManager.mainContext forEntityName:toEntityName];

        if ([toObjects count] > 0) {
            [[self class] linRelationshipType:relationshipType fromObjects:fromObjects toObjects:toObjects relationship:relationship inverseRelationship:inverseRelationship value:value];
        }
    }
}

- (NSFetchedResultsController *)fetchedResultsControllerWithRequest:(void (^)(NSFetchRequest *request))fetchRequestBlock
                                                         entityName:(NSString *)entityName
                                                 sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                          cacheName:(NSString *)cacheName {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (fetchRequestBlock)
        fetchRequestBlock(request);

    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.coreDataManager.mainContext
                                                 sectionNameKeyPath:sectionNameKeyPath
                                                          cacheName:cacheName];
}

#pragma mark - Private Methods

+ (void)logErrorForEntityName:(NSString *)entityName {
    NSLog(@"\"%@\" does not appear to be a valide NSManagedObject subclass. Make sure that the class name perfectly matches %@", entityName, entityName);
}

+ (void)linRelationshipType:(APSDataManagerEntityRelationship)relationshipType
                fromObjects:(NSArray *)fromObjects
                  toObjects:(NSArray *)toObjects
               relationship:(NSString *)relationship
        inverseRelationship:(NSString *)inverseRelationship
                      value:(id)value {
    [fromObjects enumerateObjectsUsingBlock:^(id fromObj, NSUInteger fromIdx, BOOL *fromStop) {
        switch (relationshipType) {
            case APSDataManagerEntityRelationshipOneToOne: {
                [toObjects enumerateObjectsUsingBlock:^(id toObj, NSUInteger toIdx, BOOL *toStop) {
                    [fromObj setValue:value forKey:relationship];
                }];
                break;
            }
                
            case APSDataManagerEntityRelationshipOneToMany:
                [fromObj setValue:[[NSSet alloc] initWithArray:toObjects] forKey:relationship];
                break;
                
            case APSDataManagerEntityRelationshipManyToMany: {
                [toObjects enumerateObjectsUsingBlock:^(id toObj, NSUInteger toIdx, BOOL *toStop) {
                    [fromObj setValue:[[NSSet alloc] initWithArray:toObjects] forKey:relationship];
                    [toObj setValue:[[NSSet alloc] initWithArray:fromObjects] forKey:inverseRelationship];
                }];
                break;
            }
                
            default:
                break;
        }
    }];

    if (relationshipType == APSDataManagerEntityRelationshipManyToOne) {
        [toObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:[[NSSet alloc] initWithArray:fromObjects] forKey:inverseRelationship];
        }];
    }
}

#pragma mark - Core Data Accessors

+ (id)newEntityWithName:(NSString *)entity
              inContext:(NSManagedObjectContext *)context
            idAttribute:(NSString *)attribute
                  value:(id)value
               onInsert:(void (^)(NSManagedObject *entity))insertBlock {
    Class managedObject = NSClassFromString(entity);

    if ([managedObject respondsToSelector:@selector(newEntity:inContext:idAttribute:value:onInsert:)]) {
        return [managedObject newEntity:entity inContext:context idAttribute:attribute value:value onInsert:^(NSManagedObject *entity) {
            if (insertBlock) {
                insertBlock(entity);
            }
        }];
    } else {
        [[self class] logErrorForEntityName:entity];
        return nil;
    }
}

+ (NSArray *)findAllForEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    Class managedObject = NSClassFromString(entityName);

    if ([managedObject respondsToSelector:@selector(findAllInContext:)]) {
        return [managedObject findAllInContext:context];
    } else {
        [[self class] logErrorForEntityName:entityName];
        return nil;
    }
}

+ (NSArray *)findAllByAttribute:(NSString *)attribute
                          value:(id)value
                      inContext:(NSManagedObjectContext *)context
                  forEntityName:(NSString *)entityName {
    Class managedObject = NSClassFromString(entityName);

    if ([managedObject respondsToSelector:@selector(findAllByAttribute:value:inContext:)]) {
        return [managedObject findAllByAttribute:attribute value:value inContext:context];
    } else {
        [[self class] logErrorForEntityName:entityName];
        return nil;
    }
}

+ (id)findFirstByAttribute:(NSString *)attribute value:(id)value inContext:(NSManagedObjectContext *)context forEntityName:(NSString *)entityName {
    Class managedObject = NSClassFromString(entityName);

    if ([managedObject respondsToSelector:@selector(findFirstByAttribute:value:inContext:)]) {
        return [managedObject findFirstByAttribute:attribute value:value inContext:context];
    } else {
        [[self class] logErrorForEntityName:entityName];
        return nil;
    }
}

+ (NSUInteger)numberOfObjectsForEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context {
    Class managedObject = NSClassFromString(entityName);

    if ([managedObject respondsToSelector:@selector(countInContext:)]) {
        return [managedObject countInContext:context];
    }

    [[self class] logErrorForEntityName:entityName];
    return -1;
}

@end
