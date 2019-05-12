//
//  SNCorpusPhotoAndTitleCell.m
//  sohunews
//
//  Created by Scarlett on 15/9/1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNCorpusPhotoAndTitleCell.h"
#import "NSCellLayout.h"
#import "SNCellImageView.h"
#import "SNCollectStateView.h"


#define kNewImageHeight ((kAppScreenWidth > 375.0) ? 286.0/3 : ((kAppScreenWidth == 375.0) ? 171.0/2 : 144.0/2))
#define kImageHeight ((kAppScreenWidth > 375.0) ? 219.0/3 : 126.0/2)
#define kImageWidth ((kAppScreenWidth > 375.0) ? 338.0/3 : 194.0/2)

@interface SNCorpusPhotoAndTitleCell () {
    SNCellImageView *_photoImageView;
    UILabel *_titleLabel;
    UILabel *_timeLabel;
    SNCollectStateView *_collectStateView;

}

@end

@implementation SNCorpusPhotoAndTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgImageView = [[UIView alloc] init];
        bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [self setSelectedBackgroundView:bgImageView];
        
        self.backgroundColor = [UIColor clearColor];
        [self setCellFrame];

        
        [self initSelectButton];
        [self initPhotoView];
        [self initTitleLabel];
        [self initTimeLabel];
        [self initStateView];

    }
    return self;
}

#pragma mark init
- (void)initPhotoView {
    int x = CONTENT_LEFT;
    
    CGFloat offHeight = kImageHeight;
    if ([SNUtility shownBigerFont]) {
        offHeight = kNewImageHeight;
    }
    CGRect imageViewRect = CGRectMake(x, (self.height - offHeight)/2, kImageWidth, kImageHeight);
    _photoImageView = [[SNCellImageView alloc] initWithFrame:imageViewRect];
    [_photoImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
    [self addSubview:_photoImageView];
}

- (void)initTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-CONTENT_LEFT*3 - _photoImageView.width, [SNUtility getNewsTitleFontSize]*3)];
        _titleLabel.left = _photoImageView.right + CONTENT_LEFT;
        _titleLabel.top = _photoImageView.top - 4;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
}

- (void)initTimeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
        _timeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
    }
}

- (void)initStateView {
    if (_collectStateView == nil) {
        _collectStateView = [[SNCollectStateView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 0, kAppScreenWidth - _timeLabel.width, 0)];
        _collectStateView.bottom = self.height;
        [self addSubview:_collectStateView];
    }
}

- (void)setCellInfoWithUrl:(NSString *)url newsType:(NSString *)newsType title:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link hasTV:(BOOL)hasTV isItemSelected:(BOOL)isItemSelected  hideStateView:(BOOL)hide  status:(NSString *)status remark:(NSString *)remark {
    _collectStateView.hidden = hide;
    if ([status isEqualToString:@"2"]) {
        _collectStateView.collectState = SNCollectStatePublished;
    } else {
        _collectStateView.collectState = SNCollectStateUnaudited;
    }
    if (remark.length > 0) {
        _collectStateView.stateMessage = remark;
    }
    [_photoImageView updateImageWithUrl:url
                           defaultImage:[UIImage imageNamed:kThemeImgPlaceholder3]
                              showVideo:hasTV];
    [_photoImageView updateTheme];
    
    _titleLabel.text = title;
    _timeLabel.text = [NSDate relativelyDate:time];
    [_timeLabel sizeToFit];
    _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
    [self resetLabel];
    
    self.frame = CGRectMake(0, 0, kAppScreenWidth, [SNCorpusPhotoAndTitleCell getCellHeight:title isEditMode:isEditMode]);
    
    self.idsString = ids;
    self.linkString = link;
    if (isEditMode) {
        [self setEditMode];
    }
    else {
        [self setNormalMode];
    }
    _collectStateView.centerY = _timeLabel.centerY;
    if (_titleLabel.bottom <= _photoImageView.bottom) {
        _collectStateView.left = _titleLabel.left;
    } else {
        _collectStateView.left = CONTENT_LEFT;
    }
    _selectButton.centerY = self.height/2;
    _selectButton.selected = isItemSelected;
}

- (void)resetLabel {
    _titleLabel.font = [SNUtility getNewsTitleFont];
    if ([SNUtility shownBigerFont]) {
        _titleLabel.numberOfLines = 3;
    }
    else {
        _titleLabel.numberOfLines = 2;
    }
    [_titleLabel sizeToFit];
        
    [_timeLabel sizeToFit];
    _timeLabel.right = kAppScreenWidth - CONTENT_LEFT;
    if ([self isTitlelabelMultiLine]) {
        if (kAppScreenWidth == 320.0) {
            _timeLabel.top = _photoImageView.bottom + 15.0;
        }
        else {
            _timeLabel.top = _photoImageView.bottom + 20.0;
        }
    }
    else {
        _timeLabel.bottom = _photoImageView.bottom + 5.0;
    }
    
}


- (void)updateTheme {
    [super updateTheme];
    _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
    _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
    [_photoImageView updateTheme];
}

- (void)setCellFrame {
    CGFloat offHeight = kImageHeight;
    if ([SNUtility shownBigerFont]) {
        offHeight = kNewImageHeight;
    }
    self.frame = CGRectMake(0, 0, kAppScreenWidth, CONTENT_LEFT*2 + offHeight + 5.0);
}

+ (CGFloat)getCellHeight:(NSString *)title isEditMode:(BOOL)isEditMode {
    CGFloat offHeight = kImageHeight;
    CGFloat width = kAppScreenWidth - CONTENT_LEFT*3 - kImageWidth;
    if (isEditMode) {
        width = kAppScreenWidth - CONTENT_LEFT*4 - kImageWidth;
    }
    UIFont *font = [SNUtility getNewsTitleFont];
    CGRect rect = [title boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGSize textSize = [title sizeWithAttributes:@{NSFontAttributeName : font}];
    CGFloat lines = rect.size.height/textSize.height;
    if ([SNUtility shownBigerFont] && lines > 2) {
        offHeight = kNewImageHeight;
    }
    return CONTENT_LEFT*2 + offHeight + 5.0;
}

- (void)setEditMode {

    _selectButton.left = kSelectButtonLeftDistance;
    _photoImageView.left = kSelectButtonLeftDistance*2 + _selectButton.width;
    _titleLabel.left = _photoImageView.right + CONTENT_LEFT;
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT*2 - _photoImageView.right;
}

- (void)setNormalMode {
    
    _selectButton.right = 0;
    _photoImageView.left = CONTENT_LEFT;
    _titleLabel.left = _photoImageView.right + CONTENT_LEFT;
    _titleLabel.width = kAppScreenWidth - CONTENT_LEFT*3 - _photoImageView.width;
}

- (BOOL)isTitlelabelMultiLine {
    UILabel *label = [[UILabel alloc] init];
    label.font = [SNUtility getNewsTitleFont];
    label.text = kUniversalTitle;
    label.numberOfLines = 2;
    label.width  = kAppScreenWidth - CONTENT_LEFT*2;
    [label sizeToFit];
    
    if ((_titleLabel.height/label.height) > 2) {
        return YES;
    }
    return NO;
}


@end
