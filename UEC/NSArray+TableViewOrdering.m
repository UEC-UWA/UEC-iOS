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
    
    NSArray *sections = [sortedArray sectionHeaderObjectsForKey:splittingKey sectionedArray:NO];
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:sections.count];
    NSPredicate *predicate = nil;
    
    // Here we are splitting (and sorting as the section names are already sorted) into the sections.
    for (NSString *section in sections) {
        predicate = [NSPredicate predicateWithFormat:@"%K = %@", splittingKey, section];
        [data addObject:[[sortedArray copy] filteredArrayUsingPredicate:predicate]];
    }
    
    return data;
}

- (NSArray *)sectionHeaderObjectsForKey:(NSString *)key sectionedArray:(BOOL)sectionArray
{
    NSMutableArray *sectionNames = [[NSMutableArray alloc] initWithCapacity:[self count]];

    if (sectionArray) {
        for (NSArray *subArray in self)
            [sectionNames addObject:[[subArray lastObject] valueForKey:key]];
    } else {
        for (id object in self)
            [sectionNames addObject:[object valueForKey:key]];
    }
    
    // Remove duplicates.
    NSMutableArray *uniqueSectionNames = [sectionNames mutableCopy];
    for (NSInteger i = [uniqueSectionNames count] - 1; i > 0; i--) {
        if ([uniqueSectionNames indexOfObject:uniqueSectionNames[i]] < i)
            [uniqueSectionNames removeObjectAtIndex:i];
    }
    
    return uniqueSectionNames;
}

@end
