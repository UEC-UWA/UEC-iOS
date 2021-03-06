//
//  Person.h
//  UEC
//
//  Created by Jad Osseiran on 12/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) NSString *photoPath;
@property (nonatomic, retain) NSString *position;
@property (nonatomic, retain) NSString *subcommittee;
@property (nonatomic, retain) NSString *summary;

@end
