//
//  UECDownloadingCell.m
//  UEC
//
//  Created by Jad Osseiran on 4/03/13.
//  Copyright (c) 2013 Appulse. All rights reserved.
//

#import "UECDownloadingCell.h"

@implementation UECDownloadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDownloadingBar:(UIView *)downloadingBar {
    if (_downloadingBar != downloadingBar) {
        _downloadingBar = downloadingBar;

        _downloadingBar.backgroundColor = UEC_YELLOW;
        _downloadingBar.alpha = 0.6;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
