//
//  SNCorpusJokeCell.m
//  sohunews
//
//  Created by H on 16/5/10.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#define kPublicImageViewWidth       ([[SNDevice sharedInstance] isPlus]?(154/3.f):(78/2.f))
#define kDownloadImageViewWidth     ([[SNDevice sharedInstance] isPlus]?(120/3.f):(60/2.f))
#define kImageViewTop               ([[SNDevice sharedInstance] isPlus]?7:12)
#define kCommonSpace                ([[SNDevice sharedInstance] isPlus]?(42/3.f):(28/2.f))
#define kIS_6_PLUS                  ([UIScreen mainScreen].bounds.size.width > 750/2.f)
#define kDefaultCellHeight          (250/2.f)
#define kLimitCharacterNum          (48)
#define kBottomAreaHeight           (35)
#define kHotCommentAreaHeight       (52/2.f)
#define kLittleSpace                (0)
#define kSpace                      (15/2.f)
#define kMaxImageHeight             (660/2.f)
#define kMinImageHeight             (372/2.f)

#import "SNCorpusJokeCell.h"
#import "UIFont+Theme.h"
#import "YYText.h"
#import "SNNewsGallerySlidershowController.h"
#import "TMCache.h"
#import "SNActionMenuController.h"
#import "SNNewsShareManager.h"

@interface SNCorpusJokesPool : NSMutableDictionary;

+ (SNCorpusJokesPool *)sharedInstance;

@end
@implementation SNCorpusJokesPool

+ (SNCorpusJokesPool *)sharedInstance{
    static SNCorpusJokesPool * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNCorpusJokesPool alloc] init];
    });
    return sharedInstance;
}

@end

@interface SNRollingNewsJokeHotComment : UIView

@property (nonatomic, copy) NSString * s_author;
@property (nonatomic, copy) NSString * hotCom;
@property (nonatomic, strong) UILabel * s_authorLabel;
@property (nonatomic, strong) UILabel * comLabel;
@property (nonatomic, copy) NSString * slink;

@end

@implementation SNRollingNewsJokeHotComment

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initContent];
    }
    return self;
}

- (void)initContent{
    _s_authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, self.width, self.height)];
    _s_authorLabel.text = _s_author;
    _s_authorLabel.numberOfLines = 1;
    _s_authorLabel.textAlignment = NSTextAlignmentLeft;
    _s_authorLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    _s_authorLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    [self addSubview:_s_authorLabel];
    
    _comLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _comLabel.left = _s_authorLabel.right;
    _comLabel.text = _hotCom;
    _comLabel.numberOfLines = 1;
    _comLabel.textAlignment = NSTextAlignmentLeft;
    _comLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    _comLabel.textColor = SNUICOLOR(kThemeText4Color);
    [self addSubview:_comLabel];
    
    self.backgroundColor = SNUICOLOR(kThemeBg2Color);
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 1;
    
    UIButton * comment = [UIButton buttonWithType:UIButtonTypeCustom];
    comment.frame = CGRectMake(0, 0, self.width, self.height);
    [comment addTarget:self action:@selector(openJoke) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:comment];
}

- (void)openJoke {
//    SNDebugLog(@"打开段子");
    if (self.slink.length > 0) {
        [SNUtility openProtocolUrl:self.slink context:nil];
    }
}

- (void)updateContent{
    if (_s_author.length>0) {
        CGSize msize = [_s_author sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
        _s_authorLabel.frame = CGRectMake(11, 0, msize.width, self.height);
        _s_authorLabel.text = _s_author;
        _comLabel.frame = CGRectMake(_s_authorLabel.right + 5, 0, self.width - _s_authorLabel.width - 2 * 11 - 5, self.height);
        _comLabel.text =_hotCom;
        _comLabel.left = _s_authorLabel.right + 5;
    }
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kThemeBg2Color);
    _comLabel.textColor = SNUICOLOR(kThemeText4Color);
    _s_authorLabel.textColor = SNUICOLOR(kThemeBlue1Color);
}


@end

@protocol SNRollingNewsJokeContentDelegate <NSObject>

//- (void)expandWithState:(BOOL)isExpand increment:(float)increment;
- (void)expandWithButton:(UIButton *)button;
- (void)moreAction:(UIButton *)button;
- (void)openSlidesImages;
- (void)opt:(BOOL)isHot;

@end

@interface SNRollingNewsJokeContent : UIView

@property (nonatomic, strong) YYLabel * contentLabel;

@property (nonatomic, strong) UIButton * toggleBtn; //展开收起
@property (nonatomic, strong) UIButton * praiseBtn; //点赞
@property (nonatomic, strong) UIButton * commentBtn; //评论
@property (nonatomic, strong) UIButton * boringBtn; //没劲
@property (nonatomic, strong) UIButton * imageBtn; //图片btn
@property (nonatomic, strong) UILabel * timeLabel;      //段子标识
//@property (nonatomic, retain) UIButton * moreBtn; //更多
@property (nonatomic, strong) UIImageView * imgView; //图片
@property (nonatomic, strong) SNRollingNewsJokeHotComment * hotComView;//热门评论区
@property (nonatomic, copy) NSString * slink;

@property (nonatomic, assign) BOOL isExpanding;
@property (nonatomic, assign) BOOL hasImg;

@property (nonatomic, weak) id <SNRollingNewsJokeContentDelegate>contentDelegate;

@end

@implementation SNRollingNewsJokeContent

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self updateTheme];
    }
    return self;
}

- (void)initSubviews {
    
    _contentLabel = [[YYLabel alloc] initWithFrame:CGRectMake(kCommonSpace, 0, self.frame.size.width - 2*kCommonSpace,0)];
    _contentLabel.numberOfLines = 0;
    _contentLabel.userInteractionEnabled = YES;
    //    _contentLabel.backgroundColor = [UIColor greenColor];
    _contentLabel.font = [SNUtility getNewsTitleFont];
    _contentLabel.textColor = SNUICOLOR(kThemeText2Color);
    _contentLabel.textAlignment = NSTextAlignmentJustified;
    [self addSubview:_contentLabel];
    
    _toggleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_toggleBtn setFrame:CGRectMake(kAppScreenWidth - 40 - kCommonSpace, 0, 40, 30)];
    _toggleBtn.bottom = _contentLabel.bottom;
    //    [_toggleBtn setTitle:@"展开" forState:UIControlStateNormal];
    //    [_toggleBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    _toggleBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [_toggleBtn addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_toggleBtn];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kCommonSpace, 0, self.frame.size.width - 2*kCommonSpace, 660/2.f)];
    _imgView.backgroundColor = [UIColor clearColor];
    _imgView.clipsToBounds = NO;
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.hidden = YES;
    [self addSubview:_imgView];
    
    _imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _imageBtn.frame = CGRectMake(kCommonSpace, 0, self.frame.size.width - 2*kCommonSpace, 660/2.f);
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        _imageBtn.backgroundColor = [UIColor blackColor];
        _imageBtn.alpha = 0.5f;
    }else{
        _imageBtn.backgroundColor = [UIColor clearColor];
    }
    [_imageBtn addTarget:self action:@selector(openBigImageSlide) forControlEvents:UIControlEventTouchUpInside];
    _imageBtn.hidden = YES;
    [self addSubview:_imageBtn];
    
    _hotComView = [[SNRollingNewsJokeHotComment alloc] initWithFrame:CGRectMake(_contentLabel.left, 0, _contentLabel.width, kHotCommentAreaHeight)];
    _hotComView.top = _contentLabel.bottom;
    _hotComView.hidden = YES;
    _hotComView.slink = self.slink;
    [self addSubview:_hotComView];
    
    _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_praiseBtn setFrame:CGRectMake(kCommonSpace, 0, 60, 30)];
    _praiseBtn.bottom = self.bottom - kLittleSpace;
    [_praiseBtn setImage:[UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"] forState:UIControlStateNormal];
    [_praiseBtn setImage:[UIImage themeImageNamed:@"ico_duanzi_praise_clicked_v5.png"] forState:UIControlStateSelected];
    _praiseBtn.titleLabel.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeB]];
    [_praiseBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    [_praiseBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateHighlighted];
    _praiseBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_praiseBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20 , 0, -20)];
    //    [_praiseBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 20)];
    [_praiseBtn addTarget:self action:@selector(praise:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_praiseBtn];
    
    _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentBtn setFrame:CGRectMake(kCommonSpace + _praiseBtn.right, 0, 60, 30)];
    _commentBtn.bottom = self.bottom - kLittleSpace;
    [_commentBtn setImage:[UIImage themeImageNamed:@"icohome_commentsmall_v5.png"] forState:UIControlStateNormal];
    [_commentBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    [_commentBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateHighlighted];
    _commentBtn.titleLabel.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeB]];
    _commentBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20 , 0, -20)];
    //    [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 20)];
    [_commentBtn addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_commentBtn];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth-kCommonSpace*2, 30)];
    _timeLabel.right = kAppScreenWidth - kCommonSpace;
    _timeLabel.bottom = self.bottom - kLittleSpace;
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
    _timeLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_timeLabel];
    
}

- (void)toggle:(UIButton *)toggleBtn {
    if (self.contentDelegate && [self.contentDelegate respondsToSelector:@selector(expandWithButton:)]) {
        [self.contentDelegate expandWithButton:toggleBtn];
    }
}

- (void)praise:(UIButton *)praiseBtn {
    if (praiseBtn.selected) {
        return;
    }
    if (praiseBtn.isHighlighted) {
        praiseBtn.imageView.alpha = 0.3;
    }else{
        praiseBtn.imageView.alpha = 1;
    }
    
    praiseBtn.selected = !praiseBtn.selected;
    UILabel * tips = [[UILabel alloc] initWithFrame:CGRectMake(praiseBtn.origin.x, 0, praiseBtn.width, praiseBtn.height)];
    tips.top = praiseBtn.top;
    tips.textAlignment = NSTextAlignmentCenter;
    tips.textColor = SNUICOLOR(kThemeText4Color);
    tips.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeB]];
    tips.text = praiseBtn.selected ? @"+ 1" : @"- 1";
    [self addSubview:tips];
    
    [UIView animateWithDuration:0.5 animations:^{
        tips.alpha = 0;
        tips.frame = CGRectMake(tips.origin.x, tips.origin.y - 30, tips.width, tips.height);
    } completion:^(BOOL finished) {
        [tips removeFromSuperview];
    }];
    
    if (self.contentDelegate && [self.contentDelegate respondsToSelector:@selector(opt:)]) {
        [self.contentDelegate opt:praiseBtn.selected];
    }
    
}

- (void)comment:(UIButton *)commentBtn {
    [_hotComView openJoke];
}


- (void)openBigImageSlide{
    if (self.contentDelegate && [self.contentDelegate respondsToSelector:@selector(openSlidesImages)]) {
        [self.contentDelegate openSlidesImages];
    }
}

- (void)updateTheme {
    [_praiseBtn setImage:[UIImage themeImageNamed:@"ico_duanzi_praise_v5.png"] forState:UIControlStateNormal];
    [_praiseBtn setImage:[UIImage themeImageNamed:@"ico_duanzi_praise_clicked_v5.png"] forState:UIControlStateSelected];
    [_praiseBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    [_praiseBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateHighlighted];
    [_commentBtn setImage:[UIImage themeImageNamed:@"icohome_commentsmall_v5.png"] forState:UIControlStateNormal];
    [_commentBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    [_commentBtn setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateHighlighted];
//    [_moreBtn setImage:[UIImage themeImageNamed:@"icohome_moresmall_v5.png"] forState:UIControlStateNormal];
//    [_moreBtn setImage:[UIImage themeImageNamed:@"icohome_moresmallpress_v5.png"] forState:UIControlStateHighlighted];
//    _iconLabel.textColor = SNUICOLOR(kThemeText4Color);
    _timeLabel.textColor = SNUICOLOR(kThemeText3Color);
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        _imageBtn.backgroundColor = [UIColor blackColor];
        _imageBtn.alpha = 0.5f;
    }else{
        _imageBtn.backgroundColor = [UIColor clearColor];
    }
    [self.hotComView updateTheme];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _toggleBtn.bottom = _contentLabel.bottom;
    _toggleBtn.frame = CGRectMake(_contentLabel.origin.x, _contentLabel.origin.y, _contentLabel.size.width, _contentLabel.size.height);
    _praiseBtn.bottom = self.bottom - kLittleSpace;
    _commentBtn.bottom = self.bottom - kLittleSpace;
    _boringBtn.bottom = self.bottom - kLittleSpace;
//    _moreBtn.bottom = self.bottom - kLittleSpace;
//    _iconLabel.bottom = self.bottom - kLittleSpace;
    _timeLabel.bottom = self.bottom - kLittleSpace;
    _hotComView.slink = self.slink;
    if (_hasImg) {
        _imgView.top = _contentLabel.bottom + kSpace;
        _imageBtn.top = _contentLabel.bottom + kSpace;
        _hotComView.top = _imgView.bottom + kSpace;
    }else{
        _hotComView.top = _contentLabel.bottom + kSpace;
    }
    [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10 , 0, -10)];
    [_praiseBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10 , 0, -10)];
}

@end

@interface SNCorpusJokeCell ()<SNRollingNewsJokeContentDelegate,SNNewsGallerySlidershowControllerDelegate>

@property (nonatomic, strong) SNRollingNewsJokeContent * jokeContentView;

@property (nonatomic, strong) SNNewsGallerySlidershowController * photoControl;

@property (nonatomic, strong) SNAnalyticsNewsReadTimer *analytics;

@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) SNNewsShareManager *shareManager;

@property (nonatomic, assign) BOOL isFullContent;
@property (nonatomic, assign) BOOL isEditMode;

@end

@implementation SNCorpusJokeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDic:(NSDictionary *)newsItemDict {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initContent];
        self.item = [SNCorpusJokeCell createNewsItemWithInfo:newsItemDict];
//        [self setCellFrame];
        [self initSelectButton];
//        [self initTitleLabel];
//        [self initTimeLabel];
        
        [SNNotificationManager addObserver:self selector:@selector(updateFontTheme) name:kFontModeChangeNotification object:nil];
    }
    
    return self;
}

- (void)initContent{
    _jokeContentView = [[SNRollingNewsJokeContent alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth , kDefaultCellHeight)];
    _jokeContentView.contentDelegate = self;
    [self addSubview:_jokeContentView];
}


- (void)setCellInfoWithInfoDic:(NSDictionary *)info time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link isItemSelected:(BOOL)isItemSelected {
    self.idsString = ids;
    self.linkString = link;
    _isEditMode = isEditMode;
    self.jokeContentView.timeLabel.text = [NSDate relativelyDate:time];
    if (_isEditMode) {
        [self setEditMode:0];
    }
    else {
        [self setNormalMode];
    }
    _selectButton.selected = isItemSelected;
//    [self setCellFrame];
    [self updateContentView];
    NSString * favorId = [info stringValueForKey:@"fid" defaultValue:@""];
    [[TMMemoryCache sharedCache] setObject:_item forKey:favorId];

}

- (void)updateContentView
{
    self.analytics = [SNAnalyticsNewsReadTimer timer];
    
    if (self.item.jokeHasImage) {
        _jokeContentView.hasImg = YES;
        [_jokeContentView.imgView sd_setImageWithURL:[NSURL URLWithString:self.item.news.picUrl] placeholderImage:[UIImage themeImageNamed:@"bg_defaultpic3_v5.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (self.tableView && self.indexPath) {
                [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }else{
        _jokeContentView.hasImg = NO;
        if (self.tableView && self.indexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    NSString *contentString = self.item.news.funnyText.content;
    if (contentString.length > kLimitCharacterNum) {
        _isFullContent = YES;
        if (!self.item.isExpand) {
            contentString = [contentString substringWithRange:NSMakeRange(0,kLimitCharacterNum)];
            contentString = [NSString stringWithFormat:@"%@...",contentString];
        }
    }
    if ([contentString containsString:@"\n"] && !self.item.isExpand) {//去掉换行符
        contentString = [[contentString componentsSeparatedByString:@"\n"] componentsJoinedByString:@""];
    }
    
    //    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:contentString];
    //    NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    //    style.lineSpacing = 1;//增加行高
    //    style.alignment = NSTextAlignmentJustified;//对齐方式
    //    style.lineBreakMode = NSLineBreakByTruncatingTail;
    //    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrString.length)];
    //    _textContentView.contentTextLabel.attributedText = attrString;
    //    [attrString release];
    
    BOOL isPlus = [[SNDevice sharedInstance] isPlus];
    float scale = isPlus ? 3 : 2;
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:contentString]];
    UIFont *font = [SNUtility getNewsTitleFont];
    
    if (self.item.jokeHasImage && !self.item.isExpand) {
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        UIImage *image = [UIImage themeImageNamed:@"icohome_picsmall_v5.png"];
        image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:attachText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }else{
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    UIImage *toggleImage = [UIImage themeImageNamed:@"ico_duanzi_arrow_v5.png"];
    if (self.item.isExpand) {
        toggleImage = [UIImage imageWithCGImage:toggleImage.CGImage scale:scale orientation:UIImageOrientationDownMirrored];
    }else{
        toggleImage = [UIImage imageWithCGImage:toggleImage.CGImage scale:scale orientation:UIImageOrientationUp];
    }
    UIImageView *toggleImageView = [[UIImageView alloc] initWithImage:toggleImage];
    NSMutableAttributedString *toggleAttachText = [NSMutableAttributedString yy_attachmentStringWithContent:toggleImageView contentMode:UIViewContentModeCenter attachmentSize:toggleImageView.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [text appendAttributedString:toggleAttachText];
    text.yy_font = font;
    text.yy_color = SNUICOLOR(kThemeText2Color);
    text.yy_alignment = NSTextAlignmentJustified;
    _jokeContentView.contentLabel.attributedText = text;
    
    //    _textContentView.contentTextLabel.text = contentString;
//    _jokeContentView.iconLabel.text = self.item.news.iconText;
    _jokeContentView.hotComView.s_author = [NSString stringWithFormat:@"%@:",self.item.news.funnyText.hotcomment_author];
    _jokeContentView.hotComView.hotCom = self.item.news.funnyText.hotcomment_content;
    [_jokeContentView.hotComView updateContent];
    
    NSString *commentNumStr = self.item.news.commentNum;
    NSInteger commentNum = [commentNumStr integerValue];
    if (commentNum >= 10000) {
        commentNumStr = [NSString stringWithFormat:@"%.1f万",commentNum/10000.f];
    }
    [_jokeContentView.commentBtn setTitle:commentNumStr forState:UIControlStateNormal];
    [_jokeContentView.praiseBtn  setTitle:self.item.news.funnyText.hotCount forState:UIControlStateNormal];
    _jokeContentView.praiseBtn.selected = self.item.jokeDidOpt;
    _jokeContentView.slink = self.item.news.link;
    [self incrementWithSetExpand:self.item.isExpand];

}

//- (void)setCellFrame {
//    self.frame = CGRectMake(0, 0, kAppScreenWidth, [SNCorpusJokeCell getCellHeightWith:self.item]);
//}

- (void)setEditMode:(CGFloat)duration {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _selectButton.centerY = self.height/2.f;
    _jokeContentView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:^(void){
        _selectButton.left = kSelectButtonLeftDistance;
        _jokeContentView.left = _selectButton.right + kSelectButtonLeftDistance;
//        _titleLabel.width = kAppScreenWidth - CONTENT_LEFT - _selectButton.right - kSelectButtonLeftDistance;
    } completion:^(BOOL finished){
    }];
}

- (void)setNormalMode {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    _selectButton.centerY = self.height/2.f;
    [UIView animateWithDuration:kCellAnimationDuration animations:^(void){
        _selectButton.right = 0;
        _jokeContentView.left = 0;
//        _titleLabel.width = kAppScreenWidth - 2*CONTENT_LEFT;
    } completion:^(BOOL finished){
        _jokeContentView.userInteractionEnabled = YES;
    }];
}

- (void)updateTheme {
    [super updateTheme];
}

- (void)updateFontTheme {
//    _titleLabel.font = [SNUtility getNewsTitleFont];
}

+ (SNRollingNewsTableItem *)createNewsItemWithInfo:(NSDictionary *)infoDic {
    NSString * favorId = [infoDic stringValueForKey:@"fid" defaultValue:@""];
    if (favorId.length > 0) {
        
        SNRollingNewsTableItem *item = [[TMMemoryCache sharedCache] objectForKey:favorId];
        if (!item) {
            item = [[SNRollingNewsTableItem alloc] init];
            item.news = [[SNRollingNews alloc] init];
            [[TMMemoryCache sharedCache] setObject:item forKey:favorId];
        }
        
        item.news.commentNum = [infoDic stringValueForKey:@"commentNum" defaultValue:@""];
        if ([[infoDic objectForKey:@"imgUrl"] isKindOfClass:[NSArray class]]) {
            item.news.picUrl = [[infoDic objectForKey:@"imgUrl"] firstObject];
        }
        item.news.link = [infoDic stringValueForKey:@"link" defaultValue:@""];
        item.news.newsType = [infoDic stringValueForKey:@"newsType" defaultValue:@""];
        item.news.statsType = SNRollingNewsStatsType_NormalNewsStat;
        
        NSString * hotComment = [infoDic stringValueForKey:@"hotComment" defaultValue:@""];
        if (hotComment.length > 0) {
            item.hasHotcomment = YES;
        }
        if (item.news.picUrl.length > 0) {
            item.jokeHasImage = YES;
        }
        item.news.funnyText =[SNNewsFunnyText initWithFavorateInfoString:hotComment];
        item.news.funnyText.content = [infoDic stringValueForKey:@"title" defaultValue:@""];
        item.news.funnyText.hotCount = [infoDic stringValueForKey:@"hotCount" defaultValue:@""];
        NSInteger hotNum = [item.news.funnyText.hotCount integerValue];
        if (hotNum >= 10000) {
            item.news.funnyText.hotCount = [NSString stringWithFormat:@"%.1f万",hotNum/10000.f];
        }
        return item;

    }
    return nil;
}

- (float)getCellHeight{
    return [SNCorpusJokeCell getCellHeightWith:self.item];
}
+ (float)getCellHeightWithDic:(NSDictionary*)newsItemDict {
    SNRollingNewsTableItem *item = [SNCorpusJokeCell createNewsItemWithInfo:newsItemDict];
    return [SNCorpusJokeCell getCellHeightWith:item];
}

+ (float)getCellHeightWith:(SNRollingNewsTableItem *)item {
    
    CGFloat commentHeight = 0;
    CGFloat imageHeight = 0;
    
    NSString * contentString = item.news.funnyText.content;
    if (!item.isExpand && contentString.length > kLimitCharacterNum) {
        contentString = [contentString substringWithRange:NSMakeRange(0,kLimitCharacterNum)];
        contentString = [NSString stringWithFormat:@"%@...",contentString];
    }
    if (item.isExpand) {
        if (item.hasHotcomment) {
            commentHeight = kHotCommentAreaHeight + kSpace;
        }
        
        if (item.jokeHasImage) {
            imageHeight = [self getMemeryImageSizeWithUrl:item.news.picUrl].height;
        }
    }
    CGSize size = CGSizeMake(kAppScreenWidth - 2*kCommonSpace,2000);
    CGSize labelsize = [contentString sizeWithFont:[SNUtility getNewsTitleFont] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    CGFloat add = 0;
    if ([[SNDevice sharedInstance] isPlus]) {
        add = 30.f;
    }
    else if ([[SNDevice sharedInstance] isPhone6]){
        add = 20.f;
    }
    else{
        add = 10.f;
    }
    return labelsize.height + add + commentHeight + imageHeight + kBottomAreaHeight;
}

+ (CGSize)getMemeryImageSizeWithUrl:(NSString *)url {
    UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:url];
    if (!image) {
        image = [UIImage themeImageNamed:@"bg_defaultpic3_v5.png"];
    }
    CGFloat width = kAppScreenWidth - 2 * kCommonSpace;
    CGFloat height = (width/image.size.width) * image.size.height;
    return CGSizeMake(width, height);
}

+ (CGSize)getMemeryImageSizeWithImage:(UIImage *)image {
    if (image) {
        //        if (image.size.height > kMaxImageHeight) {
        //            return CGSizeMake(image.size.width, kMaxImageHeight);
        //        }else if (image.size.height < kMinImageHeight) {
        //            return CGSizeMake(image.size.width, kMinImageHeight);
        //        }
        CGFloat width = kAppScreenWidth - 2 * kCommonSpace;
        CGFloat height = (width/image.size.width) * image.size.height;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)expandWithButton:(UIButton *)button {
    self.item.isExpand = !self.item.isExpand;
    self.item.jokeDidRead = YES;
    if (self.item.isExpand) {
        _jokeContentView.frame = CGRectMake(_jokeContentView.origin.x, _jokeContentView.origin.y, _jokeContentView.size.width,  [self incrementWithSetExpand:self.item.isExpand] + 44);
    }else{
        _jokeContentView.frame = CGRectMake(_jokeContentView.origin.x, _jokeContentView.origin.y, _jokeContentView.size.width,  kDefaultCellHeight);
    }
    [self updateContentView];
    _selectButton.centerY = self.height/2.f;
}

- (float)incrementWithSetExpand:(BOOL)isExpand{
    
    float increment = 0;
    float imageHeight = 0;
    float hotCommentHeight = 0;
    BOOL isPlus = [[SNDevice sharedInstance] isPlus];
    BOOL isIphone6 = [[SNDevice sharedInstance] isPhone6];
    
    if (isExpand) {
        
        if (self.item.hasHotcomment) {
            _jokeContentView.hotComView.hidden = NO;
            hotCommentHeight = kHotCommentAreaHeight +kSpace;
        }else{
            _jokeContentView.hotComView.hidden = YES;
        }
        
        if (self.item.jokeHasImage) {
            _jokeContentView.imgView.hidden = NO;
            _jokeContentView.imageBtn.hidden = NO;
            imageHeight = [SNCorpusJokeCell getMemeryImageSizeWithUrl:self.item.news.picUrl].height;
        }else{
            _jokeContentView.imgView.hidden = YES;
            _jokeContentView.imageBtn.hidden = YES;
        }
        
    }else{
        _jokeContentView.hotComView.hidden = YES;
        _jokeContentView.imgView.hidden = YES;
        _jokeContentView.imageBtn.hidden = YES;
    }
    NSString * labelString = [_jokeContentView.contentLabel.attributedText string];
    UIFont *font = [SNUtility getNewsTitleFont];
    CGSize size = CGSizeMake(kAppScreenWidth - 2*kCommonSpace,2000);
    CGSize labelsize = [labelString sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    CGFloat move = 0;
    if (isPlus) {
        increment = labelsize.height + (isExpand ? 30 : 20);
        move = 1;
    }else if (isIphone6) {
        increment = labelsize.height + (isExpand ? 25 : 15);
        move = 0;
    }else{
        increment = labelsize.height + (isExpand ? 10 : 5);
        move = -4;
    }
    _jokeContentView.contentLabel.numberOfLines = 0;
    _jokeContentView.contentLabel.frame = CGRectMake(_jokeContentView.contentLabel.origin.x, (isExpand && _isFullContent) ? move : 0, size.width, increment);
    _jokeContentView.imgView.frame = CGRectMake(_jokeContentView.imgView.origin.x, _jokeContentView.imgView.origin.y, _jokeContentView.imgView.width, [SNCorpusJokeCell getMemeryImageSizeWithImage:_jokeContentView.imgView.image].height);
    _jokeContentView.imageBtn.frame = CGRectMake(_jokeContentView.imgView.origin.x, _jokeContentView.imgView.origin.y, _jokeContentView.imgView.width, [SNCorpusJokeCell getMemeryImageSizeWithImage:_jokeContentView.imgView.image].height);
    _jokeContentView.frame = CGRectMake(_jokeContentView.origin.x, _jokeContentView.origin.y, _jokeContentView.size.width, kBottomAreaHeight + increment + imageHeight + hotCommentHeight);
    
    [_jokeContentView layoutIfNeeded];
    
    return increment;
}
- (void)opt:(BOOL)isHot {
    self.item.jokeDidOpt = isHot;
    NSString *hotCount = self.item.news.funnyText.hotCount;
    if (![hotCount containsString:@"万"]) {
        NSUInteger hotNum = [hotCount integerValue] + 1;
        if (hotNum >= 10000) {
            self.item.news.funnyText.hotCount = [NSString stringWithFormat:@"%.1f万",hotNum/10000.f];
        }else{
            self.item.news.funnyText.hotCount = [NSString stringWithFormat:@"%d",hotNum];
        }
        [self.jokeContentView.praiseBtn setTitle:self.item.news.funnyText.hotCount forState:UIControlStateNormal];
    }
    if (self.analytics) {
        self.analytics.isFavour = isHot;
        self.analytics.channelId = self.item.news.channelId;
        self.analytics.newsId = self.item.news.newsId;
        self.analytics.isEnd = self.item.jokeDidRead;
        self.analytics.subId = self.item.news.subId;
        self.analytics.page = SNAnalyticsTimerPageTypeRollingNewsList;
        
        [self.analytics fire];
        self.analytics = nil;
    }
}

- (void)openSlidesImages {
    SNPhotoSlideshow *ss = [[SNPhotoSlideshow alloc] init];
    //    ss.subId = _article.subId;
    ss.photos = [NSMutableArray array];
    
    SNPhoto *photo = [[SNPhoto alloc] init];
    photo.url	= self.item.news.picUrl;
    photo.index = 0 ;
    photo.caption = @"段子详情";
    photo.info = self.item.news.funnyText.content;
    photo.photoSource = ss;
    [ss.photos addObject:photo];
    
    self.photoControl = [[SNNewsGallerySlidershowController alloc] initWithGallery:ss];
    self.photoControl.delegate = self;
    //    self.photoCtl.sdkAdDataLastPic = self.sdkAdDataLastPic;
    CGRect rect = [self.jokeContentView.imgView convertRect:self.jokeContentView.imgView.bounds toView:nil];
    
    BOOL bShow = [_photoControl showPhotoByIndex:0
                                      inView:[UIApplication sharedApplication].keyWindow
                                      newsId:self.item.news.newsId
                                        from:rect];
    if (bShow) {
        //        [self getTopNavigation].view.userInteractionEnabled = NO;
        //            _isShowBigPicView = bShow;
    } else {
        self.photoControl.delegate = nil;
        [self.photoControl.view removeFromSuperview];
    }
    
}
- (void)share {
//    NSString *string = [NSString stringWithFormat:@"%@link=%@&content=%@&contentType=%@&channelId=%@&refer=%@&referId=%@", kProtocolShare, [self.item.news.link URLEncodedString],[self.item.news.funnyText.content URLEncodedString], @"joke", self.item.news.channelId, @"news", self.item.news.newsId];
//    
//    [SNUtility openProtocolUrl:string context:nil];
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSString * protocol = [NSString stringWithFormat:@"%@newsId=%@&from=%@&channelId=%@",kProtocolNews,self.item.news.newsId?:@"",@"channel",self.item.news.channelId?:@""];
    [mDic setObject:protocol forKey:SNNewsShare_Url];
    [mDic setObject:@"joke" forKey:SNNewsShare_ShareOn_contentType];
    [mDic setObject:@"joke" forKey:SNNewsShare_LOG_type];
    [mDic setObject:[NSString stringWithFormat:@"newsId=%@",self.item.news.newsId] forKey:SNNewsShare_ShareOn_referString];
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.item.news.newsId];
    NSString* sourceType = [NSString stringWithFormat:@"%d",oobj?oobj.sourceType:SNShareSourceTypeNews];
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    [mDic setObject:@"copyLink" forKey:SNNewsShare_disableIcons];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    //    _actionMenuController.contextDic = [self createActionMenuContentContext];
    _actionMenuController.contextDic = [NSMutableDictionary dictionary];
    //protocol Url @ huangzhen
    NSString * protocolUrl = [NSString stringWithFormat:@"%@newsId=%@&from=%@&channelId=%@",kProtocolNews,self.item.news.newsId?:@"",@"channel",self.item.news.channelId?:@""];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    
    [_actionMenuController.contextDic setObject:@"joke" forKey:@"contentType"];
    [_actionMenuController.contextDic setObject:[NSString stringWithFormat:@"newsId=%@",self.item.news.newsId] forKey:@"referString"];
    
    
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypeNews contentId:self.item.news.newsId];
    if (obj) {
        _actionMenuController.sourceType = obj.sourceType;
    } else {
        _actionMenuController.sourceType = 3;
    }
    
    NSString * imageUrl = _actionMenuController.contextDic[kShareInfoKeyImageUrl]?:@"";
    if (imageUrl.length == 0) {
        [_actionMenuController.contextDic setObject:obj.picUrl?:@"" forKey:kShareInfoKeyImageUrl];
    }
    _actionMenuController.timelineContentType = SNTimelineContentTypeNews;
    _actionMenuController.timelineContentId = self.item.news.newsId;
    _actionMenuController.shareLogType = @"joke";
    _actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    _actionMenuController.delegate = self;
    //    _actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    _actionMenuController.disableCopyLinkBtn = YES;
    [_actionMenuController showActionMenu];
    //    self.shareContent = _currentNewsWeb.article.shareContent;

    
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

#pragma mark SNNewsGallerySlidershowControllerDelegate method

-(void)sliderShowDidClose {
    //    _swipeLeft.enabled = YES;
    //    self.webView.scrollView.scrollsToTop = YES;
    //    //    _isShowBigPicView = NO;
    //    _currentImageIndex = 0;
    
    self.photoControl.delegate = nil;
    [self.photoControl.view removeFromSuperview];
    
    // 在webview上刷新显示刚刚在SlideShow中下载过的图片
    //    [self refreshDownloadedImagesInWebView];
    
}


- (void)sliderShowWillShare:(int)index
{
    [self share];
 
}

- (CGRect)rectForImageUrl:(NSString *)url
{
    return [self.jokeContentView.imgView convertRect:self.jokeContentView.imgView.bounds toView:nil];
}


- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
