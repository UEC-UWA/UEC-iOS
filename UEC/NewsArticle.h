//
//  NewsArticle.h
//  UEC
//
//  Created by Jad Osseiran on 7/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsArticle : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * identifier;

@end
