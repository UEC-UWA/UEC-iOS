//
//  Torque.h
//  UEC
//
//  Created by Jad Osseiran on 12/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Torque : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * downloaded;
@property (nonatomic, retain) NSNumber * downloading;
@property (nonatomic, retain) NSString * fileAddress;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * localURLString;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * size;

@end
