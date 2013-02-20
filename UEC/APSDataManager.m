//
//  APSDataManager.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "APSDataManager.h"

#import "NSManagedObject+Appulse.h"

@interface APSDataManager ()
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@end

@implementation APSDataManager

+ (APSDataManager *)sharedManager
{
    static __DISPATCH_ONCE__ APSDataManager *singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        [singletonObject setupCoreData];
    });
    
    return singletonObject;
}

#pragma mark - Public Methods

- (void)getDataForEntityName:(NSString *)entityName
          coreDataCompletion:(void (^)(NSArray *cachedObjects))coreDataCompletionBlock
          downloadCompletion:(void (^)(BOOL needsReloading, NSArray *downloadedObjects))downloadCompletionBlock
{    
    dispatch_queue_t downloadingQueue = dispatch_queue_create("downloadingQueue", NULL);
    dispatch_async(downloadingQueue, ^{
        
        // Create a new ManagedObjectContext for multi threading core data operations.
        NSManagedObjectContext *threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        threadContext.parentContext = self.mainContext;
        
        [threadContext performBlock:^{
            __block NSArray *coreDataObjects = nil;
            
            [self.class findAllForEntityName:entityName inContext:threadContext completion:^(NSArray *objects) {
                coreDataObjects = objects;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (coreDataCompletionBlock) {
                        coreDataCompletionBlock(objects);
                    }
                });
            }];
            
#ifdef LOCAL_DATA
            NSString *plistName = [[NSString alloc] initWithFormat:@"Dummy%@", entityName];
            NSArray *localData = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
            
            [self cacheData:localData forEntityName:entityName inContext:threadContext completion:^(NSArray *cachedObjects) {
                NSMutableSet *coreDataSet = [NSSet setWithArray:coreDataObjects];
                NSSet *cachedSet = [NSSet setWithArray:cachedObjects];
                
                if (![coreDataSet isEqualToSet:cachedSet]) {
                    // Allow for initial downaload.
                    if ([coreDataSet count] > [cachedSet count]) {
                        [coreDataSet minusSet:cachedSet];
                        for (id object in coreDataSet)
                            [threadContext deleteObject:object];
                    }
                }
                
#warning currently I only check that the existing object match in relation to their identifiers. I have to find a way to make it so I can know if the backend has updated an existing record so that I can set needsReloading to YES.
                //        BOOL needsReloading = ![coreDataSet isEqualToSet:cachedSet];
                BOOL needsReloading = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (downloadCompletionBlock) {
                        downloadCompletionBlock(needsReloading, cachedObjects);
                    }
                });
            }];
#else
            NSDictionary *serverPaths = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServerConnections" ofType:@"plist"]];
            
            NSMutableString *path = [[NSMutableString alloc] initWithString:serverPaths[@"BasePath"]];
            [path appendString:serverPaths[entityName][@"GET"]];
            
            // TODO: Here the downloading will have to happen. Then call cacheData:forEntityName:completion: in the completion block.
#endif
        }];
        
    });
}

- (void)setRelationshipType:(APSDataManagerEntityRelationship)relationshipType
             fromEntityName:(NSString *)fromEntityName
               toEntityName:(NSString *)toEntityName
              fromAttribute:(NSString *)attribute
               relationship:(NSString *)relationship
        inverseRelationship:(NSString *)inverseRelationship
                 completion:(void (^)())completionBlock
{
    id value = [fromEntityName valueForKey:attribute];
    
    [self.class findAllByAttribute:attribute inContext:self.mainContext value:value forEntityName:fromEntityName completion:^(NSArray *fromObjects) {
        if (fromObjects.count > 0) {
            [self.class findAllByAttribute:@"identifier" inContext:self.mainContext value:value forEntityName:toEntityName completion:^(NSArray *toObjects) {
                if (toObjects.count > 0) {
                    [self.class linRelationshipType:relationshipType fromObjects:fromObjects toObjects:toObjects relationship:relationship inverseRelationship:inverseRelationship value:value];
                }
            }];
        }
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (NSFetchedResultsController *)fetchedResultsControllerWithRequest:(void (^)(NSFetchRequest *request))fetchRequestBlock
                                                         entityName:(NSString *)entityName
                                                 sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                          cacheName:(NSString *)cacheName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if (fetchRequestBlock)
        fetchRequestBlock(request);
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                               managedObjectContext:self.mainContext
                                                 sectionNameKeyPath:sectionNameKeyPath
                                                          cacheName:cacheName];
}

- (void)saveContext
{
    [self saveContext:self.mainContext];
}

#pragma mark - Mapping

- (void)cacheData:(NSArray *)data forEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context completion:(void (^)(NSArray *cachedObjects))completionBlock
{
    NSMutableArray *cachedEntities = [[NSMutableArray alloc] init];
    
    dispatch_group_t group = dispatch_group_create();
    
    NSDictionary *mappingDicts = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MappingDictionaries" ofType:@"plist"]];
    
    NSDictionary *entityMappingDict = mappingDicts[entityName];
    
    for (NSDictionary *dataObject in data) {
        dispatch_group_enter(group);
        [self.class newEntityWithName:entityName
                            inContext:context
                          idAttribute:@"identifier"
                                value:dataObject[@"id"]
                             onInsert:^(NSManagedObject *entity) {
                                 [entityMappingDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                     if (![key isEqualToString:@"identifier"]) {
                                         id value = dataObject[obj];
                                         [entity setValue:value forKey:key];
                                     }
                                 }];
                             } completion:^(NSManagedObject *entity) {
                                 [cachedEntities addObject:entity];
                                 dispatch_group_leave(group);
                             }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self saveContext:context];
        
        if (completionBlock) {
            completionBlock(cachedEntities);
        }
    });
}

#pragma mark - Private Methods

+ (void)logErrorForEntityName:(NSString *)entityName
{
    NSLog(@"\"%@\" does not appear to be a valide NSManagedObject subclass.", entityName);
}

//+ (BOOL)

+ (void)linRelationshipType:(APSDataManagerEntityRelationship)relationshipType
                fromObjects:(NSArray *)fromObjects
                  toObjects:(NSArray *)toObjects
               relationship:(NSString *)relationship
        inverseRelationship:(NSString *)inverseRelationship
                      value:(id)value
{
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

+ (void)newEntityWithName:(NSString *)entity inContext:(NSManagedObjectContext *)context idAttribute:(NSString *)attribute value:(id)value onInsert:(void (^)(NSManagedObject *entity))insertBlock completion:(void (^)(NSManagedObject *entity))completionBlock
{
    Class managedObject = NSClassFromString(entity);
    
    if ([managedObject respondsToSelector:@selector(newEntity:inContext:idAttribute:value:onInsert:completion:)]) {
        [managedObject newEntity:entity inContext:context idAttribute:attribute value:value onInsert:^(NSManagedObject *entity) {
            if (insertBlock) {
                insertBlock(entity);
            }
        } completion:^(NSManagedObject *entity) {
            if (completionBlock) {
                completionBlock(entity);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entity];
    }
}

+ (void)findAllForEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context completion:(void (^)(NSArray *objects))completionBlock
{
    Class managedObject = NSClassFromString(entityName);

    if ([managedObject respondsToSelector:@selector(findAllInContext:completion:)]) {
        [managedObject findAllInContext:context completion:^(NSArray *objects) {
            if (completionBlock) {
                completionBlock(objects);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entityName];
    }
}

+ (void)findAllByAttribute:(NSString *)attribute inContext:(NSManagedObjectContext *)context value:(id)value forEntityName:(NSString *)entityName completion:(void (^)(NSArray *objects))completionBlock
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(findAllByAttribute:value:inContext:completion:)]) {
        [managedObject findAllByAttribute:attribute value:value inContext:context completion:^(NSArray *objects) {
            if (completionBlock) {
                completionBlock(objects);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entityName];
    }
}

+ (void)findFirstByAttribute:(NSString *)attribute value:(id)value inContext:(NSManagedObjectContext *)context forEntityName:(NSString *)entityName completion:(void (^)(id object))completionBlock
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(findFirstByAttribute:value:inContext:completion:)]) {
        [managedObject findFirstByAttribute:attribute value:value inContext:context completion:^(id object) {
            if (completionBlock) {
                completionBlock(object);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entityName];
    }
}

+ (NSUInteger)numberOfObjectsForEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(countInContext:)]) {
        return [managedObject countInContext:context];
    }
    
    [self.class logErrorForEntityName:entityName];
    return -1;
}

#pragma mark - Core Data Core

- (void)setupCoreData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationShouldSaveContext:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationShouldSaveContext:) name:UIApplicationWillTerminateNotification object:nil];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self.dataSource coreDataXcodeDataModelName] withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSURL *documentDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentDirectoryURL URLByAppendingPathComponent:@"coredatatest.sqlite"];
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{ NSMigratePersistentStoresAutomaticallyOption : @YES , NSInferMappingModelAutomaticallyOption : @YES } error:&error]) {
        NSLog(@"Error adding persistent store: %@", error);
    }
    
    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}

- (void)applicationShouldSaveContext:(NSNotification *)notification
{
    [self saveContext:self.mainContext];
}

- (void)saveContext:(NSManagedObjectContext *)context
{
    [context performBlock:^{
        NSError *error = nil;
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"Error saving context: %@", error);
        }
    }];
}

@end
