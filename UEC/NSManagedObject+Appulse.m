//
//  NSManagedObject+Appulse.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "NSManagedObject+Appulse.h"

@implementation NSManagedObject (Appulse)

+ (id)newEntity:(NSString *)entity
      inContext:(NSManagedObjectContext *)context
    idAttribute:(NSString *)attribute
          value:(id)value
       onInsert:(void (^)(NSManagedObject *object))insertBlock {
    id returnedObject = nil;

    NSFetchRequest *fs = [NSFetchRequest fetchRequestWithEntityName:entity];
    fs.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];

    if ([context countForFetchRequest:fs error:nil] == 0) {
        returnedObject = [[self alloc] initWithEntity:[self entityInContext:context] insertIntoManagedObjectContext:context];
        [returnedObject setValue:value forKey:attribute];

        if (insertBlock)
            insertBlock(returnedObject);

        return returnedObject;
    } else {
        fs.fetchLimit = 1;
        id foundObject = [self findFirstByAttribute:attribute value:value inContext:context];

        if (insertBlock) {
            insertBlock(foundObject);
        }

        return foundObject;
    }
}

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)context {
    return [context executeFetchRequest:[self fetchRequestInContext:context] error:nil];
}

+ (NSArray *)findAllByAttribute:(NSString *)attribute
                          value:(id)value
                      inContext:(NSManagedObjectContext *)context {
    return [self fetchRequest:^(NSFetchRequest *fs) {
        fs.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
    } inContext:context];
}

+ (id)findFirstByAttribute:(NSString *)attribute
                     value:(id)value
                 inContext:(NSManagedObjectContext *)context {
    id object = [[self fetchRequest:^(NSFetchRequest *fs) {
        fs.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
        fs.fetchLimit = 1;
    } inContext:context] lastObject];

    return object;
}

+ (NSArray *)fetchRequest:(void (^)(NSFetchRequest *fs))fetchRequestBlock
                inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fs = [self fetchRequestInContext:context];
    if (fetchRequestBlock)
        fetchRequestBlock(fs);
    return [context executeFetchRequest:fs error:nil];
}

+ (NSUInteger)countInContext:(NSManagedObjectContext *)context {
    return [context countForFetchRequest:[self fetchRequestInContext:context] error:nil];
}

#pragma mark - Private Methods

+ (NSEntityDescription *)entityInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:NSStringFromClass(self)
                       inManagedObjectContext:context];
}

+ (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fs = [[NSFetchRequest alloc] init];
    fs.entity = [[self class] entityInContext:context];
    return fs;
}

@end
