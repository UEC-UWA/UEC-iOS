//
//  UECDataManager.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECDataManager.h"

#import "NSManagedObject+UEC.h"

#import "Person.h"
#import "Event.h"
#import "PhotoAlbum.h"
#import "NewsArticle.h"


@interface UECDataManager ()
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation UECDataManager

+ (UECDataManager *)sharedManager
{
    static __DISPATCH_ONCE__ UECDataManager *singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        [singletonObject setupCoreData];
    });
    
    return singletonObject;
}

#pragma mark - Downloading

- (void)getDataForEntityName:(NSString *)entityName
          coreDataCompletion:(void (^)(NSArray *cachedObjects))coreDataCompletionBlock
          downloadCompletion:(void (^)(BOOL needsReloading, NSArray *downloadedObjects))downloadCompletionBlock
{
    __block NSArray *coreDataObjects = nil;
    
    [self.class findAllForEntityName:entityName completion:^(NSArray *objects) {
        coreDataObjects = objects;
        
        if (coreDataCompletionBlock) {
            coreDataCompletionBlock(objects);
        }
    }];

#ifdef LOCAL_DATA
    NSString *plistName = [[NSString alloc] initWithFormat:@"Dummy%@", entityName];
    NSArray *localData = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
    
    [self cacheData:localData forEntityName:entityName completion:^(NSArray *cachedObjects) {
        NSSet *coreDataSet = [NSSet setWithArray:coreDataObjects];
        NSSet *cachedSet = [NSSet setWithArray:cachedObjects];
        
        BOOL needsReloading = ![coreDataSet isEqualToSet:cachedSet];
        if (downloadCompletionBlock) {
            downloadCompletionBlock(needsReloading, cachedObjects);
        }
    }];
#else
    NSDictionary *serverPaths = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServerConnections" ofType:@"plist"]];
    
    NSMutableString *path = [[NSMutableString alloc] initWithString:serverPaths[@"BasePath"]];
    [path appendString:serverPaths[entityName][@"GET"]];
    
    // TODO: Here the downloading will have to happen. Then call cacheData:forEntityName:completion: in the completion block.
#endif
}

#pragma mark - Mapping

- (void)cacheData:(NSArray *)data forEntityName:(NSString *)entityName completion:(void (^)(NSArray *cachedObjects))completionBlock
{
    NSMutableArray *cachedEntities = [[NSMutableArray alloc] init];
    
    dispatch_group_t group = dispatch_group_create();
    
    NSDictionary *mappingDicts = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MappingDictionaries" ofType:@"plist"]];
    
    NSDictionary *entityMappingDict = mappingDicts[entityName];
    
    for (NSDictionary *dataObject in data) {
        dispatch_group_enter(group);
        [self.class newEntityWithName:entityName
              withIdentifierAttribute:@"identifier"
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
        [self saveContext];
        
        if (completionBlock) {
            completionBlock(cachedEntities);
        }
    });
}

#pragma mark - Core Data Accessors

+ (void)newEntityWithName:(NSString *)entity withIdentifierAttribute:(NSString *)attribute value:(id)value onInsert:(void (^)(NSManagedObject *entity))insertBlock completion:(void (^)(NSManagedObject *entity))completionBlock
{
    Class managedObject = NSClassFromString(entity);
    
    if ([managedObject respondsToSelector:@selector(newEntity:withIdentifierAttribute:value:onInsert:completion:)]) {
        [managedObject newEntity:entity withIdentifierAttribute:attribute value:value onInsert:^(NSManagedObject *entity) {
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

+ (void)findAllForEntityName:(NSString *)entityName completion:(void (^)(NSArray *objects))completionBlock
{
    Class managedObject = NSClassFromString(entityName);

    if ([managedObject respondsToSelector:@selector(findAll:)]) {
        [managedObject findAll:^(NSArray *objects) {
            if (completionBlock) {
                completionBlock(objects);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entityName];
    }
}

+ (void)findAllByAttribute:(NSString *)attribute value:(id)value forEntityName:(NSString *)entityName completion:(void (^)(NSArray *objects))completionBlock
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(findAllByAttribute:value:completion:)]) {
        [managedObject findAllByAttribute:attribute value:value completion:^(NSArray *objects) {
            if (completionBlock) {
                completionBlock(objects);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entityName];
    }
}

+ (void)findFirstByAttribute:(NSString *)attribute value:(id)value forEntityName:(NSString *)entityName completion:(void (^)(id object))completionBlock
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(findFirstByAttribute:value:)]) {
        [managedObject findFirstByAttribute:attribute value:value completion:^(id object) {
            if (completionBlock) {
                completionBlock(object);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entityName];
    }
}

+ (NSUInteger)numberOfObjectsForEntityName:(NSString *)entityName
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(count)]) {
        return [managedObject count];
    }
    
    [self.class logErrorForEntityName:entityName];
    return -1;
}

#pragma mark - Core Data Core

- (void)setupCoreData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationShouldSaveContext:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationShouldSaveContext:) name:UIApplicationWillTerminateNotification object:nil];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UEC" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSURL *documentDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentDirectoryURL URLByAppendingPathComponent:@"coredatatest.sqlite"];
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{ NSMigratePersistentStoresAutomaticallyOption : @YES , NSInferMappingModelAutomaticallyOption : @YES } error:&error]) {
        NSLog(@"Error adding persistent store: %@", error);
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}

- (void)applicationShouldSaveContext:(NSNotification *)notification
{
    [self saveContext];
}

- (void)saveContext
{
    [self.managedObjectContext performBlock:^{
        NSError *error = nil;
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            NSLog(@"Error saving context: %@", error);
        }
    }];
}

#pragma mark - Private Methods

+ (void)logErrorForEntityName:(NSString *)entityName
{
    NSLog(@"\"%@\" does not appear to be a valide NSManagedObject subclass.", entityName);
}

@end
