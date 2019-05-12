//
//  SNPhotoListTableCell.m
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//


#define kTitleLeftOffset                (10.0)

#define kTextColor                      RGBACOLOR(90, 90, 90, 1)
#define kTitleFont                      (15.5)
#define kMaxHeightForText               (4)
//#define kAbstractLineHeight             (15.5+11.5)

#import "SNPhotoListTableCell.h"
#import "SNPhotoListTableItem.h"
#import "SNDBManager.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "SNMTLabel.h"
#import "UIImage+MultiFormat.h"
#import "SNWebImageView.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

@implementation SNPhotoListTableCell
@synthesize item = _item;
@synthesize imageSize = _imageSize;
@synthesize imageView,containerView,abstractLabel;
@synthesize delegate;
@synthesize webImageView = _webImageView;


+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    SNPhotoListTableItem *item  = (SNPhotoListTableItem*)object;
    return item.cellHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGSize)imageSize
{
    return CGSizeMake(kImageSizeWidth, _item.imageHeight);
}

- (CGRect)getImageRect
{
    if (self.webImageView == nil || self.webImageView.image == nil) {
        return CGRectMake(0, 0, 0, 0);
    }

    CGRect rcImage;
    if (_item.photo.height == 0 || _item.photo.width == 0)
    {
        rcImage  = self.containerView.frame;
    }
    else
    {
        rcImage  = CGRectMake(kImageLeftMargin, 0, self.imageSize.width, self.imageSize.height);
    }
    CGRect rcImageInNavigationView  = [[self.containerView superview] convertRect:rcImage 
                                                                           toView:nil];
    
    rcImageInNavigationView.origin.y    -= TTStatusHeight();
    rcImageInNavigationView.origin.y += kSystemBarHeight;
    return rcImageInNavigationView;
}

- (void)showImage:(BOOL)bShow
{
    self.webImageView.hidden   = !bShow;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.webImageView.userInteractionEnabled   = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        
        _defaultImageView = [[UIImageView alloc] init];

	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self setBackgroundColor:[UIColor clearColor]];
    
    self.containerView.frame = CGRectMake(kImageLeftMargin, 0, self.imageSize.width, self.imageSize.height);

    if (_item.photo.height == 0 || _item.photo.width == 0)
    {
        CGRect frameFitScreen = [SNUtility calculateFrameToFitScreenBySize:self.webImageView.image.size defaultSize:self.imageSize];
        CGRect overflowRect   = [self.webImageView.image getOverflowRectByFillingRect:frameFitScreen byAnimation:kFadeOutAnimation];
        [self.webImageView setFrame:CGRectMake(-kImageLeftMargin, overflowRect.origin.y, overflowRect.size.width, overflowRect.size.height)];
    }
    else
    {
        [self.webImageView setFrame:CGRectMake(0, 0, kImageSizeWidth, _item.imageHeight)];
    }
    UIImageView *arrow  = (UIImageView *)[self.contentView viewWithTag:102];
    [self.contentView bringSubviewToFront:arrow];
    arrow.top = self.imageSize.height + kImageBottomMargin +5;
    self.abstractLabel.frame = CGRectMake(kTitleLeftOffset,
                                          self.containerView.frame.origin.y + self.containerView.frame.size.height + kImageBottomMargin
                                          , self.imageSize.width
                                          , self.item.textHeight);
    _defaultImageView.center = self.webImageView.center;
}


- (void)tapOnAbstract
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toggleFullscreen)]) {
        [self.delegate performSelector:@selector(toggleFullscreen)];
    }
}

- (void)setObject:(id)object {
    if (object != self.item) {
        self.selectionStyle     = UITableViewCellSelectionStyleNone;
        self.item               = object;
        self.webImageView.hidden   = NO;
        _defaultImageView.hidden = NO;
        self.webImageView.image = nil;
        
        self.containerView = [self viewWithTag:100];
        if (!self.containerView) {
            UIView *cView = [[UIView alloc] init];
            cView.userInteractionEnabled = YES;
            cView.clipsToBounds          = YES;
            cView.layer.masksToBounds    = YES;
            cView.layer.cornerRadius     = 3.0;
            cView.tag = 100;
            [self.contentView addSubview:cView];
            self.containerView = cView;
            [cView release];

          
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kImageSizeWidth, _item.imageHeight)];
            imgView.userInteractionEnabled = YES;
            imgView.exclusiveTouch = YES;
            imgView.backgroundColor = ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeDefault] ? [UIColor colorFromString:@"#f2f2f2"] : [UIColor colorFromString:@"#888888"]);
            //imgView.contentMode = UIViewContentModeScaleAspectFit;
            [self.containerView addSubview:imgView];
            [imgView release];
            self.webImageView = imgView;
            [self.webImageView addSubview:_defaultImageView];
            if (self.webImageView) {
                NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
                self.webImageView.alpha = [alpha floatValue];
            }
        }
        _defaultImageView.center = self.webImageView.center;
        //根据网路情况，图片路径设置显示图
        [self setImage];
        
        CGPoint fontsize = [SNUtility getNewsFontSizePoint];
        
        self.abstractLabel = (SNMTLabel *)[self viewWithTag:101];
        if (!self.abstractLabel) {
            SNMTLabel *mtLabel = [[SNMTLabel alloc] init];
            mtLabel.font = [UIFont systemFontOfSize:fontsize.x];
            
            NSString *titleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor];
            mtLabel.textColor = [UIColor colorFromString:titleColor];
            mtLabel.tag = 101;
            //add by sampanli
            mtLabel.menuDelegate=self;
            mtLabel.isNeedShowShare=YES;
            [self.contentView addSubview:mtLabel];
            [mtLabel release];
            self.abstractLabel = mtLabel;            
        } else {
            self.abstractLabel.font = [UIFont systemFontOfSize:fontsize.x];
        }
        
        UIImageView *arrow  = (UIImageView *)[self.contentView viewWithTag:102];
        if (!arrow) {
            NSString *name = [[SNThemeManager sharedThemeManager] themeFileName:@"arrow_up.png"];
            arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
            arrow.tag = 102;
            [self.contentView addSubview:arrow];
            [arrow release];
        }
        arrow.hidden = NO;
        arrow.frame = CGRectMake(12, (fontsize.y-15)/2, 15, 8);
        
        NSString *abstract = [SNUtility stringTrimming:self.item.photo.abstract];
        if (abstract && [abstract length] > 0) {
            self.abstractLabel.hidden = NO;
            [self.abstractLabel setLineHeight:fontsize.y];
            self.abstractLabel.text = [NSString stringWithFormat:@"%@%@",kAbstractPrefix, abstract];
        } else {
            [self.abstractLabel setLineHeight:0];
            self.abstractLabel.text = nil;
            self.abstractLabel.hidden = YES;
            arrow.hidden = YES;
        }
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [self.webImageView addGestureRecognizer:gesture];
        [gesture release];
    }
}

#pragma mark - NSMTlabelMenuDelegate
- (void)shareContent:(NSString*)content
{
    //去除左右空格
    NSString* text= [SNUtility stringTrimming:content];
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareContent:)]) {
        [self.delegate shareContent:text];
    }
}

- (void)loadImageWithUrl:(NSString *)url {
    [self.webImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            
            if(_item.photo.height == 0 || _item.photo.width == 0)
            {
                // 下载完成 这段代码留着的理由是：之前版本升级到4.2后，之前缓存在数据库中的文件没有width和height字段，所以原来缓存的图片按照原来老的定高定宽的显示方式展示
                CGRect frameFitScreen = [SNUtility calculateFrameToFitScreenBySize:self.webImageView.image.size defaultSize:self.imageSize];
                CGRect overflowRect   = [self.webImageView.image getOverflowRectByFillingRect:frameFitScreen byAnimation:kFadeOutAnimation];
                [self.webImageView setFrame:CGRectMake(-kImageLeftMargin, overflowRect.origin.y, overflowRect.size.width, overflowRect.size.height)];
            }

            // Fade动画
            [UIView animateWithDuration:.3 animations:^{
                _defaultImageView.hidden = YES;
            } completion:^(BOOL finished) {
            }];
        }
    }];
}

- (void)setImage {
    NSString *defautImgName = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"photo_list_click_default2.png" : @"photo_list_default2.png";
    NSString *iconImgName = [[SNThemeManager sharedThemeManager] themeFileName:defautImgName];
    [_defaultImage release];
    _defaultImage = [[UIImage imageNamed:iconImgName] retain];
    
    _defaultImageView.image = _defaultImage;
    _defaultImageView.size = CGSizeMake(_defaultImage.size.width, _defaultImage.size.height);
    
    _defaultImageView.center = self.webImageView.center;
    //网络图片
    if ([self.item.photo.url hasPrefix:@"http"])
    {
        if([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.item.photo.url]) {
            [self.webImageView setImageWithURL:[NSURL URLWithString:self.item.photo.url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image)
                {
                    _defaultImageView.hidden = YES;
                }
            }];
        }
        //启动下载
        else if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
            //[self.webImageView loadUrlPathWithUpdateFrame:self.item.photo.url];
            [self loadImageWithUrl:self.item.photo.url];
        }
        else {
            //self.webImageView.image = _defaultImage;
        }
    }
    else
    {
        self.webImageView.image = [UIImage sd_imageWithData:[NSData dataWithContentsOfFile:self.item.photo.url]];
        if (self.webImageView.image)
        {
            _defaultImageView.hidden = YES;
        }
    }

}
-(void)clickImage:(id)sender
{
    if (self.webImageView.image == nil) {
        if (![SNUtility getApplicationDelegate].isNetwork) {
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            return;
        }
        if ([self.item.photo.url hasPrefix:@"http"]) {
            [self loadImageWithUrl:self.item.photo.url];
        }
        else
        {
            self.webImageView.image = [UIImage sd_imageWithData:[NSData dataWithContentsOfFile:self.item.photo.url]];
            if (self.webImageView.image)
            {
                _defaultImageView.hidden = YES;
            }
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickImage:)]) {
            [self.delegate performSelector:@selector(clickImage:) withObject:self];
        }   
    }
}

- (void)updateTheme {
    if (self.webImageView) {
        [self setImage];
        NSString *alpha = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kImageAlpha];
        self.webImageView.alpha = [alpha floatValue];
    }
    UIImageView *arrow = (UIImageView *)[self.contentView viewWithTag:102];
    if (arrow) {
        NSString *name = [[SNThemeManager sharedThemeManager] themeFileName:@"arrow_up.png"];
        arrow.image = [UIImage imageNamed:name];
    }
    [self setNeedsDisplay];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    TT_RELEASE_SAFELY(abstractLabel);
    TT_RELEASE_SAFELY(containerView);
    [_webImageView cancelCurrentImageLoad];
    TT_RELEASE_SAFELY(_webImageView);
    TT_RELEASE_SAFELY(_item);
    TT_RELEASE_SAFELY(_defaultImage);
    TT_RELEASE_SAFELY(_defaultImageView);
    [super dealloc];
}

@end
