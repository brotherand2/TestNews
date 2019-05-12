//
//  SNFeedBackBaseCell.m
//  sohunews
//
//  Created by 李腾 on 2016/10/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackBaseCell.h"

#define FBIconViewWidth  34.0f


@implementation SNFeedBackBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView setBackgroundColor:SNUICOLOR(kThemeBg2Color)];
        [self createViews];
    }
    return self;
}

- (void)createViews {
    /**
     [UIFont systemFontOfSize:kThemeFontSizeE]];
     SNUICOLOR(kThemeText3Color);
     */
    // 时间
    self.dateLabel = [[UILabel alloc] init];
    _dateLabel.backgroundColor = [UIColor clearColor];
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    _dateLabel.hidden = YES;
    _dateLabel.textColor = SNUICOLOR(kThemeText3Color);
    [self.contentView addSubview:_dateLabel];
    
    
    // 头像
    UIImage *iconImage = [UIImage imageNamed:@"640emoji.png"];
    self.iconView = [[UIImageView alloc] initWithImage:iconImage];
    
    _iconView.layer.cornerRadius = FBIconViewWidth / 2;
    _iconView.layer.masksToBounds = YES;
    [self.contentView addSubview:_iconView];
    
    // 昵称
    self.nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = SNUICOLOR(kThemeText2Color);
    [self.contentView addSubview:_nameLabel];
    
    // 聊天信息底图
    self.chatBubble = [[UIImageView alloc] init];
    _chatBubble.userInteractionEnabled = YES;
    _chatBubble.exclusiveTouch = YES;
    [self.contentView addSubview:_chatBubble];
    // 发送失败警告视图
    NSString *waringFileName = @"fb_warning.png";
    _warningView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:waringFileName]];
    _warningView.hidden = YES;
    [self.contentView addSubview:_warningView];
    

}

@end
