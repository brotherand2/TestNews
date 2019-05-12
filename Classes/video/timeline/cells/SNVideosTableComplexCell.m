//
//  SNVideosTableComplexCell.m
//  sohunews
//
//  Created by weibin cheng on 14-8-7.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNVideosTableComplexCell.h"
#import "SNVideoObjects.h"
#import "SNVideoComplexImageView.h"
#import "SNWebImageView.h"
#import "SNCellMoreView.h"
#import "NSCellLayout.h"
#import "SNRollingNewsPublicManager.h"

#define kVideoCellComplexBannerHeight (int)(40*(kAppScreenWidth - kVideoCellComplexWidthMargin*2) / 300)
#define kVideoCellComplexIntervalHeight 10
#define kVideoCellComplexIntervalWidth 5
#define kVideoCellComplexMoreHeight 12
#define kVideoCellComplexWidthMargin 10

@interface SNVideosTableComplexCell ()
{
    SNWebImageView*         _bannerImageView;
    //UIButton*               _moreButton;
    UIImageView*            _spreadImageView;
    NSMutableArray*         _complexViewArray;
    UIImageView*            _bgImageView;
}
@property (nonatomic, strong) SNWebImageView* bannerImageView;

@end

@implementation SNVideosTableComplexCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:self reuseIdentifier:reuseIdentifier];
    //self.width = kAppScreenWidth;
    if(self)
    {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        CGRect bgViewFrame = CGRectMake(kVideoCellComplexWidthMargin,
                                        kTimelineVideoCellSubContentViewsTopMargin,
                                        0,
                                        0);
        _bgImageView = [[UIImageView alloc] initWithFrame:bgViewFrame];
        _bgImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bgImageView];
        
        _bannerImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(kVideoCellComplexWidthMargin, kTimelineVideoCellSubContentViewsTopMargin+1,
                                                                            kAppScreenWidth-kVideoCellComplexWidthMargin*2, kVideoCellComplexBannerHeight)];
        _bannerImageView.userInteractionEnabled = YES;
        _bannerImageView.defaultImage = [UIImage themeImageNamed:@"photo_list_default2.png"];
        [self addSubview:_bannerImageView];
        
        _spreadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAppScreenWidth - 36, 0, 18, kVideoCellComplexMoreHeight)];
        _spreadImageView.image = [UIImage themeImageNamed:@"video_spread.png"];
        [self addSubview:_spreadImageView];
        
//        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(kAppScreenWidth - 40, 0, 30, kVideoCellComplexMoreHeight+2)];
//        [_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmall_v5.png"] forState:UIControlStateNormal];
//        [_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmallpress_v5.png"] forState:UIControlStateHighlighted];
//        [_moreButton addTarget:self action:@selector(onClickMoreButton) forControlEvents:UIControlEventTouchUpInside];
//        _moreButton.contentMode = UIViewContentModeCenter;
//        [self addSubview:_moreButton];
        
        _complexViewArray = [[NSMutableArray alloc] initWithCapacity:6];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
        //[SNNotificationManager addObserver:self selector:@selector(updateNoPicMode:) name:kNonePictureModeChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
     //(_bannerImageView);
    // //(_moreButton);
     //(_spreadImageView);
     //(_complexViewArray);
     //(_bgImageView);
     //(_uninterestBlock);
     //(_channelId);
}

- (void)updateTheme:(NSNotification *)notification
{
    [super updateTheme];
    _spreadImageView.image = [UIImage themeImageNamed:@"video_spread.png"];
    _spreadImageView.alpha = themeImageAlphaValue();
    _bgImageView.image = [[UIImage themeImageNamed:@"timeline_videoplay_cellbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
    _bgImageView.alpha = themeImageAlphaValue();
    //[_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmall_v5.png"] forState:UIControlStateNormal];
    //[_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmallpress_v5.png"] forState:UIControlStateHighlighted];
    //_moreButton.alpha = themeImageAlphaValue();
    _bannerImageView.alpha = themeImageAlphaValue();
    for(SNVideoComplexImageView* imageView in _complexViewArray)
    {
        [imageView updateTheme];
    }
}

- (void)updateNoPicMode:(NSNotification *)notification
{
    if(![[SNUtility getApplicationDelegate] shouldDownloadImagesManually])
    {
        if(self.object.banerData)
        {
            __weak typeof(self) wself = self;
            if([SNUtility isWhiteListURL:[NSURL URLWithString:self.object.banerData.urlScheme]])
            {
                [wself.bannerImageView setUrlPath:wself.object.banerData.iconOpen completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    wself.bannerImageView.contentMode = UIViewContentModeScaleToFill;
                }];
            }
            else
            {
                [wself.bannerImageView setUrlPath:wself.object.banerData.iconDown completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    wself.bannerImageView.contentMode = UIViewContentModeScaleToFill;
                }];
            }
        }
        

        for(NSInteger index = 0 ; index < _complexViewArray.count; ++index)
        {
            SNVideoComplexImageView* imageView = [_complexViewArray objectAtIndex:index];
            if(imageView)
            {
                SNVideoEntryData* entryData = [self.object.entryData objectAtIndex:imageView.tag];
                if(entryData)
                {
                    [imageView setImageUrl:entryData.icon];
                }
            }
        }
    }
}

- (void)setObject:(SNVideoData *)object
{
    [super setObject:object];
    [self removeAllComplexView];
    
    CGRect bgViewFrame = CGRectMake(kTimelineCellBgViewSideMargin,
                                    kTimelineVideoCellSubContentViewsTopMargin,
                                    kAppScreenWidth-2*kTimelineCellBgViewSideMargin,
                                    [[self class] heightForVideoData:object]-2*kTimelineVideoCellSubContentViewsTopMargin);
    _bgImageView.frame = bgViewFrame;
    _bgImageView.image = [[UIImage themeImageNamed:@"timeline_videoplay_cellbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
    CGFloat height = kTimelineVideoCellSubContentViewsTopMargin;
    CGFloat itemWidth = (kAppScreenWidth - kVideoCellComplexWidthMargin * 2 - kVideoCellComplexIntervalWidth * 4)/3;
    if(self.object.banerData)
    {
        _bannerImageView.frame = CGRectMake(kVideoCellComplexWidthMargin,
                                            height,
                                            kAppScreenWidth-kVideoCellComplexWidthMargin*2,
                                            kVideoCellComplexBannerHeight);
        _bannerImageView.defaultImage = nil;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBannerTapGesture:)];
        [_bannerImageView addGestureRecognizer:tapGesture];
        
        __weak typeof(self) wself = self;
        if([SNUtility isWhiteListURL:[NSURL URLWithString:self.object.banerData.urlScheme]])
        {
            [wself.bannerImageView setUrlPath:wself.object.banerData.iconOpen completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                wself.bannerImageView.contentMode = UIViewContentModeScaleToFill;
            }];
        }
        else
        {
            [wself.bannerImageView setUrlPath:wself.object.banerData.iconDown completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                wself.bannerImageView.contentMode = UIViewContentModeScaleToFill;
            }];
        }
        height += kVideoCellComplexBannerHeight;
    }
    else
    {
        _bannerImageView.size = CGSizeMake(0, 0);
    }
    
    height += kVideoCellComplexIntervalHeight;
    
    if(self.object.entryData)
    {
        if(self.object.entryData.count == 3)
        {
            CGFloat width = kVideoCellComplexWidthMargin + kVideoCellComplexIntervalWidth;
            for(NSInteger i = 0; i < self.object.entryData.count; ++i)
            {
                __block typeof(self) wself = self;
                SNVideoEntryData* entry = [self.object.entryData objectAtIndex:i];
                SNVideoComplexImageView* imageView = [[SNVideoComplexImageView alloc] initWithFrame:CGRectMake(width, height, itemWidth, kVideoCellComplexImageViewHeight)];
                imageView.tag = i;
                [imageView setTitle:entry.title];
                [imageView setImageUrl:entry.icon];
                imageView.clickBlock = ^(NSInteger tag){
                    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
                    SNVideoEntryData* entryData = [wself.object.entryData objectAtIndex:tag];
                    if(entryData)
                    {
                        [wself.object uploadClickStatistics:entryData.entryId fromId:wself.channelId];
                        switch (entryData.linkType) {
                            case 1:
                                if(entryData.link)
                                {
                                    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:entryData.link, @"address",nil];
                                    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
                                    [[TTNavigator navigator] openURLAction:urlAction];
                                }
                                break;
                            case 3:
                                if(entryData.link)
                                {
                                    [SNUtility openProtocolUrl:entryData.link];
                                }
                                break;
                            case 2:
                                if(entryData.link)
                                {
                                    if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:entryData.link]])
                                    {
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:entryData.appDownloadLink]];
                                    }
                                }
                                break;
                            default:
                                break;
                        }
                    }
                };
                [self addSubview:imageView];
                [_complexViewArray addObject:imageView];
                
                width += itemWidth + kVideoCellComplexIntervalWidth;
            }
            
            height += kVideoCellComplexImageViewHeight + kVideoCellComplexIntervalHeight;
        }
        else if(self.object.entryData.count == 6)
        {
            CGFloat width = kVideoCellComplexWidthMargin + kVideoCellComplexIntervalWidth;
            for(NSInteger j = 0; j < 2; ++j)
            {
                for(NSInteger i = j*3; i < j*3+3; ++i)
                {
                    __block typeof(self) wself = self;
                    SNVideoEntryData* entry = [self.object.entryData objectAtIndex:i];
                    SNVideoComplexImageView* imageView = [[SNVideoComplexImageView alloc] initWithFrame:CGRectMake(width, height, itemWidth, kVideoCellComplexImageViewHeight)];
                    imageView.tag = i;
                    [imageView setTitle:entry.title];
                    [imageView setImageUrl:entry.icon];
                    imageView.clickBlock = ^(NSInteger tag){
                        SNVideoEntryData* entryData = [wself.object.entryData objectAtIndex:tag];
                        if(entryData)
                        {
                            [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
                            [wself.object uploadClickStatistics:entryData.entryId fromId:wself.channelId];
                            switch (entryData.linkType) {
                                case 1:
                                    if(entryData.link)
                                    {
//                                        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:entryData.link, @"address",nil];
//                                        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
//                                        [[TTNavigator navigator] openURLAction:urlAction];
                                        [SNUtility openProtocolUrl:entryData.link];
                                    }
                                    break;
                                case 3:
                                    if(entryData.link)
                                    {
                                        [SNUtility openProtocolUrl:entryData.link];
                                    }
                                    break;
                                case 2:
                                    if(entryData.link)
                                    {
                                        if(![[UIApplication sharedApplication] openURL:[NSURL URLWithString:entryData.link]])
                                        {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:entryData.appDownloadLink]];
                                        }
                                    }
                                    break;
                                default:
                                    break;
                            }
                        }
                    };
                    [self addSubview:imageView];
                    [_complexViewArray addObject:imageView];
                    
                    width += itemWidth + kVideoCellComplexIntervalWidth;
                }
                
                width = kVideoCellComplexWidthMargin + kVideoCellComplexIntervalWidth;
                height += kVideoCellComplexImageViewHeight + kVideoCellComplexIntervalHeight;
            }

        }
        else
        {
            
        }
    }
    
    //_moreButton.top = height-3;
    _spreadImageView.top = height;
}

- (void)handleBannerTapGesture:(UITapGestureRecognizer*)gesture
{
    if([SNUtility isWhiteListURL:[NSURL URLWithString:self.object.banerData.urlScheme]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.object.banerData.urlScheme]];
    }
    else
    {
        if(self.object.banerData.appDownloadLink)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.object.banerData.appDownloadLink]];
    }
    [self.object uploadClickStatistics:self.object.banerData.bannerId fromId:self.channelId];
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
}
- (void)onClickMoreButton
{
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
    [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:NO];
    
    SNCellMoreViewButtonOptions buttonOptions = SNCellMoreButtonOptionsUninterested;
    
    
    __block typeof(self) blockSelf = self;
    SNCellMoreView *moreView = [[SNCellMoreView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, self.height)
                                                       buttonOptions:buttonOptions
                                                       newsFavorited:NO isAddBookShelf:(BOOL)NO];
    moreView.right = 2*kAppScreenWidth + CONTENT_LEFT;
    
    /*[moreView setUninterestBlock:^{
        [blockSelf uninterested];
    }favoritesBlock:^(NSDictionary *dict){
        
    }listenBlock:^{
        
    }reportBlock:^{
        
    }];*/
    [moreView setUninterestBlock:^{
        [blockSelf uninterested];
    } favoritesBlock:^(NSDictionary *dict) {
        
    } listenBlock:^{
        
    } reportBlock:^{
        
    } addBookShelfBlock:^{
        
    }];
    [SNRollingNewsPublicManager sharedInstance].moreView = moreView;
    [self addSubview:moreView];
    
    [[SNRollingNewsPublicManager sharedInstance] showAnimationWithRight:kAppScreenWidth];
}

- (void)uninterested
{
    if(self.uninterestBlock)
        self.uninterestBlock(self.object);
}

- (void)removeAllComplexView
{
    for(UIView* view in _complexViewArray)
    {
        [view removeFromSuperview];
    }
    [_complexViewArray removeAllObjects];
}

+ (CGFloat)heightForVideoData:(SNVideoData *)data
{
    CGFloat height = kTimelineVideoCellSubContentViewsTopMargin;
    if(data.banerData)
        height += kVideoCellComplexBannerHeight;
    
    height += kVideoCellComplexIntervalHeight;
    
    if(data.entryData)
    {
        if(data.entryData.count == 3)
        {
            height += kVideoCellComplexIntervalHeight;
            height += kVideoCellComplexImageViewHeight;
        }
        else if(data.entryData.count == 6)
        {
            height += kVideoCellComplexIntervalHeight*2;
            height += kVideoCellComplexImageViewHeight*2;
        }
    }
    
    height += kVideoCellComplexMoreHeight;
    height += kTimelineVideoCellSubContentViewsTopMargin + kVideoCellComplexIntervalHeight;
    
    return height;
}

#pragma mark - Override
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //空实现，为了不让cell有按下效果
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //空实现，为了不让cell有按下效果
}

@end
