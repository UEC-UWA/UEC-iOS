//
//  NSManagedObject+Appulse.h
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Appulse)

+ (void)newEntity:(NSString *)entity withIdentifierAttribute:(NSString *)attribute value:(id)value onInsert:(void (^)(NSManagedObject *entity))insertBlock completion:(void (^)(NSManagedObject *entity))completionBlock;

+ (void)findAll:(void (^)(NSArray *objects))completionBlock;

+ (void)findAllByAttribute:(NSString *)attribute value:(id)value completion:(void (^)(NSArray *objects))completionBlock;

+ (void)findFirstByAttribute:(NSString *)attribute value:(id)value completion:(void (^)(id object))completionBlock;

+ (NSArray *)fetchRequest:(void (^)(NSFetchRequest *fs))fetchRequestBlock;

+ (NSUInteger)count;

@end
