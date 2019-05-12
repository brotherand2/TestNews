//
//  SNLiveRoomTopInfoView.m
//  sohunews
//
//  Created by wang yanchen on 13-5-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomTopInfoView.h"
#import "UIColor+ColorUtils.h"
#import "NSAttributedString+Attributes.h"
#import "SNSoundManager.h"
#import "SNLiveRoomConsts.h"

#define kLiveRoomTopInfoViewWidth               (kAppScreenWidth - 20)// (600 / 2)
#define kLiveRoomTopInfoViewHeight              (142 / 2)
#define kLiveRoomTopInfoViewOneLineHeight       (60 / 2)
#define kLiveRoomTopInfoViewFont                (26 / 2)
#define kLiveRoomTopInfoViewTextTopMargin       (15 / 2)
#define kLiveRoomTopInfoViewTextSideMargin      (15 / 2)
#define kLiveRoomTopInfoViewImageWidth          (150 / 2)
#define kLiveRoomTopInfoViewImageheight         (112 / 2)
#define kLiveRoomTOpInfoViewExpBtnWidth         ((48 + 12) / 2)
#define kLiveRoomTOpInfoViewExpBtnHeight        (34 / 2)

@interface SNliveRoomTopInfoFlipButton : UIButton {
    UIImageView *_bgImageView;
}

- (void)setAnimationImages:(NSArray *)animationImages;

@end

@implementation SNliveRoomTopInfoFlipButton

- (void)dealloc {
}

- (void)setBgImage:(UIImage *)bgImage {
    if (!bgImage || ![bgImage isKindOfClass:[UIImage class]]) {
        SNDebugLog(@"%@-%@:error bgImage",
                   NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bgImageView];
    }

    [_bgImageView stopAnimating];
    
    _bgImageView.image = bgImage;
    _bgImageView.size = bgImage.size;
    _bgImageView.centerX = CGRectGetMidX(self.bounds);
    _bgImageView.centerY = CGRectGetMidY(self.bounds);
}

- (void)setAnimationImages:(NSArray *)animationImages {
    if (animationImages.count == 0) {
        return;
    }
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bgImageView];
    }
    
    UIImage *aImage = animationImages.lastObject;
    _bgImageView.size = aImage.size;
    _bgImageView.centerX = CGRectGetMidX(self.bounds);
    _bgImageView.centerY = CGRectGetMidY(self.bounds);
    
    _bgImageView.animationImages = animationImages;
    _bgImageView.animationDuration = kSNLiveRoomTopInfoViewAnimationDuration + 0.05;
    _bgImageView.animationRepeatCount = 1;
    [_bgImageView startAnimating];
}

@end

@interface SNLiveRoomTopInfoContentLayer : UIView {
    CGPathRef _path;
}

@property(nonatomic, copy) NSString *text;

@end

@implementation SNLiveRoomTopInfoContentLayer
@synthesize text = _text;

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)renderWithPath:(CGPathRef)path {
    TT_RELEASE_CF_SAFELY(_path);
    _path = path;
    CFRetain(_path); //lijian 2015.05.09 外面释放了path 里面在用就crash了
    [self setNeedsDisplay];
}

- (void)dealloc {
    TT_RELEASE_CF_SAFELY(_path);
}

- (void)drawRect:(CGRect)rect {
    if (self.text.length == 0) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f));
    
    NSMutableAttributedString* attrStrWithLinks = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attrStrWithLinks setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveRoomContentColor]]];
    [attrStrWithLinks setFont:[UIFont systemFontOfSize:kLiveRoomTopInfoViewFont]];
    
    CTLineBreakMode _lineBreakMode = kCTLineBreakByWordWrapping;
    CTTextAlignment _textAlignment = kCTTextAlignmentLeft;
    
    CGFloat paragraphBefore = 0;
    CGFloat paragraphAfter = 0;
    CGFloat lineSpacing = 6;
    CFIndex theNumberOfSettings = 7;
    
    CTParagraphStyleSetting theSettings[7] =
    {
        { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAlignment },
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
        { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphBefore},
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphAfter},
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
    [attrStrWithLinks addAttribute:(NSString *)kCTParagraphStyleAttributeName
                             value:(id)paragraphStyle
                             range:NSMakeRange(0, attrStrWithLinks.length)];
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStrWithLinks);
    
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), _path, NULL);
    
    CTFrameDraw(textFrame, ctx);
    
    // clean
    CFRelease(framesetter);
    CFRelease(textFrame);
    CFRelease(paragraphStyle);
    
    CGContextRestoreGState(ctx);
}

@end

@interface SNLiveRoomTopInfoView () {
    SNliveRoomTopInfoFlipButton *_expandBtn;
}

@property(nonatomic, assign) BOOL hasImageView;
@property(nonatomic, assign) BOOL hasAccessoryViewIcon;
@property(nonatomic, assign) CGFloat totalHeight;
@property(nonatomic, strong) SNLiveRoomTopInfoContentLayer *contentLayer;
@property(nonatomic, strong) UIImageView *backgroundView;

- (void)resetLinkButton;
- (int)suggestLenthForText:(NSString *)text forWith:(CGFloat)width;
- (void)calculatorTextFrameForLinkButton;

@end

@implementation SNLiveRoomTopInfoView
@synthesize topObj = _topObj;
@synthesize imageView = _imageView;
@synthesize linkButton = _linkButton;
@synthesize hasExpanded;
@synthesize delegate;
@synthesize contentLayer = _contentLayer;
@synthesize backgroundView = _backgroundView;

- (id)initWithFrame:(CGRect)frame {
    // 固定大小
    frame.size.width = kLiveRoomTopInfoViewWidth;
    frame.size.height = kLiveRoomTopInfoViewHeight;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundView = bgImageView;
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.backgroundView];
        
        UIImage *bgImage = [[UIImage imageNamed:@"live_topInfo_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        bgImageView.image = bgImage;
        
        self.contentLayer = [[SNLiveRoomTopInfoContentLayer alloc] initWithFrame:self.bounds];
        self.contentLayer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.contentLayer];
        
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        self.hasExpanded = YES;
        UIImage *arrowImg = [UIImage imageNamed:@"uparrow_normal.png"];
        _expandBtn = [SNliveRoomTopInfoFlipButton buttonWithType:UIButtonTypeCustom];
        _expandBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_expandBtn addTarget:self action:@selector(expandView:) forControlEvents:UIControlEventTouchUpInside];
        _expandBtn.bounds = CGRectMake(0, 0, kLiveRoomTOpInfoViewExpBtnWidth, kLiveRoomTOpInfoViewExpBtnHeight);
        _expandBtn.centerX = self.centerX;
        _expandBtn.centerY = self.height - 8;
        [_expandBtn setBgImage:arrowImg];
        [self addSubview:_expandBtn];
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithTopObject:(SNLiveRoomTopObject *)topObj {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.topObj = topObj;
    }
    return self;
}

- (void)dealloc {
}

- (void)setTopObj:(SNLiveRoomTopObject *)topObj {
    if (_topObj != topObj) {
        self.hasImageView = NO;
        self.hasAccessoryViewIcon = NO;
        _topObj = topObj;
    }
    
    // 如果有图片  按三行的显示
    if (_topObj.topImage.length > 0) {
        self.imageView.hidden = NO;
        [self.imageView loadUrlPath:_topObj.topImage];
        self.hasImageView = YES;
        self.height = kLiveRoomTopInfoViewHeight;
    }
    else {
        self.imageView.hidden = YES;
    }
    
    if (_topObj.top.length > 0)
        _topObj.top = [_topObj.top trim];
    
    [self resetLinkButton];
    [self calculatorTextFrameForLinkButton];
    
    _expandBtn.centerY = self.height - 8;
    self.totalHeight = self.height;
    if (!self.hasExpanded) {
        self.height = kLiveRoomTOpInfoViewExpBtnHeight;
    }
    
    [self setNeedsDisplay];
}

- (void)updateTheme {
    UIImage *bgImage = [[UIImage imageNamed:@"live_topInfo_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    self.backgroundView.image = bgImage;
    
    [self setTopObj:_topObj];
    
    if (self.hasExpanded) {
        UIImage *arrowImg = [UIImage imageNamed:@"uparrow_normal.png"];
        [_expandBtn setBgImage:arrowImg];
    } else {
        UIImage *arrowImg = [UIImage imageNamed:@"downarrow_normal.png"];
        [_expandBtn setBgImage:arrowImg];
    }
}

- (SNWebImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(kLiveRoomTopInfoViewTextSideMargin,
                                                                   kLiveRoomTopInfoViewTextTopMargin,
                                                                   kLiveRoomTopInfoViewImageWidth,
                                                                   kLiveRoomTopInfoViewImageheight)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = 2;
        _imageView.showFade = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UIButton *)linkButton {
    if (!_linkButton) {
        _linkButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_linkButton addTarget:self action:@selector(viewTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_linkButton];
    }
    return _linkButton;
}

#pragma mark - actions
- (void)viewTapped:(id)sender {
    if (_topObj.topLink.length > 0 && self.hasExpanded) {
        // 打开链接时，停止所有音频
        [[SNSoundManager sharedInstance] stopAll];
        // 打开链接时，停止所有视频
        [SNNotificationManager postNotificationName:kSNPlayerViewPauseVideoNotification object:nil];
        
        [SNUtility openProtocolUrl:_topObj.topLink
                           context:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:REFER_LIVE] forKey:kRefer]];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
        [touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - private

- (void)resetLinkButton {
    UIImage *linkImage = nil;
    if ([self.topObj.topLink hasPrefix:kProtocolNews]) {
        linkImage = [UIImage imageNamed:@"live_topLink_news.png"];
    }
    else if ([self.topObj.topLink hasPrefix:kProtocolPaper] || [self.topObj.topLink hasPrefix:kProtocolDataFlow]) {
        linkImage = [UIImage imageNamed:@"live_topLink_paper.png"];
    }
    else if ([self.topObj.topLink hasPrefix:kProtocolLive]) {
        linkImage = [UIImage imageNamed:@"live_topLink_live.png"];
    }
    else if ([self.topObj.topLink hasPrefix:kProtocolSpecial]) {
        linkImage = [UIImage imageNamed:@"live_topLink_special.png"];
    }
    else if ([self.topObj.topLink hasPrefix:kProtocolWeibo]) {
        linkImage = [UIImage imageNamed:@"live_topLink_weibo.png"];
    }
    
    if (linkImage) {
        self.linkButton.size = linkImage.size;
        [self.linkButton setImage:linkImage forState:UIControlStateNormal];
        self.linkButton.bottom = self.height - kLiveRoomTopInfoViewTextTopMargin;
        self.linkButton.right = self.width - kLiveRoomTopInfoViewTextSideMargin;
        self.hasAccessoryViewIcon = YES;
    }
    // 为了方便计算
    else {
        self.linkButton.size = CGSizeZero;
        self.hasAccessoryViewIcon = NO;
    }
}

- (int)suggestLenthForText:(NSString *)text forWith:(CGFloat)width {
    if (text.length > 0) {
        NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:text];
        [attrStr setFont:[UIFont systemFontOfSize:kLiveRoomTopInfoViewFont]];
        CTLineBreakMode _lineBreakMode = kCTLineBreakByWordWrapping;
        CTTextAlignment _textAlignment = kCTTextAlignmentLeft;
        
        CGFloat paragraphBefore = 0;
        CGFloat paragraphAfter = 0;
        CGFloat lineSpacing = 6;
        CFIndex theNumberOfSettings = 7;
        
        CTParagraphStyleSetting theSettings[7] =
        {
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &_textAlignment },
            { kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &_lineBreakMode },
            { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphBefore},
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphAfter},
            { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
            { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
            { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
        [attrStr addAttribute:(NSString *)kCTParagraphStyleAttributeName
                                 value:(id)paragraphStyle
                                 range:NSMakeRange(0, attrStr.length)];
        CFRelease(paragraphStyle);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
        CFRange range = {0};
        CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(width, kLiveRoomTopInfoViewFont + 6), &range);
        
        CFRelease(framesetter);
        
        if (range.length != 0)
            return (int)range.length;
    }
    return 0;
}

- (void)calculatorTextFrameForLinkButton {
    if (_topObj.top.length > 0) {
        UIFont *font = [UIFont systemFontOfSize:kLiveRoomTopInfoViewFont];
        CGFloat textLeft = self.hasImageView ? self.imageView.right + kLiveRoomTopInfoViewTextSideMargin : kLiveRoomTopInfoViewTextSideMargin;
        CGFloat width = self.width - kLiveRoomTopInfoViewTextSideMargin - textLeft;
        int textLenForLine = [self suggestLenthForText:_topObj.top forWith:width];
        // 文字一行搞定
        if (textLenForLine >= _topObj.top.length) {
            CGSize textSize = [_topObj.top sizeWithFont:font];
            // 文字 link一行搞定
            if (textSize.width + (self.linkButton.width>0?self.linkButton.width + 5 : 0) <= width) {
                self.linkButton.left = textLeft + textSize.width + 5;
                self.linkButton.top = kLiveRoomTopInfoViewTextTopMargin;
                if (!self.hasImageView) {
                    self.height = kLiveRoomTopInfoViewOneLineHeight;
                }
                [self end];
                return;

            }
            // 文本第一行 link第二行
            else {
                self.linkButton.left = textLeft;
                self.linkButton.centerY = CGRectGetMidY(self.bounds);
                if (!self.hasImageView) {
                    self.height = kLiveRoomTopInfoViewHeight / 3 * 2 + 5;
                    self.linkButton.bottom = self.height - kLiveRoomTopInfoViewTextTopMargin;
                }
                [self end];
                return;

            }
        }
        
        NSString *nextLineText = [_topObj.top substringFromIndex:textLenForLine];
        textLenForLine = [self suggestLenthForText:nextLineText forWith:width];
        // 文字两行
        if (textLenForLine >= nextLineText.length) {
            CGSize textSize = [nextLineText sizeWithFont:font];
            // 文字  link  两行显示
            if (textSize.width + (self.linkButton.width>0?self.linkButton.width + 5 : 0) <= width) {
                self.linkButton.left = textLeft + textSize.width + 5;
                self.linkButton.centerY = CGRectGetMidY(self.bounds);
                if (!self.hasImageView) {
                    self.height = kLiveRoomTopInfoViewHeight / 3 * 2 + 5;
                    self.linkButton.bottom = self.height - kLiveRoomTopInfoViewTextTopMargin;
                }
                [self end];
                return;

            }
            // 文字两行 link在第三行
            else {
                self.linkButton.left = textLeft;
                if (!self.hasImageView) {
                    self.height = kLiveRoomTopInfoViewHeight;
                    self.linkButton.bottom = self.height - kLiveRoomTopInfoViewTextTopMargin;
                }
                [self end];
                return;
            }
        }
        
        nextLineText = [nextLineText substringFromIndex:textLenForLine];
        // 三行文字
        CGSize textSize = [nextLineText sizeWithFont:font];
        CGFloat linkLeft = textLeft + textSize.width + 5;
        linkLeft = MIN(linkLeft, self.width - kLiveRoomTopInfoViewTextSideMargin - self.linkButton.width);
        
        // link 只能显示第三行了
        self.linkButton.left = linkLeft;
        if (!self.hasImageView) {
            self.height = kLiveRoomTopInfoViewHeight;
            self.linkButton.bottom = self.height - kLiveRoomTopInfoViewTextTopMargin;
        }
        [self end];
    }
}

- (void)end {
    self.height += 10;
    self.contentLayer.frame = CGRectMake(0, 0, self.width, self.height);
    if (self.linkButton.superview != self.contentLayer) {
        [self.linkButton removeFromSuperview];
        [self.contentLayer addSubview:self.linkButton];
    }
    if (self.imageView.superview != self.contentLayer) {
        [self.imageView removeFromSuperview];
        [self.contentLayer addSubview:self.imageView];
    }
    self.contentLayer.text = _topObj.top;
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat textLeft = self.hasImageView ? self.imageView.right + kLiveRoomTopInfoViewTextSideMargin : kLiveRoomTopInfoViewTextSideMargin;
    
    CGPathMoveToPoint(path, NULL, textLeft, kLiveRoomTopInfoViewTextTopMargin);
    if (self.hasAccessoryViewIcon) {
        CGFloat linkLeft = self.linkButton.left + 1; // 保险起见 多计算1px空间
        CGFloat linkBottom = self.height - self.linkButton.top;
        
        CGPathAddLineToPoint(path, NULL, linkLeft, kLiveRoomTopInfoViewTextTopMargin);
        CGPathAddLineToPoint(path, NULL, linkLeft, linkBottom);
        CGPathAddLineToPoint(path, NULL, self.width -kLiveRoomTopInfoViewTextSideMargin, linkBottom);
    }
    else {
        CGPathAddLineToPoint(path, NULL, self.width - kLiveRoomTopInfoViewTextSideMargin, kLiveRoomTopInfoViewTextTopMargin);
    }
    CGPathAddLineToPoint(path, NULL, self.width - kLiveRoomTopInfoViewTextSideMargin, self.height - kLiveRoomTopInfoViewTextTopMargin);
    CGPathAddLineToPoint(path, NULL, textLeft, self.height - kLiveRoomTopInfoViewTextTopMargin);
    CGPathAddLineToPoint(path, NULL, textLeft, kLiveRoomTopInfoViewTextTopMargin);
    
    [self.contentLayer renderWithPath:path];
    
    // v5.2.0 renderWithPath 方法里不会对path做 retain或copy ...
    CFRelease(path);

}

- (void)expandView:(id)sender {
    self.hasExpanded = !self.hasExpanded;
    CGFloat fromH, toH;
    
    if (self.hasExpanded) {
        fromH = kLiveRoomTOpInfoViewExpBtnHeight;
        toH = self.totalHeight;
        
        NSMutableArray *images = [NSMutableArray array];
        [images addObject:[UIImage imageNamed:@"downarrow_normal.png"]];
        [images addObject:[UIImage imageNamed:@"middlearrow_normal.png"]];
        [images addObject:[UIImage imageNamed:@"uparrow_normal.png"]];
        [_expandBtn setAnimationImages:images];
        
    } else {
        fromH = self.totalHeight;
        toH = kLiveRoomTOpInfoViewExpBtnHeight;
        
        NSMutableArray *images = [NSMutableArray array];
        [images addObject:[UIImage imageNamed:@"uparrow_normal.png"]];
        [images addObject:[UIImage imageNamed:@"middlearrow_normal.png"]];
        [images addObject:[UIImage imageNamed:@"downarrow_normal.png"]];
        [_expandBtn setAnimationImages:images];
    }
    
    [UIView animateWithDuration:kSNLiveRoomTopInfoViewAnimationDuration animations:^{
        if (self.hasExpanded) {
            self.backgroundView.alpha = 1;
            self.imageView.alpha = 1;
            self.contentLayer.alpha = 1;
        } else {
            self.backgroundView.alpha = 0;
            self.imageView.alpha = 0;
            self.contentLayer.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (self.hasExpanded) {
            UIImage *arrowImg = [UIImage imageNamed:@"uparrow_normal.png"];
            [_expandBtn setBgImage:arrowImg];
        } else {
            UIImage *arrowImg = [UIImage imageNamed:@"downarrow_normal.png"];
            [_expandBtn setBgImage:arrowImg];
        }
    }];
    
    if (delegate && [delegate respondsToSelector:@selector(expandTopInfoViewFromHeight:toHeight:)]) {
        [delegate expandTopInfoViewFromHeight:fromH toHeight:toH];
    }
}

@end
