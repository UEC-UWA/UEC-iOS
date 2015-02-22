//
//  UECCoreDataManager.h
//  UEC
//
//  Created by Jad Osseiran on 7/12/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import CoreData;
@import Foundation;

@interface UECCoreDataManager : NSObject

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSManagedObjectContext *mainContext;

+ (instancetype)sharedManager;

- (void)setupCoreData;

- (void)saveMainContext;
- (void)saveContext:(NSManagedObjectContext *)context;

@end
