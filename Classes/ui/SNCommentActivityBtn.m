//
//  SNCommentActivityBtn.m
//  sohunews
//
//  Created by wang yanchen on 12-9-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNCommentActivityBtn.h"

#define kIconSpace          (0)
#define kLeftMargin         (0)
#define kTitleFont          (36 / 2)
#define kSofaWidth          (92 / 2)
#define kTitleViewSpace     ((kAppScreenWidth == 320.0) ? 2 : ((kAppScreenWidth == 375.0) ? 3 : (16.0/3-2)))

@interface SNCommentActivityBtn () {
    BOOL _isSofaMode;
}
- (void)fireFunction;
@end

@implementation SNCommentActivityBtn
@synthesize title = _title;
@synthesize enable = _enable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 2, self.width - 20, self.height - 4)];
        _titleView.backgroundColor = [UIColor clearColor];
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
        _titleView.textColor = [UIColor colorFromString:strColor];
        _titleView.font = [UIFont commentNumberFontSize:kThemeFontSizeD];
        _titleView.textAlignment = NSTextAlignmentRight;
        [self addSubview:_titleView];
        
        UIImage *image = [UIImage themeImageNamed:@"icotext_commentsmall_v5.png"];
        _commentIconView = [[UIImageView alloc] initWithImage:image];
        _commentIconView.frame = CGRectMake(_titleView.right + 2, 7, image.size.width, image.size.height);
        [self addSubview:_commentIconView];

        _actView = [[SNWaitingActivityView alloc] init];
        _actView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_actView];
        
        image = [UIImage themeImageNamed:@"comment_sofa.png"];
        _sofaView = [[UIImageView alloc] initWithImage:image];
        _sofaView.center = _actView.center;
        [self addSubview:_sofaView];
        _sofaView.hidden = YES;
        
        [self showLoading:YES];
        self.userInteractionEnabled = YES;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    
    if (_title.length > 0) {
        [self showLoading:NO];
        
        if ([_title intValue] >= 0) {
            _isSofaMode = NO;
            _titleView.hidden = NO;
            _commentIconView.hidden = NO;
            _sofaView.hidden = YES;
            CGSize textSize = [[SNUtility statisticsDataChangeType:_title] sizeWithFont:[UIFont digitAndLetterFontOfSize:kThemeFontSizeD]];
            _titleView.width = textSize.width;
            _commentIconView.left = _titleView.right + kTitleViewSpace;
            self.width = kLeftMargin + textSize.width + kIconSpace + _commentIconView.width + kTitleViewSpace;
            
            //@Dan: tell what to read for blind people
            _titleView.accessibilityLabel = [NSString stringWithFormat:@"%@个评论，双击阅读评论列表", title];
        }
        //不再显示沙发
//        else {
//            _isSofaMode = YES;
//            self.width = kSofaWidth;
//            _titleView.hidden = YES;
//            _commentIconView.hidden = YES;
//            _sofaView.hidden = NO;
//        }
    }
    
    [self setNeedsLayout];

    return;
}

- (void)setEnable:(BOOL)enable
{
    _enable = enable;
    if (_enable) {
        self.userInteractionEnabled = YES;
    } else {
        self.userInteractionEnabled = NO;
    }
}

- (void)setCommentRead:(BOOL)hasRead
{
    NSString *imageName = hasRead ? @"icotext_commentsmall_v5.png" : @"icotext_commentsmall_v5.png";
    UIImage *image = [UIImage themeImageNamed:imageName];
    _commentIconView.image = image;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSString *title = [NSString stringWithFormat:@"%@", _title];
    if (_title) {
        title = [SNUtility statisticsDataChangeType:title];//直接使用_title，返回后容易crash
        _titleView.text = title;
    }
    
    //_titleView.frame = CGRectMake(kLeftMargin, 2, self.width - kIconSpace, self.height - 4);
    
    //_commentIconView.frame = CGRectMake(_titleView.right + 2, 7, _commentIconView.width, _commentIconView.height);
    
    _actView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _sofaView.center = _actView.center;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)showLoading:(BOOL)bShow {
    if (bShow) {
        _titleView.hidden = YES;
        _commentIconView.hidden = YES;
        _sofaView.hidden = YES;
        _actView.hidden = NO;
        [_actView startAnimating];
    }
    else {
        if (_isSofaMode) {
            _titleView.hidden = YES;
            _commentIconView.hidden = YES;
            _sofaView.hidden = NO;
        }
        else {
            _titleView.hidden = NO;
            _commentIconView.hidden = NO;
            _sofaView.hidden = YES;
        }
        _actView.hidden = YES;
        [_actView stopAnimating];
    }
}

- (void)addTarget:(id)target selecor:(SEL)sel {
    _target = target;
    _fuction = sel;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UIImage *image = [UIImage themeImageNamed:@"icotext_commentsmall_v5.png"];
    _commentIconView.image = image;
    image = [UIImage themeImageNamed:@"comment_sofa_p.png"];
    _sofaView.image = image;
    _titleView.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UIImage *image = [UIImage themeImageNamed:@"icotext_commentsmall_v5.png"];
    _commentIconView.image = image;
    image = [UIImage themeImageNamed:@"comment_sofa.png"];
    _sofaView.image = image;
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
    _titleView.textColor = [UIColor colorFromString:strColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    UIImage *image = [UIImage themeImageNamed:@"comment_sofa.png"];
    _sofaView.image = image;
    
    UITouch *tch = [touches anyObject];
    CGPoint pt = [tch locationInView:self];
    if (CGRectContainsPoint(self.bounds, pt)) {
        [self fireFunction];
    }
    
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
    _titleView.textColor = [UIColor colorFromString:strColor];
}

#pragma mark - private methods
- (void)fireFunction {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMethodSignature *signature = [[_target class] instanceMethodSignatureForSelector:_fuction];
    if ([_target respondsToSelector:_fuction]) {
        if ([signature numberOfArguments] == 2) {
            [_target performSelector:_fuction];
        }
        else if ([signature numberOfArguments] == 3) {
            [_target performSelector:_fuction withObject:self];
        }
    }
#pragma clang diagnostic pop
}

- (void)updateTheme
{
    UIImage *image = [UIImage themeImageNamed:@"icotext_commentsmall_v5.png"];
    if (_commentIconView) {
        _commentIconView.image = image;
    }
    _titleView.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    
    image = [UIImage themeImageNamed:@"comment_sofa.png"];
    if (_sofaView) {
        _sofaView.image = image;
    }
}

@end
