//
//  SNPhotoListRecommendView.m
//  sohunews
//
//  Created by 雪 李 on 11-12-29.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#define kIconTextOffset                             (23.0 / 2)
#define kRecommendTileFont                          (13.0)

#import "SNPhotoListRecommendView.h"
#import "SNDBManager.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "SNWebImageView.h"
#import "SDImageCache.h"

@implementation SNPhotoListRecommendView
-(id)initWithRecommendGallery:(RecommendGallery*)recommendItem frame:(CGRect)frame delegate:(id)delegate
{
    if(self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification object:nil];
        self.frame  = frame;
        _delegate   = delegate;
        CGRect iconViewFrame    = self.bounds;
        
        //icon
        //2013 10 28 by leijia
        _recommendIconView  = [[SNWebImageView alloc] initWithFrame:iconViewFrame];
        _recommendIconView.layer.masksToBounds    = YES;
        _recommendIconView.layer.cornerRadius     = 3.0;
        _recommendIconView.contentMode = UIViewContentModeScaleAspectFill;
        NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
        _recommendIconView.alpha = [alpha floatValue];
        NSString *defautlImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_photolist_click_recommend.png" : @"default_photolist_recommend.png";
        _recommendIconView.defaultImage = [UIImage imageNamed:defautlImgName];

        [self addSubview:_recommendIconView];
        
//        UIImage* cache = [[TTURLCache sharedCache] imageForURL:recommendItem.iconUrl];
//        if (cache) {
//            _recommendIconView.clipToSize = _recommendIconView.size;
//            _recommendIconView.image = cache;
//            _isIconLoaded   = YES;
//        } else {
//            NSString *defautlImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"default_photolist_click_recommend.png" : @"default_photolist_recommend.png";
//            _recommendIconView.image = [UIImage imageNamed:defautlImgName];
//            _isIconLoaded   = NO;
//        }
        
        //title
        if (recommendItem.title) {
            _recommendTitle                     = [[UILabel alloc] init];
            _recommendTitle.text                = recommendItem.title;
            _recommendTitle.textAlignment       = UITextAlignmentCenter;
            _recommendTitle.numberOfLines       = 2;
            _recommendTitle.font                = [UIFont systemFontOfSize:kRecommendTileFont];
            NSString *titleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoListRecommendTitleColor];
            _recommendTitle.textColor           = [UIColor colorFromString:titleColor];
            _recommendTitle.backgroundColor     = [UIColor clearColor]; 
            [self addSubview:_recommendTitle];

            CGSize changeSize = [_recommendTitle.text sizeWithFont:_recommendTitle.font]; 
            _recommendTitle.frame = CGRectMake(0, _recommendIconView.origin.y + _recommendIconView.bounds.size.height + kIconTextOffset,
                                               iconViewFrame.size.width, changeSize.height*2);
            CGRect newFrame = self.frame;
            newFrame.size.height = _recommendTitle.frame.origin.y + _recommendTitle.frame.size.height;
            self.frame = newFrame;
        }
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                  action:@selector(clicked:)];
        [self addGestureRecognizer:gesture];
        [gesture release];
    }
    
    return self;
}

-(BOOL)isRecommendIconLoaded
{
//    return _isIconLoaded;
//    UIImage *image = [_recommendIconView cacheImageForUrl:[NSURL URLWithString:_urlPath]];
//    if (image) {
//        return YES;
//    } else {
//        return NO;
//    }
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_urlPath]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setUrlPath:(NSString *)urlPath
{
    [_urlPath release];
    _urlPath = [urlPath copy];
    _recommendIconView.urlPath = urlPath;
}

- (void)clickToLoadImage:(NSString *)urlPath
{
    [_recommendIconView loadUrlPath:urlPath];
}

-(void)clicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(clickRecommendPhoto:)]) {
        [_delegate performSelector:@selector(clickRecommendPhoto:) withObject:self];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    _recommendIconView.delegateEx = nil;
    TT_RELEASE_SAFELY(_recommendIconView);
    TT_RELEASE_SAFELY(_recommendTitle);
    TT_RELEASE_SAFELY(_urlPath);
    
    [super dealloc];
}

- (void)updateTheme
{
    NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
    _recommendIconView.alpha = [alpha floatValue];
    
    NSString *titleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoListRecommendTitleColor];
    _recommendTitle.textColor = [UIColor colorFromString:titleColor];
}

-(void)notifyImageLoaded:(UIImage*)aImage
{
    _isIconLoaded = YES;
}
@end
