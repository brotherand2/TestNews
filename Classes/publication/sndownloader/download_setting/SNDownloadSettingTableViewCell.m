//
//  SNDownloadSettingTableViewCell.m
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadSettingTableViewCell.h"
#import "UIColor+ColorUtils.h"

@interface SNDownloadSettingTableViewCell() {
    UIImageView *_bgImageView;
    UIImageView *_seperatorView;
}
@property(nonatomic, strong)UIImageView *bgImageView;
@property(nonatomic, strong)UIImageView *seperatorView;
@end

@implementation SNDownloadSettingTableViewCell
@synthesize delegate = _delegate;
@synthesize data = _data;
@synthesize bgImageView = _bgImageView;
@synthesize titleLabel = _titleLabel;
@synthesize checkMarkBtn = _checkMarkBtn;
@synthesize seperatorView = _seperatorView;
@synthesize order;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegateParam {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _delegate = delegateParam;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self bgImageView];
        [self titleLabel];
        [self checkMarkBtn];
        [self seperatorView];
    }
    return self;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.frame)-20, CGRectGetHeight(self.frame))];
        [_bgImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+14, 0, CGRectGetWidth(self.frame)-14, CGRectGetHeight(self.frame))];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:79/255.0f green:79/255.0f blue:79/255.0f alpha:1];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)checkMarkBtn {
    if (!_checkMarkBtn) {
        _checkMarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat _checkMarkBtnWidth = 40.0f;
        CGFloat _checkMarkBtnHeight = 40.0f;
        _checkMarkBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-_checkMarkBtnWidth-10,
                                         _titleLabel.center.y-_checkMarkBtnHeight/2.0f,
                                         _checkMarkBtnWidth,
                                         _checkMarkBtnHeight);
        [_checkMarkBtn setImage:[UIImage imageNamed:@"download_setting_checkmark.png"] forState:UIControlStateNormal];
        [_checkMarkBtn setHidden:YES];
        [_checkMarkBtn addTarget:self action:@selector(unmarkIt) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkMarkBtn];
    }
    return _checkMarkBtn;
}

- (UIImageView *)seperatorView {
    if (!_seperatorView) {
        _seperatorView = [[UIImageView alloc] init];
        _seperatorView.frame = CGRectMake(11, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame)-22, 1);
        [_seperatorView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:_seperatorView];
    }
    return _seperatorView;
}

//Override by subclass
- (void)reverseSelectedState {
}

- (void)dealloc {
     //(_data);
     //(_bgImageView);
     //(_titleLabel);
     //(_checkMarkBtn);
     //(_seperatorView);
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    switch (self.order) {
        case SNDownloadSettingCellOrder_OnlyOne:
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_onlyone.png"];
            self.seperatorView.image = nil;
            break;
        case SNDownloadSettingCellOrder_First:
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_first.png"];
            self.seperatorView.image = [UIImage imageNamed:@"download_setting_cellseperatorbg.png"];
            break;
        case SNDownloadSettingCellOrder_Last:
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_last.png"];
            self.seperatorView.image = nil;
            break;
        default://SNDownloadSettingCellOrder_Middle
            self.bgImageView.image = [UIImage imageNamed:@"download_setting_cellbg_middle.png"];
            self.seperatorView.image = [UIImage imageNamed:@"download_setting_cellseperatorbg.png"];
            break;
    }
}

- (void)unmarkIt {
    [self reverseSelectedState];
    if ([_delegate respondsToSelector:@selector(updateSectionHeaderTriggeredByCell:)]) {
        [_delegate updateSectionHeaderTriggeredByCell:self];
    }
}

@end
