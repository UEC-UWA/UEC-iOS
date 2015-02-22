//
//  UECEventCell.h
//  UEC
//
//  Created by Jad Osseiran on 27/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import UIKit;

@interface UECEventCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *eventLabel, *eventDetailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *eventImageView, *categoryImageView;

@end
