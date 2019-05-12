//
//  SNBadgeView.m
//  sohunews
//
//  Created by Gao Yongyue on 13-9-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBadgeView.h"

@interface SNBadgeView ()
{
    NSMutableArray *_badges;
    int fail;
    int success;
    
    float _maxHeight;
}
@end

@implementation SNBadgeView

- (id)init
{
    return [self initWithFrame:CGRectZero badges:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame badges:nil];
}

- (id)initWithFrame:(CGRect)frame badges:(NSArray *)badgeListArray
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        _badges = [[NSMutableArray alloc] init];
        [self reloadBadges:badgeListArray];
    }
    return self;
}

- (void)clean
{
    success = 0;
    fail = 0;
    _totalWidth = 0.f;
    _totalHeight = 0.f;
    [self removeAllSubviews];
    [_badges removeAllObjects];
}

- (void)nofifyTheDelegateWidth:(float)width height:(float)height
{
    if (_delegate && [_delegate respondsToSelector:@selector(badgeViewWidth:height:)])
    {
        [_delegate badgeViewWidth:width height:height];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(badgeViewWidth:height:badgeView:)])
    {
        [_delegate badgeViewWidth:width height:height badgeView:self];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(badgeViewWidth:height:identifier:)])
    {
        [_delegate badgeViewWidth:width height:height identifier:_identifier];
    }
}

- (void)reloadBadges:(NSArray *)badgeListArray
{
    [self reloadBadges:badgeListArray maxHeight:13.f];
}

- (void)reloadBadges:(NSArray *)badgeListArray maxHeight:(float)maxHeight
{
    [self clean];
    if (badgeListArray && [badgeListArray isKindOfClass:[NSArray class]] && [badgeListArray count])
    {
        _maxHeight = maxHeight;
        [badgeListArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIImageView *badgeImageView = [[UIImageView alloc] init];
            [_badges addObject:badgeImageView];
            
            NSURL *iconURL = nil;
            NSString *iconLocation = obj[@"icon"];
            if (iconLocation.length > 0) {
                if ([SNAPI isWebURL:iconLocation]) {
                    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
                        iconLocation = [SNUtility replaceString:iconLocation];
                    }
                    iconURL = [NSURL URLWithString:iconLocation];
                }
                else {
                    iconURL = [NSURL fileURLWithPath:iconLocation];
                }
            }
            
            [badgeImageView sd_setImageWithURL:iconURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self resizeBadgeImageView:image];
            }];
            [self addSubview:badgeImageView];
//            badgeImageView.alpha = themeImageAlphaValue();
        }];
    }
    else
    {
        _totalWidth = 0.f;
        _totalHeight = 0.f;
        [self nofifyTheDelegateWidth:_totalWidth height:_totalHeight];
    }
}

- (void)resizeBadgeImageView:(UIImage *)image
{
    if (image)
    {
        //下载成功
        success ++;
        _totalHeight = _totalHeight > image.size.height/2 ? _totalHeight : image.size.height/2;
        if (_maxHeight)
        {
            _totalHeight = _totalHeight > _maxHeight ? _maxHeight : _totalHeight;
        }
    }
    else
    {
        //下载失败
        fail ++;
    }
    
    if ([_badges count] == (success + fail))
    {
        //已经全部下载完（包括成功+失败）
        
        //重新resieze UI
        __block float lastWidth = 0.f;
        [_badges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIImageView *badgeImageView = (UIImageView *)obj;
            if (badgeImageView.image)
            {
                CGSize size = badgeImageView.image.size;
                //下载成功的
                if (_totalHeight < size.height/2)
                {
                    //当实际高度大于默认高度时，等比例压缩
                    float width = (size.width/2 * _totalHeight) / (size.height/2);
                    badgeImageView.frame = CGRectMake(lastWidth, 0.f, width , _totalHeight);
                }
                else
                {
                    badgeImageView.frame = CGRectMake(lastWidth, 0.f, size.width/2, size.height/2);
                    //当多个徽章高度不一致时，底部对齐
                    badgeImageView.top = _totalHeight - badgeImageView.height;
                }
                lastWidth = badgeImageView.right + 4.f;
//                badgeImageView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? .7f : 1.f;
            }
            else
            {
                //下载失败的
            }
        }];

        //回调
        _totalWidth = lastWidth > 0 ? (lastWidth - 4.f) : 0.f;
        [self nofifyTheDelegateWidth:_totalWidth height:_totalHeight];
    }
}

- (void)updateTheme
{
//    [_badges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIImageView *badgeImageView = (UIImageView *)obj;
//        if (badgeImageView.image)
//        {
//            badgeImageView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? .7f : 1.f;
//        }
//    }];
}

- (void)dealloc
{
    _badges = nil;
}

@end
