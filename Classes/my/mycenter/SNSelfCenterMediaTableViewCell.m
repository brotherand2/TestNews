//
//  SNSelfCenterMediaTableViewCell.m
//  sohunews
//
//  Created by yangln on 14-10-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSelfCenterMediaTableViewCell.h"
#import "SNBubbleBadgeObject.h"

@implementation SNSelfCenterMediaTableViewCell

@synthesize myMediaObject = _myMediaObject;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSelfCenterMediaTableViewCellHeight)];
        _bgImageView.alpha = 0;
        [self.contentView addSubview:_bgImageView];
        
        _headImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(14, 11, 37, 37)];
        _headImageView.showFade = YES;
        _headImageView.defaultImage = [UIImage themeImageNamed:@"defaulticon.png"];
        _headImageView.layer.cornerRadius = 2;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.showFade = NO;
        _headImageView.alpha = themeImageAlphaValue();
        [self.contentView addSubview:_headImageView];
        
        UIColor* labelColor = SNUICOLOR(kThemeText1Color);
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, 14, 180, 15)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont boldSystemFontOfSize:13];
        _nameLabel.textColor = labelColor;
        [self.contentView addSubview:_nameLabel];
        
        _badgeView = [[SNBadgeView alloc] initWithFrame:CGRectZero];
        _badgeView.backgroundColor = [UIColor clearColor];
        _badgeView.delegate = self;
//        _badgeView.alpha = themeImageAlphaValue();
        [self.contentView addSubview:_badgeView];
        
        labelColor = SNUICOLOR(kThemeText4Color);
        _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+10, _nameLabel.bottom+1, 180, 12)];
        _subLabel.font = [UIFont systemFontOfSize:9];
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.textColor = labelColor;
        [self.contentView addSubview:_subLabel];
        
//        UIImage* image = [UIImage themeImageNamed:@"my_media_manage.png"];
        _manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _manageButton.right = kAppScreenWidth - 56;
        _manageButton.top = (kSelfCenterMediaTableViewCellHeight - 43)/2;
        _manageButton.size = CGSizeMake(58, 43);
        [_manageButton setTitle:@"管理" forState:UIControlStateNormal];
        _manageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_manageButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
        [_manageButton addTarget:self action:@selector(clickManage) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_manageButton];
        
        
        _bubbleView = [[SNBubbleTipView alloc] initWithType:SNHeadBubbleType];
        _bubbleView.alignType = SNBubbleAlignLeft;
        _bubbleView.frame = CGRectMake(_manageButton.right-13, 26, _bubbleView.defaultWidth, _bubbleView.defaultHeight);
        [self.contentView addSubview:_bubbleView];
        
        [SNNotificationManager addObserver:self selector:@selector(onBubbleMessageNotification:) name:kSNBubbleBadgeChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setHighlighted:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(highlighted)
    {
        _bgImageView.alpha = 1;
        _bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    }
    else
    {
        _bgImageView.alpha = 0;
        _bgImageView.backgroundColor = [UIColor clearColor];
    }
    
}
- (void)dealloc
{
     //(_myMediaObject);
     //(_headImageView);
     //(_nameLabel);
     //(_subLabel);
     //(_manageLabel);
     //(_badgeView);
     //(_bubbleView);
     //(_arrowView);
     //(_manageButton);
     //(_bgImageView);
    [SNNotificationManager removeObserver:self];
}
-(void)clickManage
{
    NSString* url = self.myMediaObject.mediaLink;
    if(url)
    {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:url, @"address",nil];
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}
- (void)setMyMediaObject:(SNUserinfoMediaObject *)myMediaObject
{
    if(_myMediaObject != myMediaObject)
    {
        _myMediaObject = myMediaObject;
    }
    
    UIColor* labelColor = SNUICOLOR(kThemeText1Color);
    _nameLabel.textColor = labelColor;
    _nameLabel.text = myMediaObject.name;
    CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font];
    if(size.width <= 180)
        _nameLabel.width = size.width;
    else
        _nameLabel.width =  180;
    
    [_badgeView reloadBadges:self.myMediaObject.subTypeIcon];
    
    labelColor = SNUICOLOR(kThemeText4Color);
//    _subLabel.text = [NSString stringWithFormat:@"%@人订阅", _myMediaObject.count];
    _subLabel.text = _myMediaObject.count;
    _subLabel.textColor = labelColor;
    _manageLabel.textColor = labelColor;
    if(_headImageView.urlPath.length > 0)
    {
        [_headImageView unsetImage];
        _headImageView.urlPath = nil;
        _headImageView.defaultImage = [UIImage themeImageNamed:@"defaulticon.png"];
    }
    if(_myMediaObject.iconUrl.length > 0)
    {
        [_headImageView  loadUrlPath:_myMediaObject.iconUrl];
    }
    _headImageView.alpha = themeImageAlphaValue();
//    NSDictionary* dic = [SNBubbleNumberManager shareInstance].subMessage;
//    if(dic && self.myMediaObject)
//    {
//        NSString* msgCount = [dic objectForKey:self.myMediaObject.subId];
//        
//        if([msgCount intValue] > 0)
//        {
//            _bubbleView.hidden = NO;
//            _bubbleView.tipCount = -1;
//            if ([msgCount intValue]>0) {
//                _bubbleView.tipCount = -1;
//            }
//            else {
//                _bubbleView.tipCount = 0;
//            }
//            _manageLabel.hidden = YES;
//        }
//        else
//        {
//            _bubbleView.hidden = YES;
//            _manageLabel.hidden = NO;
//        }
//        
//    }
    [_manageButton setTitle:@"管理" forState:UIControlStateNormal];
    [self updateBubble];
}

- (void)setCellItemSeperateLine {
    if (!_cellItemSeperateImageView) {
        _cellItemSeperateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSelfCenterMediaTableViewCellHeight-0.5, kAppScreenWidth, 0.5)];
        [self.contentView addSubview:_cellItemSeperateImageView];
    }
    
    _cellItemSeperateImageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
}

- (void)badgeViewWidth:(float)width height:(float)height
{
    _badgeView.width = width;
    _badgeView.height = height;
    _badgeView.left = _headImageView.right-5.5;
    _badgeView.top = _headImageView.bottom-_badgeView.height;
}

- (void)onBubbleMessageNotification:(NSNotification *)notification {
    [self updateBubble];
}

- (void)updateBubble {
    int count = [[SNBubbleNumberManager shareInstance] getSubMessageCount];
    if (count >0) {
        _bubbleView.hidden = NO;
        _bubbleView.tipCount = -1;
        _manageLabel.hidden = YES;
    }
    else {
        _bubbleView.hidden = YES;
        _manageLabel.hidden = NO;
    }
}

- (void)updateTheme {
//    _badgeView.alpha = themeImageAlphaValue();
    [_badgeView reloadBadges:self.myMediaObject.subTypeIcon];
}

@end
