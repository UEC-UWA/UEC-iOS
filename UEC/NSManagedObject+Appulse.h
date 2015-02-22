//
//  NSManagedObject+Appulse.h
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import CoreData;

@interface NSManagedObject (Appulse)

+ (id)newEntity:(NSString *)entity
      inContext:(NSManagedObjectContext *)context
    idAttribute:(NSString *)attribute
          value:(id)value
       onInsert:(void (^)(NSManagedObject *))insertBlock;

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllByAttribute:(NSString *)attribute
                          value:(id)value
                      inContext:(NSManagedObjectContext *)context;

+ (id)findFirstByAttribute:(NSString *)attribute
                     value:(id)value
                 inContext:(NSManagedObjectContext *)context;

+ (NSArray *)fetchRequest:(void (^)(NSFetchRequest *fs))fetchRequestBlock
                inContext:(NSManagedObjectContext *)context;

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;

@end
