//
//  SNSubCenterMyListCell.m
//  sohunews
//
//  Created by Chen Hong on 12-11-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterMyListCell.h"
#import "UIColor+ColorUtils.h"
#import "CacheObjects.h"
#import "SNDBManager.h"
#import "SNGuideRegisterManager.h"
#import "SNUserManager.h"
#import "SNSubscribeCenterService.h"

#define FRAME_IMAGE_SIZE                    (110 / 2)
#define FRAME_IMAGE_OFFSET_X				(14 / 2)
#define FRAME_IMAGE_OFFSET_Y                (20 / 2)

#define IMAGEVIEW_SIZE                      (96 / 2)

#define TITLE_OFFSET_X                      (140.0 / 2)
#define TITLE_OFFSET_Y                      (36.0 / 2)
#define TITLE_WIDTH                         (400.0 / 2)
#define TITLE_HEIGHT                        (34.0 / 2)
#define TITLE_FONT_SIZE                     (16.0)

#define SUB_TITLE_WIDTH                     (476.0 / 2)
#define SUB_TITLE_FRAME_H                   (28 /2)
#define SUB_TITLE_LINE_H                    21.0
#define SUB_TITLE_FONT_SIZE                 14.0

#define TIME_LABEL_X                        (516.0/2)
#define TIME_LABEL_Y                        (48/2)
#define TIME_LABEL_W                        (100.0/2)
#define TIME_LABEL_H                        (10.0)
#define TIME_FONT_SIZE                      10.0


@implementation SNSubCenterMyListCell

@synthesize parentController=_parentController;
@synthesize indexPath=_indexPath;
@synthesize onComp=_onComp;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.exclusiveTouch = YES;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kSNSubCenterMyListCellNotifyUpdateTheme object:nil];
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_W*2, CELL_H)];
        [self addSubview:_backView];
        
        // 图标背景
        _iconBGView = [[UIImageView alloc] initWithFrame:CGRectMake(FRAME_IMAGE_OFFSET_X, FRAME_IMAGE_OFFSET_Y, FRAME_IMAGE_SIZE,FRAME_IMAGE_SIZE)];
        [_backView addSubview:_iconBGView];
        
        // voiceOver专用点击支持
        _iconBGView.userInteractionEnabled = YES;
        _iconBGView.isAccessibilityElement = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleIconTap:)];
        [_iconBGView addGestureRecognizer:tap];
        
        // 图标
        _iconView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0, IMAGEVIEW_SIZE, IMAGEVIEW_SIZE)];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.clipsToBounds = YES;
        _iconView.showFade = NO;
        _iconView.defaultImage = [UIImage imageNamed:@"defaulticon.png"];
        _iconView.center = CGPointMake(_iconBGView.width/2, _iconBGView.height/2);
        [_iconBGView addSubview:_iconView];
        
        // 标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_OFFSET_X, TITLE_OFFSET_Y, TITLE_WIDTH, TITLE_HEIGHT)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
        [_backView addSubview:_titleLabel];
        
        _topNewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom + 10, SUB_TITLE_WIDTH, SUB_TITLE_FONT_SIZE+1)];
        _topNewsLabel.backgroundColor = [UIColor clearColor];
        _topNewsLabel.font = [UIFont systemFontOfSize:SUB_TITLE_FONT_SIZE];
        _topNewsLabel.numberOfLines = 1;
        [_backView addSubview:_topNewsLabel];
        
        // 时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TIME_LABEL_X, TIME_LABEL_Y, TIME_LABEL_W, TIME_LABEL_H)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:TIME_FONT_SIZE];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [_backView addSubview:_timeLabel];
        
        // 置顶
        UIImage *pin = [UIImage imageNamed:@"subcenter_pin1.png"];
        _pinView = [[UIImageView alloc] initWithImage:pin];
        _pinView.frame = CGRectMake(CELL_W - 6 - pin.size.width, 2, pin.size.width, pin.size.height);
        _pinView.hidden = YES;
        [_backView addSubview:_pinView];
        
        // badge
        _unreadImg = [UIImage imageNamed:@"subcenter_badge_icon.png"];
        _downloadedImg = [UIImage imageNamed:@"subcenter_download_badge.png"];
        
        _badgeView = [[UIImageView alloc] initWithImage:nil];
        _badgeView.frame = CGRectMake(_iconBGView.width-_unreadImg.size.width-3.5, 3.5, _unreadImg.size.width, _unreadImg.size.height);
        [_iconBGView addSubview:_badgeView];
        
        _cellMenuView = [self createCellMenuView];//[[SNSubCenterMyListCellMenuView alloc] initWithFrame:CGRectMake(CELL_W, 0, CELL_W, CELL_H)];
        _cellMenuView.hidden = YES;
        [_backView addSubview:_cellMenuView];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
     //(_onComp);
    
}

- (void)setObject:(id)object {
    isNewItem = (object != _object);
    
	if (isNewItem) {
        _object = object;
        [self setNeedsLayout];
    
        _cellMenuView.delegate = self;
        _cellMenuView.object = _object;
	}
}

- (void)refreshBadgeView {
    int status = [(SCSubscribeObject *)_object statusValueWithFlag:SCSubObjStatusFlagSubStatus];
    
    //“新一期”样式
    if (status == [kHAVE_NEW_TERM intValue]) {
        _badgeView.image = _unreadImg;
    }
    //"已离线"样式
    else if (status == [KHAD_BEEN_OFFLINE intValue]) {
        _badgeView.image = _downloadedImg;
    } else {
        _badgeView.image = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    SCSubscribeObject *item = (SCSubscribeObject *)_object;
    [self refreshBadgeView];
    
    if (isNewItem) {
        isNewItem = NO;
    
        //刊物icon
        if (item.subIcon.length > 0) {
            [_iconView unsetImage];
            [_iconView loadUrlPath:item.subIcon];
        } else {
            [_iconView setImage:[UIImage imageNamed:@"defaulticon.png"]];
        }
        
        //刊物名称
        _titleLabel.text = item.subName;
        
        _iconBGView.accessibilityLabel = [item.subName stringByAppendingString:@"菜单"];
        
        //TopNews
        _topNewsLabel.text = item.topNews;
        
        _pinView.hidden = ![item.isTop boolValue];
        
        //time
        if ([item.publishTime longLongValue] > 0) {
            _timeLabel.hidden = NO;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[item.publishTime longLongValue]/1000];
            _timeLabel.text = [date formatTimeWithType:1];
            _timeLabel.accessibilityLabel = _timeLabel.text;
        } else {
            _timeLabel.hidden = YES;
        }


        //CGSize size = [_timeLabel.text sizeWithFont:_timeLabel.font];
        //_timeLabel.left = CELL_W + CELL_W - size.width - 12;
        
        [self updateTheme];
    }
}

- (void)updateTheme {
    if (![self needsUpdateTheme]) {
        return;
    }

    [super updateTheme];
    [self setNeedsDisplay];
    
    //刊物封面背景框
    _iconBGView.image = [UIImage imageNamed:@"subcenter_allsub_sub_bgn.png"];
    
    
    //刊物名称
    _titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubHomeTableCellTitleLabelColor]];
    
    //TopNews
    _topNewsLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubHomeTableCellDetailLabelColor]];
    
    _timeLabel.textColor = _topNewsLabel.textColor;
    _pinView.image = [UIImage imageNamed:@"subcenter_pin1.png"];
    
    _unreadImg = [UIImage imageNamed:@"subcenter_badge_icon.png"];
    _downloadedImg = [UIImage imageNamed:@"subcenter_download_badge.png"];

    [self refreshBadgeView];

    [_cellMenuView updateTheme];
}

- (void)showMenu:(BOOL)bShow {
    if (bShow && !_bShowMenu) {
        _cellMenuView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^(void) {            
            _backView.left = -CELL_W;
        }];
    }
    
    if (!bShow && _bShowMenu) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            _backView.left = 0;
        } completion:^(BOOL finished){
            _cellMenuView.hidden = YES;
        }];
    }
    
    _bShowMenu = bShow;
    [super setHighlighted:NO animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (!_bShowMenu) {
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (!_bShowMenu) {
        [super setSelected:selected animated:animated];
    }
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    [UIView drawCellSeperateLine:rect];
	
}

#pragma mark - delegate
// 置顶/取消置顶
- (void)subCenterMyListCellMenuViewKeepOnTop:(BOOL)bTop {
    _pinView.hidden = !bTop;
    
//    if ([self.parentController respondsToSelector:@selector(subCenterMyListCellMenuViewKeepOnTop:object:)]) {
//        [self.parentController subCenterMyListCellMenuViewKeepOnTop:bTop object:self.object];
//    }
}

// 推送开/关
- (void)subCenterMyListCellMenuViewPushOn:(BOOL)bOn {
//    if ([self.parentController respondsToSelector:@selector(subCenterMyListCellMenuViewPushOn:object:)]) {
//        [self.parentController subCenterMyListCellMenuViewPushOn:bOn object:self.object];
//    }
}

// 订阅/取消订阅
- (void)subCenterMyListCellMenuViewSubscribeOn:(BOOL)bOn {
//    if ([self.parentController respondsToSelector:@selector(subCenterMyListCellMenuViewSubscribeOn:object:)]) {
//        [self.parentController subCenterMyListCellMenuViewSubscribeOn:bOn object:self.object];
//    }
}

#pragma mark - tap gesture
- (void)handleIconTap:(UITapGestureRecognizer *)tap {
    if (UIAccessibilityIsVoiceOverRunning()) {
        if ([self.parentController respondsToSelector:@selector(handleIconTap:)]) {
            [self.parentController handleIconTap:tap];
        }
    } else {
        [self didSelect:self.object];
    }
}

- (void)didSelect:(SCSubscribeObject *)obj {
    if (obj == nil) {
        return;
    }
    
    // 去除‘新’标记
    [obj setStatusValue:[kNO_NEW_TERM intValue] forFlag:SCSubObjStatusFlagSubStatus];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:obj.status forKey:TB_SUB_CENTER_ALL_SUB_STATUS];
    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:obj.subId withValuePairs:dict];
    [self refreshBadgeView];
    
    // 打开 // 如果是可以通过link打开的 优先考虑通过link打开
    //提交参数中s1=term&s2=subscribed，表示为来自“我的订阅”。服务器端准备以此判断，这个时候忽略termId,均提供最新的内容
    SubscribeHomeMySubscribePO *_tempSubHomeMySubPO = [obj toSubscribeHomeMySubscribePO];
    
    if (obj.subShowType.length > 0 && obj.link.length > 0) {
        obj.openContext = @{@"subitem" : _tempSubHomeMySubPO,
                            @"linkType" : @"SUBLIST",
                            @"FromMySubList" : @"Yes",
                            @"s1" : @"term",
                            @"s2" : @"subscribed",};
        //摇一摇，引导登陆
        if (![SNUserManager isLogin] &&
            [obj.subId length] > 0     &&
            [obj.subId compare:kSubIdPluginShake] == NSOrderedSame) {
            [self needGuideRegist];
            return;
        }
        if ([obj open]) return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_tempSubHomeMySubPO forKey:@"subitem"];
    [userInfo setObject:@"SUBLIST" forKey:@"linkType"];
    [userInfo setObject:@"Yes" forKey:@"FromMySubList"];
    [userInfo setObject:@"term" forKey:@"s1"];
    [userInfo setObject:@"subscribed" forKey:@"s2"];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://paperBrowser"] applyAnimated:YES] applyQuery:userInfo];
    
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)needGuideRegist
{
    SCSubscribeObject *obj = (SCSubscribeObject*)_object;
    [SNGuideRegisterManager showGuideWithShake:obj.subId];
}

- (id)createCellMenuView {
    return [[SNSubCenterMyListCellMenuView alloc] initWithFrame:CGRectMake(CELL_W, 0, CELL_W, CELL_H)];
}

@end
