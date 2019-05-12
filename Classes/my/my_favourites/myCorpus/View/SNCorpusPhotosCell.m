//
//  SNCorpusPhotosCell.m
//  sohunews
//
//  Created by Scarlett on 15/9/1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNCorpusPhotosCell.h"
#import "SNCellImageView.h"
#import "NSCellLayout.h"
#import "SNCollectStateView.h"

#define kPhotoViewCount (3)
#define kImageHeight ((kAppScreenWidth > 375.0) ? 240.0/3 : ((kAppScreenWidth == 320.0) ? 120/2.0 : 144/2.0))
#define kImageWidth ((kAppScreenWidth > 375.0) ? 370.0/3 : ((kAppScreenWidth == 320.0) ? 184/2.0 : 222/2.0))
#define kBetweenImageDiatance ((kAppScreenWidth > 375.0) ? 24.0/3 : ((kAppScreenWidth == 320.0) ? 16/2.0 : 14/2.0))
#define kTitleLableTopDistance 5
#define kTitleLableBottomDistance ((kAppScreenWidth > 375.0) ? 17.0/3 : 10/2.0)
#define kImageBottomDistance (36/2 + 6.0)

@interface SNCorpusPhotosCell () {

    NSMutableArray *_imageViewArray;
    NSArray *_imageUrlArray;
    
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    SNCollectStateView *_collectStateView;
    
    CGSize _titleSize;
}
@end

@implementation SNCorpusPhotosCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgImageView = [[UIView alloc] init];
        bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [self setSelectedBackgroundView:bgImageView];
        _titleSize = [kCorpusFolderName getTextSizeWithFontSize:[SNUtility getNewsTitleFontSize]];
        [self setCellFrame];
        
        _imageViewArray = [[NSMutableArray alloc] init];
        
        [self initSelectButton];
        [self initTitleLabel];
        [self initPhotoView];
        [self initTimeLabel];
        [self initStateView];
    }
    return self;
}

- (void)setCellInfoWithUrlArray:(NSArray *)urlArray newsType:(NSString *)newsType title:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link isItemSelected:(BOOL)isItemSelected  hideStateView:(BOOL)hide status:(NSString *)status remark:(NSString *)remark {
    _imageUrlArray = [NSArray arrayWithArray:urlArray];
    if ([_imageUrlArray count] > 0) {
        [self updateGroupImages];
    }
    _collectStateView.hidden = hide;
    if ([status isEqualToString:@"2"]) {
        _collectStateView.collectState = SNCollectStatePublished;
    } else {
        _collectStateView.collectState = SNCollectStateUnaudited;
    }
    if (remark.length > 0) {
        _collectStateView.stateMessage = remark;
    }
    _titleLabel.text = title;
    _timeLabel.text = [NSDate relativelyDate:time];
    [_timeLabel sizeToFit];
    _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
    [self resetLabel];
    
    self.idsString = ids;
    self.linkString = link;
    
    if (isEditMode) {
        [self setEditMode];
    }
    else {
        [self setNormalMode];
    }
    _selectButton.centerY = self.height/2;
    _selectButton.selected = isItemSelected;
}

- (void)resetLabel {
    _titleLabel.font = [SNUtility getNewsTitleFont];
    [_titleLabel sizeToFit];
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT*2;
    
    [self resetGroupImagesPoint];
    [self setCellFrame];
    
    if ([_imageUrlArray count] > 0) {
        SNCellImageView *photoImageView = [_imageViewArray objectAtIndex:0];
        _timeLabel.top = photoImageView.bottom + 4;
        _collectStateView.centerY = _timeLabel.centerY;
    }
}

- (void)initTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTitleLableTopDistance, kAppScreenWidth-CONTENT_LEFT*2, [SNUtility getNewsTitleFontSize])];
        _titleLabel.left = CONTENT_LEFT;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
        _titleLabel.font = [SNUtility getNewsTitleFont];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
    }
}

- (void)initPhotoView {
    int x = CONTENT_LEFT;
    for (int i = 0; i < kPhotoViewCount; i++) {
        CGRect imageViewRect = CGRectMake(x, _titleLabel.bottom + kTitleLableBottomDistance, kImageWidth, kImageHeight);
        SNCellImageView *photoImageView = [[SNCellImageView alloc] initWithFrame:imageViewRect];
        [photoImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
        [_imageViewArray addObject:photoImageView];
        [self addSubview:photoImageView];
        x += kImageWidth + kBetweenImageDiatance;
    }
}

- (void)initTimeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-CONTENT_LEFT*3, _titleSize.height)];
        _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
        _timeLabel.bottom = self.bottom;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
        _timeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
    }
}

- (void)initStateView {
    if (_collectStateView == nil) {
        _collectStateView = [[SNCollectStateView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 0, kAppScreenWidth - _timeLabel.width, _titleSize.height)];
        _collectStateView.bottom = self.height;
        [self addSubview:_collectStateView];
    }
}

- (void)updateGroupImages {
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [_imageViewArray objectAtIndex:i];
        photoImageView.hidden = NO;
        
        NSString *imageUrl = nil;
        if (i < [_imageUrlArray count]) {
            imageUrl = [_imageUrlArray objectAtIndex:i];
        }
        
        [photoImageView updateImageWithUrl:imageUrl defaultImage:[UIImage imageNamed:kThemeImgPlaceholder3] showVideo:NO];
        [photoImageView updateTheme];
    }
}

- (void)resetGroupImagesPoint {
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [_imageViewArray objectAtIndex:i];
        photoImageView.top = _titleLabel.bottom + kTitleLableBottomDistance;
    }
}

- (void)updateTheme {
    [super updateTheme];
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [_imageViewArray objectAtIndex:i];
        [photoImageView updateTheme];
        [photoImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
    }
    _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
    _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
}

- (void)setCellFrame {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, kAppScreenWidth, kTitleLableTopDistance + _titleLabel.height + kTitleLableBottomDistance + kImageHeight + kImageBottomDistance);
}

+ (CGFloat)getCellHeight:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.font = [SNUtility getNewsTitleFont];
    label.text = title;
    label.numberOfLines = 2;
    label.width  = kAppScreenWidth-CONTENT_LEFT*2;
    [label sizeToFit];
    return kTitleLableTopDistance + label.height + kTitleLableBottomDistance + kImageHeight + kImageBottomDistance;
}

- (void)setEditMode {
    
    _selectButton.left = kSelectButtonLeftDistance;
    _titleLabel.left = _selectButton.right + kSelectButtonLeftDistance;
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT - _selectButton.right - kSelectButtonLeftDistance;
    int x = _selectButton.right + kSelectButtonLeftDistance;
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [_imageViewArray objectAtIndex:i];
        photoImageView.left = x;
        x += kImageWidth + kBetweenImageDiatance;
    }
}

- (void)setNormalMode {
    
    _selectButton.right = 0;
    _selectButton.selected = NO;
    _titleLabel.left = CONTENT_LEFT;
    _titleLabel.width = kAppScreenWidth-CONTENT_LEFT*2;
    int x = CONTENT_LEFT;
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [_imageViewArray objectAtIndex:i];
        photoImageView.left = x;
        x += kImageWidth + kBetweenImageDiatance;
    }
}

@end
