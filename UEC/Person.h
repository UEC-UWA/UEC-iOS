//
//  Person.h
//  UEC
//
//  Created by Jad Osseiran on 15/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * subcommittee;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * order;

@end
