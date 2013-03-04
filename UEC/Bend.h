//
//  Bend.h
//  UEC
//
//  Created by Jad Osseiran on 4/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bend : NSManagedObject

@property (nonatomic, retain) NSString * fileAddress;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * localURLString;
@property (nonatomic, retain) NSNumber * purchased;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * downloading;
@property (nonatomic, retain) NSNumber * size;

@end
