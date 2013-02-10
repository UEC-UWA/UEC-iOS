//
//  NSArray+TableViewOrdering.h
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TableViewOrdering)

- (NSArray *)sectionedArrayWithSplittingKey:(NSString *)splittingKey withSortDescriptor:(NSArray *)sortDescriptors;
- (NSArray *)sectionHeaderObjectsForKey:(NSString *)key sectionedArray:(BOOL)sectionArray;

@end
