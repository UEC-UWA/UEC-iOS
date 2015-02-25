//
//  UECDownloadingCell.h
//  UEC
//
//  Created by Jad Osseiran on 4/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

@import UIKit;

@interface UECDownloadingCell : UITableViewCell

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;

@property (nonatomic, weak) IBOutlet UIView *downloadingBar;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel, *progressLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *downloadActivityView;

@end
