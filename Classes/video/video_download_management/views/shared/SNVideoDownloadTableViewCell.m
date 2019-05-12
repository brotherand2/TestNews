//
//  SNVideoDownloadTableViewCell.m
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideoDownloadTableViewCell.h"
#import "SNVideoDownloadTableViewController.h"

#define kVideoDownloadTableViewCellHeight                   (186/2.0f)

#define kHeadlineLabelMarginTop                             (30.0f/2.0f)
#define kHeadlineLabelMarginRight_Normal                    (10.0f)
#define kHeadlineLabelFontSize                              (38.0f/2.0f)
#define kHeadlineLabelHeight                                (84.0f/2.0f)
#define kHeadlineLabelWidth_Normal                          (kAppScreenWidth == 320.0 ? 200.0 : (kAppScreenWidth == 375.0 ? 255.0 : 294))//(400.0f/2.0f)
#define kHeadlineLabelWidth_Edit                            (kAppScreenWidth == 320.0 ? 165.0 : (kAppScreenWidth == 375.0 ? 220.0 : 259.0))//(330.0f/2.0f)
#define kHeadlineLabelNumberOfLines                         (2)

#define kThumbnailImageViewMarginLeft                       (10.0f)
#define kThumbnailImageViewMarginRight_Edit                 (76.0f/2.0f)
#define kThumbnailImageViewWidth                            (180.0f/2.0f)
#define KThumbnailImageViewHeight                           (130.0f/2.0f)

#define kCheckBoxWidth                                      (30.0f)
#define kCheckBoxHeight                                     (30.0f)
#define kCheckBoxMarginRight_Edit                           (3.0f)

@implementation SNVideoDownloadTableViewCell

#pragma mark - Static
+ (CGFloat)heightForRow {
    return kVideoDownloadTableViewCellHeight;
}

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor                = [UIColor clearColor];
        self.contentView.backgroundColor    = [UIColor clearColor];
        self.selectionStyle                 = UITableViewCellSelectionStyleNone;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [UIView drawCellSeperateLine:rect];
}

- (void)dealloc {
    
    [SNNotificationManager removeObserver:self];
    
}

#pragma mark - Ovrride
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        if ([_tableViewController respondsToSelector:@selector(didEndDisplayingCell:)]) {
            [_tableViewController didEndDisplayingCell:self];
        }
    }
}

#pragma mark - Public
- (void)setData:(SNVideoDataDownload *)data {
    self.model = data;
    
    //RENDER VIEW////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Thumbnail imageView
    if (!(self.thumnailImageView)) {
        self.thumnailImageView  = [[SNWebImageView alloc] initWithFrame:CGRectMake(kThumbnailImageViewMarginLeft,
                                                                                    ([SNVideoDownloadTableViewCell heightForRow]-KThumbnailImageViewHeight)/2.0f,
                                                                                    kThumbnailImageViewWidth,
                                                                                    KThumbnailImageViewHeight)];
        self.thumnailImageView.layer.cornerRadius   = 3;
        self.thumnailImageView.clipsToBounds        = YES;
        [self.thumnailImageView setDefaultImageMode:[UIImage themeImageNamed:@"rolling_default_image.png"]];
        self.thumnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.thumnailImageView];
    }
    
    //Headline label
    if (!(self.headlineLabel)) {
        self.headlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.thumnailImageView.right + 10,
                                                                        kHeadlineLabelMarginTop,
                                                                        kHeadlineLabelWidth_Normal,
                                                                        kHeadlineLabelHeight)];
        self.headlineLabel.backgroundColor   = [UIColor clearColor];
        self.headlineLabel.textAlignment     = NSTextAlignmentLeft;
        self.headlineLabel.numberOfLines     = kHeadlineLabelNumberOfLines;
        self.headlineLabel.font              = [UIFont systemFontOfSize:kHeadlineLabelFontSize];
        self.headlineLabel.lineBreakMode     = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.headlineLabel];
    }
    self.headlineLabel.textColor        = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDownloadTableViewCell_HeadlineTextColor]];
    if (!(self.model.isEditing)) {
        self.headlineLabel.width = kHeadlineLabelWidth_Normal;
    } else {
        self.headlineLabel.width = kHeadlineLabelWidth_Edit;
    }
    
    CGSize _onelineActureSize = [@"一行文本高度" sizeWithFont:[UIFont systemFontOfSize:kHeadlineLabelFontSize]
                                      constrainedToSize:CGSizeMake(self.headlineLabel.width, NSIntegerMax)
                                          lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize _actualSize = [self.model.title sizeWithFont:[UIFont systemFontOfSize:kHeadlineLabelFontSize]
                                     constrainedToSize:CGSizeMake(self.headlineLabel.width, NSIntegerMax)
                                         lineBreakMode:NSLineBreakByTruncatingTail];
    if (_actualSize.height > kHeadlineLabelNumberOfLines*_onelineActureSize.height) {
        _actualSize.height = kHeadlineLabelNumberOfLines*_onelineActureSize.height;
    }
    self.headlineLabel.height = _actualSize.height;
    
    //Checkbox
    if (!(self.checkBox)) {
        self.checkBox                   = [UIButton buttonWithType:UIButtonTypeCustom];
        self.checkBox.frame             = CGRectMake(kAppScreenWidth,
                                                     ([SNVideoDownloadTableViewCell heightForRow]-kCheckBoxHeight)/2.0f,
                                                     kCheckBoxWidth,
                                                     kCheckBoxHeight);
        [self.checkBox addTarget:self action:@selector(tapCheckBox:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.checkBox];
    }
    if (self.model.isEditing) {
        self.checkBox.left = kAppScreenWidth - kCheckBoxMarginRight_Edit - kCheckBoxWidth;
        if (self.model.isSelected) {
            [self.checkBox setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
        } else {
            [self.checkBox setBackgroundImage:[UIImage imageNamed:@"deselected.png"] forState:UIControlStateNormal];
        }
    } else {
        self.checkBox.left = kAppScreenWidth;

        [self.checkBox setBackgroundImage:[UIImage imageNamed:@"deselected.png"] forState:UIControlStateNormal];
    }
    
    
    //UPDATE DATA/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    self.headlineLabel.text = self.model.title;
    __weak __typeof(&*self)weakSelf = self;
    [self.thumnailImageView setUrlPath:self.model.poster completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        weakSelf.thumnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    }];
}

- (void)beginEdit {
    self.model.isEditing = YES;
    self.model.isSelected = NO;

    self.headlineLabel.width = kHeadlineLabelWidth_Edit;
    self.checkBox.left = self.contentView.width - kCheckBoxMarginRight_Edit - kCheckBoxWidth;

    [self.checkBox setBackgroundImage:[UIImage imageNamed:@"deselected.png"] forState:UIControlStateNormal];
}

- (void)finishEdit {
    self.model.isEditing = NO;
    self.model.isSelected = NO;

    self.headlineLabel.width = kHeadlineLabelWidth_Normal;
    self.checkBox.left = self.contentView.width;
    [self.checkBox setBackgroundImage:[UIImage imageNamed:@"deselected.png"] forState:UIControlStateNormal];
}

- (void)select {
    self.model.isSelected = YES;
    [self.checkBox setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
}

- (void)deselect {
    self.model.isSelected = NO;
    [self.checkBox setBackgroundImage:[UIImage imageNamed:@"deselected.png"] forState:UIControlStateNormal];
}

#pragma mark - Private
- (void)tapCheckBox:(UIButton *)checkBox {
    if (self.model.isSelected == NO) {
        self.model.isSelected = YES;

        [checkBox setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
    } else {
        self.model.isSelected = NO;
        [checkBox setBackgroundImage:[UIImage imageNamed:@"deselected.png"] forState:UIControlStateNormal];
    }
    
    if([_tableViewController respondsToSelector:@selector(didTapCheckBoxInCell:)]) {
        [_tableViewController didTapCheckBoxInCell:self];
    }
}

- (void)updateTheme {
    [self setNeedsDisplay];
}

@end
