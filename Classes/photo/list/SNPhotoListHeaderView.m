//
//  SNPhotoListHeaderView.m
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#define kTitleFont                      (20.0)
#define kTitleSourceFont                (10.0)
#define kTitleLeftOffset                (12.0)
#define kShareRightOffset               (10.0)
#define kTitleTopOffset                 (35.0 / 2)
#define kTitleOffsetTime                (25.0 / 2)
#define kSeporatorOffset                (25.0 / 2)
#define kSeporatorOffsetCellImage       (29.0 / 2)
#define kImageOffsetCellText            (25.0 / 2)
#define kButtonSize                     (44.0)
#define kTitleColor                     RGBACOLOR(38, 38, 38, 1)
#define kTitleSourceColor               RGBACOLOR(166, 166, 166, 1)
#define kDecorationLength               (5)

#import "SNPhotoListHeaderView.h"
#import "SNConsts.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"

@implementation SNPhotoListHeaderView

@synthesize delegate = _delegate;
@synthesize sourceInfoLabel = _sourceInfoLabel;

-(id)initWithTitle:(NSString*)title 
              time:(NSString*)time
              from:(NSString*)from
         likeCount:(NSString*)likeCount
          delegate:(id)delegate frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat bottom = 0;
        self.delegate = delegate;
        //标题
        if (title) {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.text     = title;
            [_titleLabel setTextAlignment:UITextAlignmentLeft];
            [_titleLabel setFont:[UIFont systemFontOfSize:kTitleFont]];
            NSString *titleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoListTitleColor];
            [_titleLabel setTextColor:[UIColor colorFromString:titleColor]];

            [_titleLabel setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_titleLabel];
            [_titleLabel release];

            CGFloat width = frame.size.width - 20;
            CGSize size = [title sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(width, 300) lineBreakMode:_titleLabel.lineBreakMode];
            _titleLabel.frame = CGRectMake(kTitleLeftOffset, kTitleTopOffset, width, size.height);
            _titleLabel.numberOfLines = 0;
            _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            //hack，评论标题多于两会省略显示
            int titleLine = 0;
            if (_titleLabel.font.lineHeight > 0) {
                titleLine = size.height / _titleLabel.font.lineHeight;
            }
            
            if (!time && titleLine > 2) {
                _titleLabel.frame = CGRectMake(kTitleLeftOffset, kTitleTopOffset, width, _titleLabel.font.lineHeight * 2);
            }
            bottom = _titleLabel.bottom;
        }
        
        //时间 来源 喜欢人数
        if (time || from || likeCount) {
            _sourceInfoLabel  = [[UILabel alloc] init];
            NSMutableString *titleDetail = [[NSMutableString alloc] init];
            if (time) {
                [titleDetail appendString:time];
                [titleDetail appendString:@"    "];
            }
            if (from && [from length] > 0) {
                [titleDetail appendString:from];
                [titleDetail appendString:@"    "];
            }
            if (likeCount.length > 0 && [likeCount intValue] > 0) {
                [titleDetail appendString:[NSString stringWithFormat:NSLocalizedString(@"favoriteCount", nil),likeCount]];
            }
            _sourceInfoLabel.text = [NSString stringWithString:titleDetail];
            [titleDetail release];
            
            [_sourceInfoLabel setTextAlignment:UITextAlignmentLeft];
            [_sourceInfoLabel setFont:[UIFont systemFontOfSize:kTitleSourceFont]];
            NSString *sourceColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoListSourceColor];
            [_sourceInfoLabel setTextColor:[UIColor colorFromString:sourceColor]];
            [_sourceInfoLabel setBackgroundColor:[UIColor clearColor]];
            [self addSubview:_sourceInfoLabel];
            [_sourceInfoLabel release]; 
            
            double offset = 0.0;
            if (_titleLabel) {
                offset += _titleLabel.origin.y + _titleLabel.bounds.size.height + kTitleOffsetTime;
            } else {
                offset = kTitleTopOffset;
            }
            _sourceInfoLabel.frame = CGRectMake(kTitleLeftOffset, offset, frame.size.width - 20, kTitleSourceFont + 2);

            bottom = _sourceInfoLabel.bottom;
        }
        
        CGRect viewRect = CGRectMake(0, _titleLabel.origin.y,
                                     kDecorationLength, (bottom - _titleLabel.origin.y));
        _redDecorationView = [[UIView alloc]initWithFrame:viewRect];
        NSString *decorationColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kContentSolidColor];
        _redDecorationView.backgroundColor = [UIColor colorFromString:decorationColor];
        [self addSubview:_redDecorationView];
        [_redDecorationView release];

        self.height = bottom + 10;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme)
                                                     name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeDidChangeNotification object:nil];
    [super dealloc];
}

- (void)setReadCount:(NSString *)readCount
{
    NSString *titleString = [NSString stringWithFormat:@"%@%@人已读", self.sourceInfoLabel.text, readCount];
    self.sourceInfoLabel.text = titleString;
}

- (void)updateTheme {
    NSString *titleColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoListTitleColor];
    [_titleLabel setTextColor:[UIColor colorFromString:titleColor]];
    if (_sourceInfoLabel) {
        NSString *sourceColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoListSourceColor];
        [_sourceInfoLabel setTextColor:[UIColor colorFromString:sourceColor]];
    }
    if (_redDecorationView) {
        NSString *decorationColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kContentSolidColor];
        _redDecorationView.backgroundColor = [UIColor colorFromString:decorationColor];
    }
    if (_seperator) {
        NSString *fileName = [[SNThemeManager sharedThemeManager] themeFileName:@"list_headline.png"];
        UIImage *sepImg = [[UIImage imageNamed:fileName] scaledImage];
        _seperator.image = sepImg;
    }
}

@end
