//
//  SNFeedBackImageCell.m
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackImageCell.h"
#import "SNFeedBackImageModel.h"
#import "UIImage+Utility.h"
#import "SNWaitingActivityView.h"
#import "SNGalleryPhotoView.h"
#import "SNUserManager.h"

@interface SNFeedBackImageCell ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) SNFeedBackImageModel *imageModel;
@property (nonatomic, strong) SNWaitingActivityView *sendingIndicator;
@property (nonatomic, strong) SNGalleryPhotoView *imageDetailView;

@end
static CGRect oldframe;
@implementation SNFeedBackImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    _fbImageView = [[UIImageView alloc] init];
    _fbImageView.contentMode = UIViewContentModeScaleAspectFit;
    _fbImageView.userInteractionEnabled = YES;
    _fbImageView.layer.cornerRadius = 2;
    _fbImageView.layer.masksToBounds = YES;
    [self.chatBubble addSubview:_fbImageView];
    self.nameLabel.textAlignment = NSTextAlignmentRight;
    
    _sendingIndicator = [[SNWaitingActivityView alloc] init];
    
    [self.contentView addSubview:_sendingIndicator];
    _sendingIndicator.hidden = YES;
    
    
    // 点击大图浏览
    [self.fbImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoBrower:)]];
    
}


- (void)setDataWithModel:(SNFeedBackImageModel *)fbModel {
    _imageModel = fbModel;
    self.nameLabel.text = @"搜狐网友";
    self.iconView.image = [UIImage imageNamed:@"feedBack_defaultIcon_v5.png"];
    if ([SNUserManager isLogin]) {
        self.nameLabel.text = [SNUserManager getNickName];
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:[SNUserManager getHeadImageUrl]] placeholderImage:[UIImage imageNamed:@"feedBack_defaultIcon_v5.png"]];
        if ([SNThemeManager sharedThemeManager].isNightTheme) {
            self.iconView.alpha = 0.5;
        } else {
            self.iconView.alpha = 1;
        }
    }
    if (fbModel.date.length > 0) {
        self.dateLabel.text = [fbModel.date getDateFormate];
    }
    
    UIImage *rightImage = [UIImage imageNamed:@"icofeedback_rightbackground_v5.png"];
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        self.chatBubble.alpha = 0.5;
    }
    
    self.chatBubble.image = [rightImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 20, 10, 20)];
    [self setFrameWithModel:fbModel];
}

- (void)setFrameWithModel:(SNFeedBackImageModel *)fbModel {
    if (!fbModel.isHideDate) {
        self.dateLabel.hidden = NO;
        self.dateLabel.frame = CGRectMake(0, kFBDateTopMargin, kAppScreenWidth, 11);
        self.iconView.frame = CGRectMake(kAppScreenWidth - kFBIconLeftMargin - kFBIconWidth, kFBNameTopMargin + CGRectGetMaxY(self.dateLabel.frame), kFBIconWidth, kFBIconWidth);
    } else {
        self.dateLabel.hidden = YES;
        self.iconView.frame = CGRectMake(kAppScreenWidth - kFBIconLeftMargin - kFBIconWidth, kFBDateTopMargin, kFBIconWidth, kFBIconWidth);
    }
    
    CGSize nameSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kThemeFontSizeB]} context:nil].size;
    CGFloat nameX = (self.iconView.left - kFBNameLeftMargin - nameSize.width);
    self.nameLabel.frame = CGRectMake(nameX, self.iconView.top, nameSize.width, 11);
    CGSize imageSize;
    if (fbModel.navImage == nil) {
        imageSize = [UIImage getImageWithSize:CGSizeMake(fbModel.imgWidth, fbModel.imgHeight) resizeWithMaxSize:CGSizeMake(kFBImageWidth, kFBImageHeight)];
    } else {
        imageSize = [UIImage getImageWithSize:fbModel.navImage.size resizeWithMaxSize:CGSizeMake(kFBImageWidth, kFBImageHeight)];
    }
    self.chatBubble.frame = CGRectMake(self.nameLabel.right + 10 - imageSize.width, self.nameLabel.bottom + kFBNameTopMargin, imageSize.width + 8, imageSize.height);
    self.fbImageView.frame = CGRectMake(0, 0, imageSize.width,imageSize.height);
    if (fbModel.isSendFaild) {
        self.warningView.hidden = NO;
        self.warningView.frame = CGRectMake(self.chatBubble.left - kFBWarningWidth, self.chatBubble.top, kFBWarningWidth, kFBWarningWidth);
    } else {
        self.warningView.hidden = YES;
    }
    if (fbModel.navImage != nil) {
        self.fbImageView.image = fbModel.navImage;
    } else {
        _sendingIndicator.hidden = NO;
        _sendingIndicator.origin = CGPointMake(self.chatBubble.left - _sendingIndicator.width - 5, CGRectGetMinY(self.chatBubble.frame) + CGRectGetHeight(self.chatBubble.frame)/2 - CGRectGetHeight(_sendingIndicator.frame)/2);
        __weak typeof(self)weakself = self;
        [self.fbImageView sd_setImageWithURL:[NSURL URLWithString:fbModel.imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _sendingIndicator.hidden = YES;
            if (error) {
                weakself.fbImageView.image = [UIImage imageNamed:@"icofeedback_picture_v5.png"];
            }
        }];
    }
    
}

- (void)photoBrower:(UITapGestureRecognizer *)recognizer {
    [self showImage];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - openCommentImage
- (void)showImage {
    if (_imageDetailView == nil) {
    
        _imageDetailView = [[SNGalleryPhotoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _imageDetailView.downloadBtn.hidden = YES;
    }
    if (self.imageModel.navImage != nil) {
        _imageDetailView.image = self.imageModel.navImage;
    }
    [_imageDetailView loadImageWithUrlPath:self.imageModel.originalImageUrl];
    
    [[TTNavigator navigator].topViewController.flipboardNavigationController.view addSubview:_imageDetailView];
    
    _imageDetailView.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _imageDetailView.alpha = 1.0;
    }];
}


@end
