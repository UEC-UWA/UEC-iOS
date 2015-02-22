//
//  Event.h
//  UEC
//
//  Created by Jad Osseiran on 18/01/2014.
//  Copyright (c) 2014 Appulse. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSString *eventDescription;
@property (nonatomic, retain) NSString *facebookLink;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *imagePath;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *photoPath;

@end
