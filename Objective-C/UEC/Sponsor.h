//
//  Sponsor.h
//  UEC
//
//  Created by Jad Osseiran on 12/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface Sponsor : NSManagedObject

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *logoPath;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *websitePath;

@end
