//
//  UECCoreDataManager.m
//  UEC
//
//  Created by Jad Osseiran on 7/12/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECCoreDataManager.h"

@implementation UECCoreDataManager

+ (instancetype)sharedManager
{
    static __DISPATCH_ONCE__ id singletonObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
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
    
    self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.mainContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}

- (void)applicationShouldSaveContext:(NSNotification *)notification
{
    [self saveContext:self.mainContext];
}

- (void)saveMainContext
{
    [self saveContext:self.mainContext];
}

- (void)saveContext:(NSManagedObjectContext *)context
{
    NSError *childError = nil;
    [context save:&childError];
    
    UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];;
    [self.mainContext performBlock:^{
        NSError *parentError = nil;
        if ([self.mainContext hasChanges] && ![self.mainContext save:&parentError]) {
            NSLog(@"Error saving context: %@", parentError);
        }
        [[UIApplication sharedApplication] endBackgroundTask:task];
    }];
}

@end
