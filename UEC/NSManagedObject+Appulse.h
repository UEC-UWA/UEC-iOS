//
//  NSManagedObject+Appulse.h
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Appulse)

+ (void)newEntity:(NSString *)entity
        inContext:(NSManagedObjectContext *)context
      idAttribute:(NSString *)attribute
            value:(id)value onInsert:(void (^)(NSManagedObject *))insertBlock
       completion:(void (^)(NSManagedObject *entity))completionBlock;

+ (void)findAllInContext:(NSManagedObjectContext *)context
              completion:(void (^)(NSArray *objects))completionBlock;

+ (void)findAllByAttribute:(NSString *)attribute
                     value:(id)value
                 inContext:(NSManagedObjectContext *)context
                completion:(void (^)(NSArray *objects))completionBlock;

+ (void)findFirstByAttribute:(NSString *)attribute
                       value:(id)value
                   inContext:(NSManagedObjectContext *)context
                  completion:(void (^)(id object))completionBlock;

+ (NSArray *)fetchRequest:(void (^)(NSFetchRequest *fs))fetchRequestBlock
                inContext:(NSManagedObjectContext *)context;

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;

@end
