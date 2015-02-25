//
//  NewsArticle.h
//  UEC
//
//  Created by Jad Osseiran on 12/04/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface NewsArticle : NSManagedObject

@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *title;

@end
