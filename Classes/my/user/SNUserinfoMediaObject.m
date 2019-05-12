//
//  SNUserinfoMediaObject.m
//  sohunews
//
//  Created by weibin cheng on 13-8-1.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//
#define kMediaCellHeight 60
#define kMediaWidthMargin 10
#define kMediaHeightMargin 12
#define kMediaIconSize 36


#define kSeperateLineTag 100

#import "SNUserinfoMediaObject.h"
#import "SNConsts.h"
#import "UIColor+ColorUtils.h"

#import "SNThemeManager.h"

@implementation SNUserinfoMediaObject
@synthesize iconUrl = _iconUrl;
@synthesize name = _name;
@synthesize count = _count;
@synthesize link = _link;
@synthesize mediaLink = _mediaLink;
@synthesize subId = _subId;
@synthesize subTypeIcon = _subTypeIcon;

@end


@implementation SNUserinfoMediaCell
@synthesize mediaObject = _mediaObject;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.exclusiveTouch = YES;
        self.backgroundColor = [UIColor clearColor];
        CGFloat x = kMediaWidthMargin;
        CGFloat y = kMediaHeightMargin;
        _headImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(x, y, kMediaIconSize, kMediaIconSize)];
        _headImageView.showFade = YES;
        _headImageView.defaultImage = [UIImage themeImageNamed:@"defaulticon.png"];
        _headImageView.layer.cornerRadius = 1;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.alpha = 1;
        [self addSubview:_headImageView];
        
//        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
//        [_headImageView addGestureRecognizer:tapGesture];
//        [tapGesture release];
        
//        UIImage* image = [UIImage themeImageNamed:@"subinfo_article_iconBg.png"];
//        CGRect rect = CGRectInset(_headImageView.frame, -1, -1);
//        UIImageView* imageView = [[UIImageView alloc] initWithFrame:rect];
//        imageView.image = image;
//        [self insertSubview:imageView belowSubview:_headImageView];
//        [imageView release];
        
        x += kMediaIconSize + kMediaWidthMargin;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 230, 18)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoNameColor]];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:_nameLabel];
        
        _badgeView = [[SNBadgeView alloc] initWithFrame:CGRectMake(230, y+3, 20, 16)];
        _badgeView.delegate = self;
        [self addSubview:_badgeView];
        
        y += 16 + 8;
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 230, 12)];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoMediaContentColor]];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_contentLabel];
        
        x = TTApplicationFrame().size.width - 20;
        y = 24;
        
        UIImage* image = [UIImage themeImageNamed:@"arrow.png"];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(x, y, 6, 10);
        [self addSubview:imageView];
        
        x = kMediaWidthMargin;
        y = kMediaCellHeight - 1;
        
        UIImageView* bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, TTApplicationFrame().size.width - kMediaWidthMargin*2, 1)];
        bottomLine.tag = kSeperateLineTag;
        bottomLine.image = [UIImage themeImageNamed:@"weibo_detail_sepline.png"];
        [self addSubview:bottomLine];
        
    }
    return self;
}
-(void)dealloc
{
     //(_headImageView);
     //(_nameLabel);
     //(_contentLabel);
     //(_cellSelectedBg);
     //(_mediaObject);
}

//- (void)tapImageView:(UITapGestureRecognizer*)tapGesture
//{
//    UIImage* image = [[TTURLCache sharedCache] imageForURL:_mediaObject.iconUrl fromDisk:YES];
//    if([SNUtility getApplicationDelegate].shouldDownloadImagesManually && !image)
//    {
//        [_headImageView loadUrlPath:_mediaObject.iconUrl];
//    }
//}
-(void)setMediaObject:(SNUserinfoMediaObject *)object showSeperateLine:(BOOL)show;
{
    //self.mediaObject = object;
    if(_headImageView.urlPath.length > 0)
    {
        [_headImageView unsetImage];
        _headImageView.urlPath = nil;
        _headImageView.defaultImage = [UIImage themeImageNamed:@"defaulticon.png"];
    }
    if(object.iconUrl.length > 0)
    {
        _headImageView.urlPath = object.iconUrl;
        //[_headImageView loadFromUrlPath:object.iconUrl];
    }
    _headImageView.alpha = 1.0;
    if(object.name)
        _nameLabel.text = object.name;
    if(object.count)
        _contentLabel.text = [NSString stringWithFormat:@"%@", object.count];
    _nameLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCircleBaseinfoNameColor]];
    _contentLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kUserinfoMediaContentColor]];
    CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font];
    _nameLabel.width = size.width;
    _badgeView.left = _nameLabel.left + _nameLabel.width + 5;
    [_badgeView reloadBadges:object.subTypeIcon];
    
    UIImageView* bottomLine = (UIImageView*)[self viewWithTag:kSeperateLineTag];
    if(bottomLine)
    {
        if(!show)
           [bottomLine removeFromSuperview];
    }
    else
    {
        if(show)
        {
            CGFloat x = kMediaWidthMargin;
            CGFloat y = kMediaCellHeight - 1;
            UIImageView* bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, TTApplicationFrame().size.width - kMediaWidthMargin*2, 1)];
            bottomLine.tag = kSeperateLineTag;
            bottomLine.image = [UIImage themeImageNamed:@"weibo_detail_sepline.png"];
            [self addSubview:bottomLine];
        }

    }
}
- (void)badgeViewWidth:(float)width height:(float)height
{
    _badgeView.width = width;
    _badgeView.height = height;
    //_badgeView.center = CGPointMake(_badgeView.center.x, _nameLabel.center.y);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self showSelectedBg:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self showSelectedBg:highlighted];
}

- (void)showSelectedBg:(BOOL)show
{
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.frame = self.bounds;
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1;
    }
    else
    {
        if (_cellSelectedBg.alpha > 0) {
            [UIView beginAnimations:nil context:nil];
            _cellSelectedBg.alpha = 0;
            [UIView commitAnimations];
        }
    }
}
@end
