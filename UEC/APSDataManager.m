//
//  APSDataManager.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "APSDataManager.h"

#import "AFURLConnectionOperation.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworkReachabilityManager.h"

#import "NSManagedObject+Appulse.h"
#import "APSDataManager+UEC.h"

#define CORE_DATA_XCODE_DATA_MODEL_NAME @"UEC"
#define MAPPING_DICTIONARIES [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MappingDictionaries" ofType:@"plist"]]

@interface APSDataManager ()
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSManagedObjectContext *mainContext;

@property (strong, nonatomic) NSString *coreDataXcodeDataModelName;
@property (strong, nonatomic) NSDictionary *mappingDictionaries;

@property (strong, nonatomic) NSMutableArray *currentDownloads;
@end

@implementation APSDataManager

+ (instancetype)sharedManager
{
    static __DISPATCH_ONCE__ APSDataManager *singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        
        singletonObject.coreDataXcodeDataModelName = CORE_DATA_XCODE_DATA_MODEL_NAME;
        singletonObject.mappingDictionaries = MAPPING_DICTIONARIES;
        
        singletonObject.currentDownloads = [[NSMutableArray alloc] init];
        
        [singletonObject setupCoreData];
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

#pragma mark - Public Methods

- (void)cacheEntityName:(NSString *)entityName completion:(void (^)(BOOL internetReachable))completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableSet *coreDataObjectsIDs = [[NSMutableSet alloc] init];
    NSMutableSet *downloadedObjectsIDs = [[NSMutableSet alloc] init];
    
    for (id coreDataObject in [self.class findAllForEntityName:entityName inContext:self.mainContext]) {
        [coreDataObjectsIDs addObject:[coreDataObject objectID]];
    }
    
    // Create a new ManagedObjectContext for multi threading core data operations.
    NSManagedObjectContext *threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    threadContext.parentContext = self.mainContext;
    
    dispatch_queue_t downloadingQueue = dispatch_queue_create("downloadingQueue", NULL);
    dispatch_async(downloadingQueue, ^{
        
        AFNetworkReachabilityStatus internetStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        if (internetStatus == AFNetworkReachabilityStatusNotReachable) {
            // Make sure to wait just enough time to finish the animation of the "Pull to refresh"/
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
        
//        //build NSURLRequest
//        NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:path]
//                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                      timeoutInterval:60.0];
//        
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
//                                             initWithRequest:request];
//        operation.responseSerializer = [AFJSONResponseSerializer serializer];
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *plistName = [[NSString alloc] initWithFormat:@"Dummy%@", entityName];
        NSArray *responseObject = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
        
            [threadContext performBlock:^{
                NSDictionary *entityMappingDict = self.mappingDictionaries[entityName];
                
                for (NSDictionary *dataObject in responseObject) {
                    id downloadedObject = [self.class newEntityWithName:entityName
                                                              inContext:threadContext
                                                            idAttribute:@"identifier"
                                                                  value:dataObject[@"id"]
                                                               onInsert:^(NSManagedObject *entity) {
                                                                   [entityMappingDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                                                       if (![key isEqualToString:@"identifier"]) {
#warning Really need to find out how to turn a JSON date through AFJSONRequestOperation
                                                                           NSDate *date = [self dateForUECJSONValue:dataObject[obj]];
                                                                           id value = (date) ? date : dataObject[obj];
                                                                           [entity setValue:value forKey:key];
                                                                       }
                                                                   }];
                                                               }];
                    
                    [downloadedObjectsIDs addObject:[downloadedObject objectID]];
                }
                
                [self saveContext:threadContext];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![coreDataObjectsIDs isEqualToSet:downloadedObjectsIDs]) {
                        [coreDataObjectsIDs minusSet:downloadedObjectsIDs];
                        for (id objectID in coreDataObjectsIDs) {
                            NSError *error = nil;
                            NSManagedObject *object = [self.mainContext existingObjectWithID:objectID error:&error];
                            [self.mainContext deleteObject:object];
                        }
                    }
                    
                    [self saveContext:self.mainContext];
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    
                    if (completionBlock) {
                        completionBlock(YES);
                    }
                });
            }];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            
//        }];
//        
//        [operation start];
    });
}

- (void)setRelationshipType:(APSDataManagerEntityRelationship)relationshipType
             fromEntityName:(NSString *)fromEntityName
               toEntityName:(NSString *)toEntityName
              fromAttribute:(NSString *)attribute
               relationship:(NSString *)relationship
        inverseRelationship:(NSString *)inverseRelationship
{
    id value = [fromEntityName valueForKey:attribute];
    
    NSArray *fromObjects = [self.class findAllByAttribute:attribute value:value inContext:self.mainContext forEntityName:fromEntityName];
    if (fromObjects.count > 0) {
        NSArray *toObjects = [self.class findAllByAttribute:@"identifier" value:value inContext:self.mainContext forEntityName:toEntityName];
        
        if (toObjects.count > 0) {
            [self.class linRelationshipType:relationshipType fromObjects:fromObjects toObjects:toObjects relationship:relationship inverseRelationship:inverseRelationship value:value];
        }
    }
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

#pragma mark - Private Methods

+ (void)logErrorForEntityName:(NSString *)entityName
{
    NSLog(@"\"%@\" does not appear to be a valide NSManagedObject subclass. Make sure that the class name perfectly matches %@", entityName, entityName);
}

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

+ (id)newEntityWithName:(NSString *)entity
              inContext:(NSManagedObjectContext *)context
            idAttribute:(NSString *)attribute
                  value:(id)value
               onInsert:(void (^)(NSManagedObject *entity))insertBlock
{
    Class managedObject = NSClassFromString(entity);
    
    if ([managedObject respondsToSelector:@selector(newEntity:inContext:idAttribute:value:onInsert:)]) {
        return [managedObject newEntity:entity inContext:context idAttribute:attribute value:value onInsert:^(NSManagedObject *entity) {
            if (insertBlock) {
                insertBlock(entity);
            }
        }];
    } else {
        [self.class logErrorForEntityName:entity];
        return nil;
    }
}

+ (NSArray *)findAllForEntityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context
{
    Class managedObject = NSClassFromString(entityName);

    if ([managedObject respondsToSelector:@selector(findAllInContext:)]) {
        return [managedObject findAllInContext:context];
    } else {
        [self.class logErrorForEntityName:entityName];
        return nil;
    }
}

+ (NSArray *)findAllByAttribute:(NSString *)attribute
                          value:(id)value
                      inContext:(NSManagedObjectContext *)context
                  forEntityName:(NSString *)entityName
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(findAllByAttribute:value:inContext:)]) {
        return [managedObject findAllByAttribute:attribute value:value inContext:context];
    } else {
        [self.class logErrorForEntityName:entityName];
        return nil;
    }
}

+ (id)findFirstByAttribute:(NSString *)attribute value:(id)value inContext:(NSManagedObjectContext *)context forEntityName:(NSString *)entityName
{
    Class managedObject = NSClassFromString(entityName);
    
    if ([managedObject respondsToSelector:@selector(findFirstByAttribute:value:inContext:)]) {
        return [managedObject findFirstByAttribute:attribute value:value inContext:context];
    } else {
        [self.class logErrorForEntityName:entityName];
        return nil;
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
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.coreDataXcodeDataModelName withExtension:@"momd"];
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
    NSError *childError = nil;
    [context save:&childError];
    
    UIBackgroundTaskIdentifier task = UIBackgroundTaskInvalid;
    dispatch_block_t block = ^{
        NSError *parentError = nil;
        if ([self.mainContext hasChanges] && ![self.mainContext save:&parentError]) {
            NSLog(@"Error saving context: %@", parentError);
        }
        [[UIApplication sharedApplication] endBackgroundTask:task];
    };
    
    task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    [self.mainContext performBlock:block];
}

@end
