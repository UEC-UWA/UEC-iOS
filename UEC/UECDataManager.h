//
//  UECDataManager.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObject;

@interface UECDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (UECDataManager *)sharedManager;

- (void)getDataForEntityName:(NSString *)entityName
          coreDataCompletion:(void (^)(NSArray *cachedObjects))coreDataCompletionBlock
          downloadCompletion:(void (^)(BOOL needsReloading, NSArray *downloadedObjects))downloadCompletionBlock;

@end
