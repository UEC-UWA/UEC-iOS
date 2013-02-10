//
//  Event.h
//  UEC
//
//  Created by Jad Osseiran on 10/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * endSale;
@property (nonatomic, retain) NSNumber * extendedSale;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * startSale;
@property (nonatomic, retain) NSNumber * ticketsLeft;
@property (nonatomic, retain) NSNumber * totalTickets;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * address;

@end
