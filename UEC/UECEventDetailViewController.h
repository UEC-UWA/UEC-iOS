//
//  UECEventDetailViewController.h
//  UEC
//
//  Created by Jad Osseiran on 27/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface UECEventDetailViewController : UITableViewController

@property (strong, nonatomic) Event *event;

@end