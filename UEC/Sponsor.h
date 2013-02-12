//
//  Sponsor.h
//  UEC
//
//  Created by Jad Osseiran on 12/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sponsor : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * logoPath;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * websitePath;

@end
