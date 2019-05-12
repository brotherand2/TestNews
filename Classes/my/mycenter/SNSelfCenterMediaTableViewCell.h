//
//  SNSelfCenterMediaTableViewCell.h
//  sohunews
//
//  Created by yangln on 14-10-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"
#import "SNUserinfoMediaObject.h"
#import "SNBadgeView.h"
#import "SNBubbleTipView.h"
#import "SNTableViewCell.h"

#define kSelfCenterMediaTableViewCellHeight 70
#define kPushlishAudioTableViewCellHeight 50
@interface SNSelfCenterMediaTableViewCell : SNTableViewCell<SNBadgeViewDelegate>
{
    SNWebImageView*     _headImageView;
    UILabel*            _nameLabel;
    UILabel*            _subLabel;
    SNBadgeView*        _badgeView;
    SNBubbleTipView*    _bubbleView;
    UIImageView*        _arrowView;
    UILabel*            _manageLabel;
    UIButton*           _manageButton;
    UIImageView*        _bgImageView;
    UIImageView *_cellItemSeperateImageView;
}

@property (nonatomic, strong) SNUserinfoMediaObject* myMediaObject;
- (void)setCellItemSeperateLine;

@end
