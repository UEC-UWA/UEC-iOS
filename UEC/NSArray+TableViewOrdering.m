//
//  NSArray+TableViewOrdering.m
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "NSArray+TableViewOrdering.h"

@implementation NSArray (TableViewOrdering)

- (NSArray *)sectionedArrayWithSplittingKey:(NSString *)splittingKey withSortDescriptor:(NSArray *)sortDescriptors
{
    NSArray *sortedArray = nil;
    if (sortDescriptors) 
        sortedArray = [self sortedArrayUsingDescriptors:sortDescriptors];
    else
        sortedArray = self;
    
    NSArray *sections = [sortedArray sectionNamesForKey:splittingKey];
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:sections.count];
    NSPredicate *predicate = nil;
    
    // Here we are splitting (and sorting as the section names are already sorted) into the sections.
    for (NSString *section in sections) {
        predicate = [NSPredicate predicateWithFormat:@"subcommittee LIKE Education", splittingKey, section];
        [data addObject:[sortedArray filteredArrayUsingPredicate:predicate]];
    }
    
    return data;
}

- (NSArray *)sectionNamesForKey:(NSString *)key
{
    NSMutableString *keyPath = [[NSMutableString alloc] initWithFormat:@"@distinctUnionOfObjects.%@", key];
    
    return [self valueForKeyPath:keyPath];
}

@end
