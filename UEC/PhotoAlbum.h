//
//  PhotoAlbum.h
//  UEC
//
//  Created by Jad Osseiran on 9/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PhotoAlbum : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * keyPhotoPath;
@property (nonatomic, retain) NSString * name;

@end
