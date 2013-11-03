//
//  UECDownloadingCell.h
//  UEC
//
//  Created by Jad Osseiran on 4/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UECDownloadingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@property (weak, nonatomic) IBOutlet UIView *downloadingBar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel, *progressLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadActivityView;

@end
