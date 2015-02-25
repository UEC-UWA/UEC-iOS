//
//  UECCommitteeMemberCell.h
//  UEC
//
//  Created by Jad Osseiran on 20/02/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import UIKit;

@interface UECCommitteeMemberCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *pictureImageView;
@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel, *lastNameLabel, *positionLabel;

@end
