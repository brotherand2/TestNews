//
//  SNRollingNewsFunnyTextCell.m
//  sohunews
//
//  Created by H on 16/4/20.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//
#define kPublicImageViewWidth      ([[SNDevice sharedInstance] isPlus] ? (154 / 3.f) : (78 / 2.f))
#define kDownloadImageViewWidth    ([[SNDevice sharedInstance] isPlus] ? (120 / 3.f) : (60 / 2.f))

#define kImageViewTop ([[SNDevice sharedInstance] isPlus] ? 7 : 12)
#define kCommonSpace  ([[SNDevice sharedInstance] isPlus] ? (42 / 3.f) : (28 / 2.f))
#define kIS_6_PLUS    ([UIScreen mainScreen].bounds.size.width > 750 / 2.f)

#define kDefaultCellHeight          (250 / 2.f)
#define kLimitCharacterNum          (48)
#define kBottomAreaHeight           (35)
#define kHotCommentAreaHeight       ([[SNDevice sharedInstance] isPlus] ? (50 / 2.f) : (40 / 2.f))
#define kLittleSpace                (0)
#define kSpace                      (15 / 2.f)
#define kMaxImageHeight             (660 / 2.f)
#define kMinImageHeight             (372 / 2.f)
#define kCellsSpaceTop              (7.f)
#define kCellsSpaceBottom           (7.f)
#define kPraiseJSKitName            (@"PraiseList")

#import "SNRollingNewsFunnyTextCell.h"
#import "UIFont+Theme.h"
#import "YYText.h"
#import "SNNewsGallerySlidershowController.h"
#import "OLImageView.h"
#import "UIImage+GIF.h"
#import "SNImageView.h"
#import "SHUrlMaping.h"
#import <JsKitFramework/JsKitStorage.h>
#import <JsKitFramework/JsKitStorageManager.h>
#import "SNActionMenuController.h"
#import "TMCache.h"
#import "SNNewsShareManager.h"

@protocol SNRollingNewsFunnyTextHotCommentDelegate <NSObject>
- (void)openJokeNews;
@end

@interface SNRollingNewsFunnyTextHotComment : UIView
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *hotComment;
@property (nonatomic, strong) YYLabel *authorLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *comment;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, weak) id openJokeNewsDelegate;
@end

@implementation SNRollingNewsFunnyTextHotComment

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initContent];
    }
    return self;
}

- (void)initContent {
    _authorLabel = [[YYLabel alloc] initWithFrame:CGRectMake(11, 0, self.width, self.height)];
    _authorLabel.text = _author;
    _authorLabel.numberOfLines = 2;
    _authorLabel.textAlignment = NSTextAlignmentLeft;
    _authorLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    _authorLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    [self addSubview:_authorLabel];
    
    self.backgroundColor = SNUICOLOR(kThemeBg2Color);
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 1;
    
    _comment = [UIButton buttonWithType:UIButtonTypeCustom];
    _comment.frame = CGRectMake(0, 0, self.width, self.height);
    [_comment addTarget:self action:@selector(openJoke)
       forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_comment];
}

- (void)openJoke {
    if (self.openJokeNewsDelegate &&
        [self.openJokeNewsDelegate respondsToSelector:@selector(openJokeNews)]) {
        [self.openJokeNewsDelegate openJokeNews];
    }
}

- (void)updateContent {
    if (_author.length > 0 && _hotComment.length > 0) {
        UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeB];

        NSMutableAttributedString *author = [NSMutableAttributedString new];
        [author appendAttributedString:[[NSAttributedString alloc] initWithString:_author]];
        author.yy_color = SNUICOLOR(kThemeBlue1Color);
        author.yy_font = font;
        NSMutableAttributedString *comment = [[NSMutableAttributedString alloc] initWithString:_hotComment];
        comment.yy_color = SNUICOLOR(kThemeText4Color);
        comment.yy_font = font;
        [author appendAttributedString:comment];
        
        author.yy_alignment = NSTextAlignmentLeft;
        author.yy_font = font;
        _authorLabel.numberOfLines = 2;
        _authorLabel.attributedText = author;
        CGSize size = CGSizeMake(self.width - 22,2000);
        CGSize labelsize = [[_author stringByAppendingString:_hotComment] sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
        CGFloat height = labelsize.height;
        if (height > kHotCommentAreaHeight) {
            height = 2 * kHotCommentAreaHeight;
        } else {
            height = kHotCommentAreaHeight;
        }
        self.frame = CGRectMake(self.origin.x, self.origin.y, self.width, height);
        _comment.frame = CGRectMake(0, 0, self.width, height);
        _authorLabel.frame = CGRectMake(11, 0, self.width - 22,height);
    }
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kThemeBg2Color);
    _authorLabel.textColor = SNUICOLOR(kThemeBlue1Color);
}

@end

@protocol SNRollingNewsFunnyTextContentDelegate <NSObject>
- (void)expandWithButton:(UIButton *)button;
- (void)moreAction:(UIButton *)button;
- (void)openSlidesImages;
- (void)opt:(BOOL)isHot;
- (void)openJokeNewsFromHotComment;
@end

@interface SNRollingNewsFunnyTextContent : UIView <SNRollingNewsFunnyTextHotCommentDelegate>
@property (nonatomic, strong) YYLabel *contentTextLabel;
@property (nonatomic, strong) UIButton *toggleButton;   //展开收起
@property (nonatomic, strong) UIButton *praiseButton;   //点赞
@property (nonatomic, strong) UIImageView *praiseImgae; //点赞
@property (nonatomic, strong) UILabel *praiselabel;     //点赞
@property (nonatomic, strong) UIButton *commentButton;  //评论
@property (nonatomic, strong) UIImageView *commentImgae;//评论
@property (nonatomic, strong) UILabel *commentlabel;    //评论

@property (nonatomic, strong) UIButton *boringButton;   //没劲
@property (nonatomic, strong) UIButton *imageButton;    //图片btn
@property (nonatomic, strong) UILabel *signLabel;       //段子标识
@property (nonatomic, strong) UIButton *moreButton;     //更多
@property (nonatomic, strong) SNImageView *imageView;   //图片
@property (nonatomic, strong) SNRollingNewsFunnyTextHotComment *hotCommentView;//热门评论区
@property (nonatomic, copy) NSString *link;

@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign) BOOL hasHotComment;
@property (nonatomic, weak) id <SNRollingNewsFunnyTextContentDelegate>delegate;
@end

@implementation SNRollingNewsFunnyTextContent

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self updateTheme];
    }
    return self;
}

- (void)initSubviews {
    _contentTextLabel = [[YYLabel alloc] initWithFrame:CGRectMake(kCommonSpace, 0, self.frame.size.width - 2 * kCommonSpace, 0)];
    _contentTextLabel.numberOfLines = 0;
    _contentTextLabel.userInteractionEnabled = YES;
    _contentTextLabel.font = [SNUtility getNewsTitleFont];
    _contentTextLabel.textColor = SNUICOLOR(kThemeText2Color);
    _contentTextLabel.textAlignment = NSTextAlignmentJustified;
    [self addSubview:_contentTextLabel];
    
    _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_toggleButton setFrame:CGRectMake(kAppScreenWidth - 40 - kCommonSpace,
                                       0, 40, 30)];
    _toggleButton.bottom = _contentTextLabel.bottom;
    _toggleButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [_toggleButton addTarget:self action:@selector(toggle:)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_toggleButton];

    _imageView = [[SNImageView alloc] initWithFrame:CGRectMake(kCommonSpace, 0, self.frame.size.width - 2 * kCommonSpace, 660 / 2.f)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.clipsToBounds = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.defaultImage = [UIImage themeImageNamed:@"bg_defaultpic3_v5.png"];
    _imageView.hidden = YES;
    [self addSubview:_imageView];
    
    _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _imageButton.frame = CGRectMake(kCommonSpace, 0, self.frame.size.width - 2 * kCommonSpace, 660 / 2.f);
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        _imageButton.backgroundColor = [UIColor blackColor];
        _imageButton.alpha = 0.5f;
    } else {
        _imageButton.backgroundColor = [UIColor clearColor];
    }
    [_imageButton addTarget:self action:@selector(openBigImageSlide)
           forControlEvents:UIControlEventTouchUpInside];
    _imageButton.hidden = YES;
    [self addSubview:_imageButton];
    
    _hotCommentView = [[SNRollingNewsFunnyTextHotComment alloc] initWithFrame:CGRectMake(_contentTextLabel.left, 0, _contentTextLabel.width, kHotCommentAreaHeight)];
    _hotCommentView.top = _contentTextLabel.bottom;
    _hotCommentView.hidden = YES;
    _hotCommentView.link = self.link;
    _hotCommentView.openJokeNewsDelegate = self;
    [self addSubview:_hotCommentView];
    
    _praiseImgae = [[UIImageView alloc] initWithFrame:CGRectMake(kCommonSpace, 0, 12, 12)];
    _praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_qs_v5.png"];
    [self addSubview:_praiseImgae];
    _praiselabel = [[UILabel alloc] initWithFrame:CGRectMake(_praiseImgae.right + 4, 0, 60, 20)];
    _praiselabel.textColor = SNUICOLOR(kThemeText4Color);
    _praiselabel.textAlignment = NSTextAlignmentLeft;
    _praiselabel.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeB]];
    [self addSubview:_praiselabel];
    
    _praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_praiseButton setFrame:CGRectMake(kCommonSpace, 0, 60, 20)];
    _praiseButton.bottom = self.bottom - kLittleSpace;
    _praiseImgae.centerY = _praiseButton.centerY;
    _praiselabel.centerY = _praiseImgae.centerY;
    [_praiseButton addTarget:self action:@selector(praise:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_praiseButton];

    _commentImgae = [[UIImageView alloc] initWithFrame:CGRectMake(kCommonSpace + _praiseButton.right, 0, 12, 12)];
    _commentImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"];
    [self addSubview:_commentImgae];
    _commentlabel = [[UILabel alloc] initWithFrame:CGRectMake(_commentImgae.right + 4, 0, 60, 20)];
    _commentlabel.textColor = SNUICOLOR(kThemeText4Color);
    _commentlabel.textAlignment = NSTextAlignmentLeft;
    _commentlabel.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeB]];
    [self addSubview:_commentlabel];

    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentButton setFrame:CGRectMake(kCommonSpace + _praiseButton.right,
                                        0, 60, 20)];
    _commentButton.bottom = self.bottom - kLittleSpace;
    _commentImgae.centerY = _commentButton.centerY;
    _commentlabel.centerY = _commentImgae.centerY;
    [_commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_commentButton];

    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setFrame:CGRectMake(kCommonSpace + _praiseButton.right, 0, 30, 30)];
    _moreButton.bottom = self.bottom - kLittleSpace;
    _moreButton.right = self.right - kCommonSpace;
    [_moreButton setTitle:@"" forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmall_v5.png"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmallpress_v5.png"] forState:UIControlStateHighlighted];
    [_moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreButton];

    _signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    _signLabel.bottom = self.bottom - kLittleSpace;
    _signLabel.right = _moreButton.left - kCommonSpace + _moreButton.imageView.left;
    _signLabel.numberOfLines = 1;
    _signLabel.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeB]];
    _signLabel.textColor = SNUICOLOR(kThemeText4Color);
    _signLabel.textAlignment = NSTextAlignmentRight;
    _signLabel.text = @"段子";
    [self addSubview:_signLabel];
}

- (void)toggle:(UIButton *)toggleButton {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(expandWithButton:)]) {
        [self.delegate expandWithButton:toggleButton];
    }
}

- (void)praise:(UIButton *)praiseButton {
    praiseButton.selected = !praiseButton.selected;
    
    if (!praiseButton.selected) {
        _praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"];
    } else {
        _praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_clicked_v5.png"];
    }

    if (praiseButton.selected) {
        UILabel *tips = [[UILabel alloc] initWithFrame:CGRectMake(praiseButton.origin.x, 0, praiseButton.width, praiseButton.height)];
        tips.bottom = praiseButton.top;
        tips.centerX = _praiseImgae.right;
        tips.textAlignment = NSTextAlignmentCenter;
        tips.textColor = SNUICOLOR(kThemeText4Color);
        tips.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeB]];
        tips.text = @"+ 1";
        [self addSubview:tips];
        
        [UIView animateWithDuration:0.5 animations:^{
            tips.alpha = 0;
        } completion:^(BOOL finished) {
            [tips removeFromSuperview];
        }];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(opt:)]) {
        [self.delegate opt:praiseButton.selected];
    }
}

- (void)comment:(UIButton *)commentButton {
    [self openJokeNews];
}

- (void)openJokeNews {
    if (self.delegate && [self.delegate respondsToSelector:@selector(openJokeNewsFromHotComment)]) {
        [self.delegate openJokeNewsFromHotComment];
    }
}

- (void)more:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreAction:)]) {
        [self.delegate moreAction:button];
    }
}

- (void)openBigImageSlide{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(openSlidesImages)]) {
        [self.delegate openSlidesImages];
    }
}

- (void)updateTheme {
    if (_isExpand) {
        _praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_qs_v5.png"];
    } else {
        _praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"];
    }
    _praiselabel.textColor = SNUICOLOR(kThemeText4Color);
    _commentImgae.image = [UIImage themeImageNamed:@"icohome_commentsmall_v5.png"];
    _commentlabel.textColor = SNUICOLOR(kThemeText4Color);
    
    [_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmall_v5.png"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage themeImageNamed:@"icohome_moresmallpress_v5.png"] forState:UIControlStateHighlighted];
    _signLabel.textColor = SNUICOLOR(kThemeText4Color);
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        _imageButton.backgroundColor = [UIColor blackColor];
        _imageButton.alpha = 0.5f;
    } else {
        _imageButton.backgroundColor = [UIColor clearColor];
    }
    [self.hotCommentView updateTheme];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat expandExt = 0;
    if (_isExpand) {
        expandExt = 10;
    } else {
        expandExt = 0;
    }
    _toggleButton.bottom = _contentTextLabel.bottom;
    _toggleButton.frame = CGRectMake(_contentTextLabel.origin.x, _contentTextLabel.origin.y, _contentTextLabel.size.width, _contentTextLabel.size.height - 20);
    
    _praiseButton.bottom = self.height - expandExt;
    _commentButton.bottom = self.height - expandExt;
    _moreButton.bottom = self.height - expandExt;
    _signLabel.bottom = self.height - expandExt;
    
    _hotCommentView.link = self.link;
    if (_hasImage) {
        _imageView.top = _contentTextLabel.bottom + kSpace;
        _imageButton.top = _contentTextLabel.bottom + kSpace;
        _hotCommentView.top = _imageView.bottom + kSpace;
        if (_isExpand) {
            _praiseButton.top = _imageView.bottom + kSpace;
            _commentButton.top = _imageView.bottom + kSpace;
            _moreButton.top = _imageView.bottom + kSpace;
            _signLabel.top = _imageView.bottom + kSpace;
        }
    } else {
        _hotCommentView.top = _contentTextLabel.bottom + kSpace;
    }
    
    if (_hasHotComment && _isExpand) {
        _praiseButton.top = _hotCommentView.bottom + kSpace;
        _commentButton.top = _hotCommentView.bottom + kSpace;
        _moreButton.top = _hotCommentView.bottom + kSpace;
        _signLabel.top = _hotCommentView.bottom + kSpace;
    }
    _commentImgae.centerY = _commentButton.centerY;
    _commentlabel.centerY = _commentButton.centerY;
    _praiseImgae.centerY = _praiseButton.centerY;
    _praiselabel.centerY = _praiseButton.centerY;
    _moreButton.bottom = _commentButton.bottom;
    _signLabel.centerY = _commentButton.centerY;
}

@end

@interface SNRollingNewsFunnyTextCell ()<SNRollingNewsFunnyTextContentDelegate,SNNewsGallerySlidershowControllerDelegate,SNCellMoreViewShareDelegate>
@property (nonatomic, strong) SNRollingNewsFunnyTextContent *textContentView;
@property (nonatomic, strong) SNNewsGallerySlidershowController *photoCtl;
@property (nonatomic, strong) SNAnalyticsNewsReadTimer *analyticsTimer;
@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) SNNewsShareManager *shareManager;

@property (nonatomic, assign) BOOL isFullContent;
@property (nonatomic, assign) CGFloat unExpandTextHeight;
@property (nonatomic, strong) UIButton *togbtn;
@end

@implementation SNRollingNewsFunnyTextCell

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    return [self getCellHeightWith:newsItem];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initContent];
        [SNNotificationManager addObserver:self selector:@selector(prasisedInArticle:) name:@"com.sohu.newssdk.action.setting.duanziPraiseStatus" object:nil];
    }
    return self;
}

+ (float)getCellHeightWith:(SNRollingNewsTableItem *)item {
    CGFloat commentHeight = 0;
    CGFloat imageHeight = 0;
    CGFloat expandExt = 0;
    NSString *expandState = [[TMCache sharedCache] objectForKey:item.news.newsId];
    if (expandState.length > 0) {
        item.isExpand = [expandState isEqualToString:@"1"];
    }
    NSString *contentString = item.news.funnyText.content;
    if (!item.isExpand && contentString.length > kLimitCharacterNum) {
        contentString = [contentString substringWithRange:NSMakeRange(0,kLimitCharacterNum)];
        contentString = [NSString stringWithFormat:@"%@...",contentString];
    }
    if (item.isExpand) {
        if (item.hasHotcomment) {
            CGSize size = CGSizeMake(kAppScreenWidth - 2 * kCommonSpace - 22, 2000);
            CGSize labelsize = [[item.news.funnyText.hotcomment_author stringByAppendingString:item.news.funnyText.hotcomment_content] sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
            CGFloat height = labelsize.height;
            if (height > kHotCommentAreaHeight) {
                height = 2 * kHotCommentAreaHeight;
            } else {
                height = kHotCommentAreaHeight;
            }
            commentHeight = height + kSpace;
        }
        
        if (item.jokeHasImage) {
            imageHeight = [self getMemeryImageSizeWithUrl:item.news.picUrl].height;
        }
    }
    if ([contentString containsString:@"\n"] && !item.isExpand) {//去掉换行符
        contentString = [[contentString componentsSeparatedByString:@"\n"] componentsJoinedByString:@""];
    }

    CGSize size = CGSizeMake(kAppScreenWidth - 2 * kCommonSpace, 2000);
    CGSize labelsize = [contentString sizeWithFont:[SNUtility getNewsTitleFont] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    CGFloat add = 0;
    if (item.isExpand) {
        if ([[SNDevice sharedInstance] isPlus]) {
            add = 25.f;
        } else if ([[SNDevice sharedInstance] isPhone6]) {
            add = 20.f;
        } else {
            add = 10.f;
        }
        add = (add / kLimitCharacterNum)*contentString.length;
    }
    
    if (!item.isExpand) {
        item.lastCellHeight = labelsize.height + add + commentHeight + imageHeight + kBottomAreaHeight + expandExt + kCellsSpaceTop + kCellsSpaceBottom;
    }
    return labelsize.height + add + commentHeight + imageHeight + kBottomAreaHeight + expandExt + kCellsSpaceTop + kCellsSpaceBottom;
}

+ (CGSize)getMemeryImageSizeWithUrl:(NSString *)url {
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:url];
    if (!image) {
        return CGSizeMake(0, 0);
    }
    CGFloat standardWidth = kAppScreenWidth - 2 * kCommonSpace;
    
    if (image.images.count > 0) {
        UIImage *img = image.images[0];
        CGFloat width = img.size.width > standardWidth ? standardWidth : img.size.width;
        CGFloat height = (standardWidth / img.size.width) * img.size.height;
        return CGSizeMake(width, height);
    } else {
        CGFloat width = image.size.width > standardWidth ? standardWidth : image.size.width;
        CGFloat height = (standardWidth / image.size.width) * image.size.height;
        return CGSizeMake(width, height);
    }
}

+ (CGSize)getMemeryImageSizeWithImage:(UIImage *)image {
    if (image) {
        CGFloat standardWidth = kAppScreenWidth - 2 * kCommonSpace;
        if (image.images.count > 0) {
            UIImage *img = image.images[0];
            CGFloat width = img.size.width > standardWidth ? standardWidth : img.size.width;
            CGFloat height = (standardWidth / img.size.width) * img.size.height;
            return CGSizeMake(width, height);
        } else {
            CGFloat width = image.size.width > standardWidth ? standardWidth : image.size.width;
            CGFloat height = (standardWidth / image.size.width) * image.size.height;
            return CGSizeMake(width, height);
        }
    }
    return CGSizeZero;
}


- (void)initContent {
    _textContentView = [[SNRollingNewsFunnyTextContent alloc] initWithFrame:CGRectMake(0, (kCellsSpaceTop), kAppScreenWidth , kDefaultCellHeight)];
    _textContentView.delegate = self;
    _unExpandTextHeight = 0;
     [self addSubview:_textContentView];
}

- (void)prasisedInArticle:(NSNotification *)notice {
    NSDictionary *userInfo = notice.userInfo;
    if (userInfo) {
        NSNumber *value = [userInfo objectForKey:self.item.news.newsId];
        if (value) {
            NSInteger isHot = [value integerValue];
            self.item.jokeDidOpt = isHot;
            NSString *hotCount = self.item.news.funnyText.hotCount;
            if (![hotCount containsString:@"万"]) {
                NSUInteger hotNum = 0;
                if (isHot) {
                    hotNum = [hotCount integerValue] + 1;
                } else {
                    hotNum = [hotCount integerValue] - 1;
                }
                
                if (hotNum >= 10000) {
                    self.item.news.funnyText.hotCount = [NSString stringWithFormat:@"%.1f万",hotNum/10000.f];
                } else {
                    self.item.news.funnyText.hotCount = [NSString stringWithFormat:@"%d",hotNum];
                }
                if (hotNum == 0) {
                    self.item.news.funnyText.hotCount = @"";
                }
                self.textContentView.praiselabel.text = self.item.news.funnyText.hotCount;
            }
            self.textContentView.praiseButton.selected = isHot;
            
            if (!isHot) {
                if (self.item.isExpand) {
                    self.textContentView.praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"];
                } else {
                    self.textContentView.praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_qs_v5.png"];
                }
            } else {
                self.textContentView.praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_clicked_v5.png"];
            }
        }
    }
}

- (void)updateTheme {
    [super updateTheme];
    [self repopulation];
    [self.textContentView updateTheme];
}

- (void)updateContentView {
    NSString *expandState = [[TMCache sharedCache] objectForKey:self.item.news.newsId];
    if (expandState.length > 0) {
        self.item.isExpand = [expandState isEqualToString:@"1"];
    }
    
    self.analyticsTimer = [SNAnalyticsNewsReadTimer timer];
    [self repopulation];
}

- (void)repopulation {
    _textContentView.isExpand = self.item.isExpand;
    if (self.item.jokeHasImage) {
        _textContentView.hasImage = YES;
    } else {
        _textContentView.hasImage = NO;
    }
    
    if (self.item.news.funnyText.hotcomment_author.length > 0) {
        _textContentView.hasHotComment = YES;
    } else {
        _textContentView.hasHotComment = NO;
    }
    
    NSString *contentString = self.item.news.funnyText.content;
    if ([contentString containsString:@"\n"] && !self.item.isExpand) {
        //去掉换行符
        contentString = [[contentString componentsSeparatedByString:@"\n"] componentsJoinedByString:@""];
    }
    
    contentString = [contentString stringByReplacingOccurrencesOfString:@" " withString:@""];//去掉空格
    
    if (contentString.length > kLimitCharacterNum) {
        _isFullContent = YES;
        if (!self.item.isExpand) {
            contentString = [contentString substringWithRange:NSMakeRange(0,kLimitCharacterNum)];
            contentString = [NSString stringWithFormat:@"%@...",contentString];
        }
     }
    
    BOOL isPlus = [[SNDevice sharedInstance] isPlus];
    float scale = isPlus ? 3 : 2;
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    if (contentString.length > 0) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:contentString]];
    }
    UIFont *font = [SNUtility getNewsTitleFont];

    if (self.item.jokeHasImage && !self.item.isExpand) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        UIImage *image = [UIImage themeImageNamed:@"icohome_picsmall_v5.png"];
        image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:attachText];
    }

    if (!_isFullContent && !self.item.jokeHasImage && self.item.news.funnyText.hotcomment_author.length <= 0) {
        //48字以内段子并且没有图片没有热门评论，不需要展开按钮以及展开
        self.item.jokeOnlyShortText = YES;
    } else {
        self.item.jokeOnlyShortText = NO;
        UIImage *toggleImage = [UIImage themeImageNamed:@"ico_duanzi_arrow_v5.png"];
        if (self.item.isExpand) {
            toggleImage = [UIImage imageWithCGImage:toggleImage.CGImage scale:scale orientation:UIImageOrientationDownMirrored];
        } else {
            toggleImage = [UIImage imageWithCGImage:toggleImage.CGImage scale:scale orientation:UIImageOrientationUp];
        }
        _togbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_togbtn setImage:toggleImage forState:UIControlStateNormal];
        [_togbtn setFrame:CGRectMake(0, 0, 40, 20)];
        [_togbtn addTarget:self action:@selector(clickTogBtn) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableAttributedString *toggleAttachText = [NSMutableAttributedString yy_attachmentStringWithContent:_togbtn contentMode:UIViewContentModeCenter attachmentSize:_togbtn.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:toggleAttachText];
    }

    text.yy_font = font;
    text.yy_color = SNUICOLOR(kThemeText2Color);
    text.yy_alignment = NSTextAlignmentLeft;
    
    text.yy_lineSpacing = 0.01;
    _textContentView.contentTextLabel.attributedText = text;
    _textContentView.contentTextLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    _textContentView.signLabel.text = self.item.news.iconText;
    _textContentView.hotCommentView.author = [NSString stringWithFormat:@"%@: ",self.item.news.funnyText.hotcomment_author];
    _textContentView.hotCommentView.hotComment = self.item.news.funnyText.hotcomment_content;
    [_textContentView.hotCommentView updateContent];
    
    NSString *commentNumStr = self.item.news.commentNum;
    NSInteger commentNum = [commentNumStr integerValue];
    if (commentNum >= 10000) {
        commentNumStr = [NSString stringWithFormat:@"%.1f万",commentNum/10000.f];
    }

    _textContentView.commentlabel.text = commentNumStr;
    _textContentView.praiselabel.text = self.item.news.funnyText.hotCount;
    self.item.jokeDidOpt = [self didPraisedJokeWithNewsId:self.item.news.newsId];
    _textContentView.praiseButton.selected = self.item.jokeDidOpt;
    if (self.item.isExpand) {
        _textContentView.praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"];
        _textContentView.praiseButton.hidden = NO;
        _textContentView.commentButton.hidden = NO;
    } else {
        _textContentView.praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_qs_v5.png"];
        _textContentView.praiseButton.hidden = YES;
        _textContentView.commentButton.hidden = YES;
    }
    if (self.item.jokeOnlyShortText) {
        _textContentView.praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"];
        _textContentView.praiseButton.hidden = NO;
        _textContentView.commentButton.hidden = NO;

    }
    if (self.item.jokeDidOpt) {
        _textContentView.praiseImgae.image = [UIImage themeImageNamed:@"ico_duanzi_praise_clicked_v5.png"];
    }
    _textContentView.link = self.item.news.link;
    [self incrementWithSetExpand:self.item.isExpand];
}

- (void)expandWithButton:(UIButton *)button {
    self.item.isExpand = !self.item.isExpand;
    NSString *tpString = self.item.isExpand ? @"co":@"cc";
    NSString *ctypeString = self.item.jokeHasImage? @"1":@"0";
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=joker&_tp=%@&ctype=%@&channelId=%@", tpString, ctypeString, [SNUtility getCurrentChannelId]]];
    
    if (self.item.jokeOnlyShortText) {//48字以内纯文本内容不需要展开功能
        return;
    }
    
    self.item.jokeDidRead = YES;
    if (self.item.isExpand) {
        _textContentView.frame = CGRectMake(_textContentView.origin.x, _textContentView.origin.y, _textContentView.size.width,  [SNRollingNewsFunnyTextCell getCellHeightWith:self.item] - (kCellsSpaceTop + kCellsSpaceBottom));
    } else {
        _textContentView.frame = CGRectMake(_textContentView.origin.x, _textContentView.origin.y, _textContentView.size.width,  [SNRollingNewsFunnyTextCell getCellHeightWith:self.item] - (kCellsSpaceTop + kCellsSpaceBottom));
    }
    if (_textContentView.hasImage && self.item.isExpand && !_textContentView.imageView.image) {
        [_textContentView.imageView loadImageWithUrl:self.item.news.picUrl defaultImage:[UIImage themeImageNamed:@"bg_defaultpic3_v5.png"]];
    }
    if (self.tableView && self.indexPath) {
        [UIView transitionWithView:self.tableView
                          duration:0.35f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void) {
             [self.tableView reloadData];
        } completion: ^(BOOL isFinished) {
             [[TMCache sharedCache] setObject:self.item.isExpand ? @"1" : @"0" forKey:self.item.news.newsId]; //缓存展开收起的状态
         }];
    }
    
    [self repopulation];
}

- (void)clickTogBtn {
    self.item.isExpand = !self.item.isExpand;
    self.item.jokeDidRead = YES;
    if (self.item.isExpand) {
        _textContentView.frame = CGRectMake(_textContentView.origin.x, _textContentView.origin.y, _textContentView.size.width,  [SNRollingNewsFunnyTextCell getCellHeightWith:self.item] - (kCellsSpaceTop + kCellsSpaceBottom));
    } else {
        _textContentView.frame = CGRectMake(_textContentView.origin.x, _textContentView.origin.y, _textContentView.size.width,  [SNRollingNewsFunnyTextCell getCellHeightWith:self.item] - (kCellsSpaceTop + kCellsSpaceBottom));
    }
    if (_textContentView.hasImage && self.item.isExpand &&
        !_textContentView.imageView.image) {
        [_textContentView.imageView loadImageWithUrl:self.item.news.picUrl defaultImage:[UIImage themeImageNamed:@"bg_defaultpic3_v5.png"]];
    }
    if (self.tableView) {
        [UIView transitionWithView:self.tableView
                          duration:0.35f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void) {
             [self.tableView reloadData];
         } completion: ^(BOOL isFinished) {
             [[TMCache sharedCache] setObject:self.item.isExpand ? @"1" : @"0" forKey:self.item.news.newsId]; //缓存展开收起的状态
         }];
    }
    
    [self repopulation];
    NSString *tpString = self.item.isExpand ? @"mo":@"mc";
    NSString *ctypeString = self.item.jokeHasImage? @"1":@"0";
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=joker&_tp=%@&ctype=%@&channelId=%@", tpString, ctypeString, [SNUtility getCurrentChannelId]]];
}

- (float)incrementWithSetExpand:(BOOL)isExpand {
    float increment = 0;
    if (isExpand) {
        if (self.item.hasHotcomment) {
            _textContentView.hotCommentView.hidden = NO;
        } else {
            _textContentView.hotCommentView.hidden = YES;
        }

        if (self.item.jokeHasImage) {
            _textContentView.imageView.hidden = NO;
            _textContentView.imageButton.hidden = NO;
        } else {
            _textContentView.imageView.hidden = YES;
            _textContentView.imageButton.hidden = YES;
        }
    } else {
        _textContentView.hotCommentView.hidden = YES;
        _textContentView.imageView.hidden = YES;
        _textContentView.imageButton.hidden = YES;
    }

    CGSize size = CGSizeMake(kAppScreenWidth - 2 * kCommonSpace,2000);
    CGSize labelsize = [[_textContentView.contentTextLabel.attributedText string] sizeWithFont:[SNUtility getNewsTitleFont] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    if (!isExpand) {
        _unExpandTextHeight = labelsize.height;
    }
    increment = labelsize.height + (isExpand ? (20.f / _unExpandTextHeight) * _textContentView.contentTextLabel.attributedText.string.length : 12);
    
    _textContentView.contentTextLabel.numberOfLines = 0;
    _textContentView.contentTextLabel.frame = CGRectMake(_textContentView.contentTextLabel.origin.x, _textContentView.contentTextLabel.origin.y, size.width, increment);
    _textContentView.imageView.frame = CGRectMake(_textContentView.imageView.origin.x, _textContentView.imageView.origin.y, [SNRollingNewsFunnyTextCell getMemeryImageSizeWithUrl:item.news.picUrl].width, [SNRollingNewsFunnyTextCell getMemeryImageSizeWithUrl:item.news.picUrl].height);
    _textContentView.imageButton.frame = CGRectMake(_textContentView.imageView.origin.x, _textContentView.imageView.origin.y, [SNRollingNewsFunnyTextCell getMemeryImageSizeWithUrl:item.news.picUrl].width, [SNRollingNewsFunnyTextCell getMemeryImageSizeWithUrl:item.news.picUrl].height);
    _textContentView.frame = CGRectMake(_textContentView.origin.x, _textContentView.origin.y, _textContentView.size.width, [SNRollingNewsFunnyTextCell getCellHeightWith:self.item] - (kCellsSpaceTop + kCellsSpaceBottom));
    [_textContentView layoutSubviews];
 
    return increment;
}

- (BOOL)didPraisedJokeWithNewsId:(NSString *)newsId {
    JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id object = [jsKitStorage getItem:kPraiseJSKitName];
    if (object && [object isKindOfClass:[NSArray class]]) {
        NSArray *optArray = (NSArray *)object;
        for (id obj in optArray) {
            if ([obj isKindOfClass:[NSString class]] ) {
                NSString *newsid = (NSString *)obj;
                if ([newsid isEqualToString:newsId]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (void)savePraisedInfo:(NSString *)newsId {
    NSMutableArray * praisedList = [NSMutableArray array];
    JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id object = [jsKitStorage getItem:kPraiseJSKitName];
    if (object && [object isKindOfClass:[NSArray class]]) {
        NSArray *optArray = (NSArray *)object;
        praisedList = [NSMutableArray arrayWithArray:optArray];
        [praisedList addObject:newsId];
    } else {
        [praisedList addObject:newsId];
    }
    [jsKitStorage setItem:praisedList forKey:kPraiseJSKitName];
}

- (void)removePraisedInfo:(NSString *)newsId {
    NSMutableArray *praisedList = [NSMutableArray array];
    JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id object = [jsKitStorage getItem:kPraiseJSKitName];
    if (object && [object isKindOfClass:[NSArray class]]) {
        NSArray *optArray = (NSArray *)object;
        praisedList = [NSMutableArray arrayWithArray:optArray];
        [praisedList removeObject:newsId];
    }
    [jsKitStorage setItem:praisedList forKey:kPraiseJSKitName];
}


- (void)moreAction:(UIButton *)button {
    [self moreAction];
    if (self.moreView) {
        self.moreView.shareActionDelegate = self;
    }
}

- (void)share {
#if 1
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString *protocol = [NSString stringWithFormat:@"%@newsId=%@&from=%@&channelId=%@", kProtocolNews, self.item.news.newsId ? : @"", @"channel", self.item.news.channelId ? : @""];
    [mDic setObject:protocol forKey:@"url"];
    [mDic setObject:@"joke" forKey:@"contentType"];
    [mDic setObject:[NSString stringWithFormat:@"newsId=%@", self.item.news.newsId]
             forKey:@"referString"];
    [mDic setObject:protocol forKey:@"url"];
    [mDic setObject:@"joke" forKey:@"shareLogType"];
    [mDic setObject:@"copyLink" forKey:@"disableIcons"];
    
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.item.news.newsId];
    NSString *sourceType = [NSString stringWithFormat:@"%d", oobj ? oobj.sourceType:SNShareSourceTypeNews];
    [mDic setObject:sourceType forKey:@"sourceType"];
    [mDic setObject:oobj.picUrl?oobj.picUrl:@"" forKey:kShareInfoKeyImageUrl];
    [mDic setObject:oobj.picUrl?oobj.picUrl:@"copyLink" forKey:@"disableIcons"];

    [self callShare:mDic];
    
    return;
#endif
}

- (void)opt:(BOOL)isHot {
    if (isHot) {
        SNCCPVPage page = [self.item getCurrentPage];
        SNUserTrack *userTrack = [SNUserTrack trackWithPage:page link2:self.item.news.link];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_joke_praise];
        [SNNewsReport reportADotGifWithTrack:paramString];
        
    }
    if (isHot) {
        [self savePraisedInfo:self.item.news.newsId];
    } else {
        [self removePraisedInfo:self.item.news.newsId];
    }

    self.item.jokeDidOpt = isHot;
    NSString *hotCount = self.item.news.funnyText.hotCount;
    if (![hotCount containsString:@"万"]) {
        NSUInteger hotNum = 0;
        if (isHot) {
            hotNum = [hotCount integerValue] + 1;
        } else {
            hotNum = [hotCount integerValue] - 1;
        }
        
        if (hotNum >= 10000) {
            self.item.news.funnyText.hotCount = [NSString stringWithFormat:@"%.1f万",hotNum/10000.f];
        } else {
            self.item.news.funnyText.hotCount = [NSString stringWithFormat:@"%d",hotNum];
        }
        if (hotNum == 0) {
            self.item.news.funnyText.hotCount = @"";
        }
        self.textContentView.praiselabel.text = self.item.news.funnyText.hotCount;
    }

    if (self.analyticsTimer) {
        self.analyticsTimer.isFavour = isHot ? 1:-1;
        self.analyticsTimer.channelId = self.item.news.channelId;
        self.analyticsTimer.newsId = self.item.news.newsId;
        self.analyticsTimer.isEnd = self.item.jokeDidRead;
        self.analyticsTimer.subId = self.item.news.subId;
        self.analyticsTimer.page = SNAnalyticsTimerPageTypeRollingNewsList;

        [self.analyticsTimer fire];
        self.analyticsTimer = nil;
    }
}

- (void)openJokeNewsFromHotComment {
    [self openNews];
}

- (void)openSlidesImages {
    SNPhotoSlideshow *ss = [[SNPhotoSlideshow alloc] init];
    ss.photos = [NSMutableArray array];
    
    SNPhoto *photo = [[SNPhoto alloc] init];
    photo.url = self.item.news.picUrl;
    photo.index = 0;
    photo.caption = @"段子详情";
    photo.info = self.item.news.funnyText.content;
    photo.photoSource = ss;
    [ss.photos addObject:photo];

    self.photoCtl = [[SNNewsGallerySlidershowController alloc] initWithGallery:ss];
    self.photoCtl.delegate = self;
    CGRect rect = [self.textContentView.imageView convertRect:self.textContentView.imageView.bounds toView:nil];
    SNTabBarController *newsController = (SNTabBarController *)[[TTNavigator navigator] viewControllerForURL:@"tt://tabBar"];
    
    BOOL bShow = [_photoCtl showPhotoByIndex:0
                                      inView:newsController.view
                                      newsId:self.item.news.newsId
                                        from:rect];
    if (bShow) {
        _textContentView.userInteractionEnabled = NO;
    } else {
        self.photoCtl.delegate = nil;
        [self.photoCtl.view removeFromSuperview];
    }
}

#pragma mark SNNewsGallerySlidershowControllerDelegate method
- (void)sliderShowDidClose {
    _textContentView.userInteractionEnabled = YES;
    self.photoCtl.delegate = nil;
    [self.photoCtl.view removeFromSuperview];
}

- (void)sliderShowDidShow {
    _textContentView.userInteractionEnabled = NO;
}

- (void)sliderShowWillShare:(int)index {
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    NSString *referStr = nil;
    referStr = @"newsId=%@";
    
#if 1 //wangshun share test
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    [mDic setObject:self.item.news.picUrl forKey:@"imageUrl"];
    [mDic setObject:@"joke" forKey:@"contentType"];
    [mDic setObject:[NSString stringWithFormat:referStr, self.item.news.newsId] forKey:@"referString"];
    [mDic setObject:@"joke" forKey:@"shareLogType"];
    [self callShare:mDic];
    return;
#endif
    _actionMenuController.shareLogType = @"joke";
    _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    _actionMenuController.timelineContentType = SNTimelineContentTypePhoto;
    _actionMenuController.timelineContentId = self.item.news.newsId;
    [_actionMenuController.contextDic setObject:self.item.news.picUrl forKey:@"imageUrl"];
    [_actionMenuController.contextDic setObject:@"joke" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:referStr, self.item.news.newsId] forKey:@"referString"];
    _actionMenuController.delegate = self;
    [_actionMenuController showActionMenu];
}

- (void)callShare:(NSDictionary *)paramsDic {
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (CGRect)rectForImageUrl:(NSString *)url {
    return [self.textContentView.imageView convertRect:self.textContentView.imageView.bounds toView:nil];
}

@end
