//
//  NSManagedObject+UEC.m
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "NSManagedObject+UEC.h"

#import "UECDataManager.h"

@implementation NSManagedObject (UEC)

+ (void)newEntity:(NSString *)entity withIdentifierAttribute:(NSString *)attribute value:(id)value onInsert:(void (^)(NSManagedObject *))insertBlock completion:(void (^)(NSManagedObject *entity))completionBlock
{
    id returnedObject = nil;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fs = [NSFetchRequest fetchRequestWithEntityName:entity];
    fs.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
    
    if ([context countForFetchRequest:fs error:nil] == 0) {
        returnedObject = [[self alloc] initWithEntity:[self entity] insertIntoManagedObjectContext:context];
        [returnedObject setValue:value forKey:attribute];
        
        if (insertBlock)
            insertBlock(returnedObject);
        
        if (completionBlock) {
            completionBlock(returnedObject);
        }
    } else {
        fs.fetchLimit = 1;
        
        [self findFirstByAttribute:attribute value:value completion:^(id object) {
            if (completionBlock) {
                completionBlock(object);
            }
        }];
    }
}

+ (void)findAll:(void (^)(NSArray *objects))completionBlock
{
    NSArray *objects = [[self managedObjectContext] executeFetchRequest:[self fetchRequest] error:nil];
    
    if (completionBlock) {
        completionBlock(objects);
    }
}

+ (void)findAllByAttribute:(NSString *)attribute value:(id)value completion:(void (^)(NSArray *objects))completionBlock
{
    NSArray *objects = [self fetchRequest:^(NSFetchRequest *fs) {
        fs.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
    }];
    
    if (completionBlock) {
        completionBlock(objects);
    }
}

+ (void)findFirstByAttribute:(NSString *)attribute value:(id)value completion:(void (^)(id object))completionBlock
{
    id object = [[self fetchRequest:^(NSFetchRequest *fs) {
        fs.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
        fs.fetchLimit = 1;
    }] lastObject];
    
    if (completionBlock) {
        completionBlock(object);
    }
}

+ (NSArray *)fetchRequest:(void (^)(NSFetchRequest *fs))fetchRequestBlock
{
    NSFetchRequest *fs = [self fetchRequest];
    if (fetchRequestBlock)
        fetchRequestBlock(fs);
    return [[self managedObjectContext] executeFetchRequest:fs error:nil];
}

+ (NSUInteger)count
{
    return [[self managedObjectContext] countForFetchRequest:[self fetchRequest] error:nil];
}

#pragma mark - Private Methods

+ (NSManagedObjectContext *)managedObjectContext
{
    return [UECDataManager sharedManager].managedObjectContext;
}

+ (NSEntityDescription *)entity
{
    return [NSEntityDescription entityForName:NSStringFromClass(self)
                       inManagedObjectContext:[self managedObjectContext]];
}

+ (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fs = [[NSFetchRequest alloc] init];
    fs.entity = [[self class] entity];
    return fs;
}

@end
