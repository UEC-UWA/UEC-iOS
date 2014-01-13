//
//  Event.h
//  UEC
//
//  Created by Jad Osseiran on 15/12/2013.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * facebookLink;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * type;

@end
