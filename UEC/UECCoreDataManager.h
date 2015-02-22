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

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSManagedObjectContext *mainContext;

+ (instancetype)sharedManager;

- (void)setupCoreData;

- (void)saveMainContext;
- (void)saveContext:(NSManagedObjectContext *)context;

@end
