//
//  UECCommitteeMemberCell.h
//  UEC
//
//  Created by Jad Osseiran on 20/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UECCommitteeMemberCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel, *lastNameLabel, *positionLabel;

@end
