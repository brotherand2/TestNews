//
//  SNVideoDetailCell.h
//  sohunews
//
//  Created by jojo on 13-9-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"
#import "SNLabel.h"

#define kVideoDetailCellHeight                  (160 / 2)

@class SNVideoData;
@interface SNVideoDetailCell : UITableViewCell {
    SNLabel *_titleLabel;
    SNWebImageView *_videoImageView;
    UIImageView *_cellSelectedBg;
    UILabel *_authorLabel;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) SNVideoData *video;

// view item
@property (nonatomic, strong) SNLabel *titleLabel;
@property (nonatomic, strong) SNWebImageView *videoImageView;
@property (nonatomic, strong) UILabel *authorLabel;

@end

@protocol SNVideoDetailCellDelegate
- (NSString *)playingMessageId;
- (void)didTapCellThumbnailInCell:(SNVideoDetailCell *)cell;
@end
