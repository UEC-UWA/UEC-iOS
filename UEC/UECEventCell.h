//
//  UECEventCell.h
//  UEC
//
//  Created by Jad Osseiran on 27/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UECEventCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *eventLabel, *eventDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageView, *categoryImageView;

@end
