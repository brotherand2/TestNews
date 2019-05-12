//
//  SNChannelPromotionView.m
//  sohunews
//
//  Created by Cae on 15/4/17.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNChannelPromotionView.h"
#import "SNNameButton.h"

#define kTitleLabelHeight  (17.0f)
//#define kTitleMargin        (kAppScreenWidth > 375 ? 28 : 24)
#define kTitleMargin        (kAppScreenWidth > 375 ? 14 : 12)

#define kCPImageWidth       (18)
#define kCPImageRight       (kAppScreenWidth > 375 ? (14.0/3) : 3)
#define kCPButtonHeight       (20)
#define kCPButtonMargin      (kAppScreenWidth > 375 ? (28.0/3) : 12)
#define kCPButtonHeightInterval   (15)
#define kCPButtonWidthInterval    (30)

@interface SNChannelPromotionView ()

@property (nonatomic, retain) UILabel *titleLabel;

@end

@implementation SNChannelPromotionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithModelArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.modelArray = array;
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(14, kTitleMargin, kAppScreenWidth, kTitleLabelHeight)] autorelease];
        self.titleLabel.text = @"相关频道";
        self.titleLabel.textColor = SNUICOLOR(kThemeText4Color);
        self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeD];
        CGFloat width = 14;
        CGFloat height = kTitleMargin + kTitleLabelHeight + kCPButtonMargin;
        
        if (kAppScreenWidth > 375) {
            for (NewsTagChannelItem *tagChannelItem in self.modelArray) {
                NSString *title = tagChannelItem.name;
                NSInteger index = [self.modelArray indexOfObject:tagChannelItem];
                
                CGSize size = [title textSizeWithFont:font];
                CGFloat newWidth = width + kCPImageWidth + kCPImageRight + size.width + 14;
                if (newWidth > kAppScreenWidth) {
                    width = 14;
                    height += kCPButtonHeight + kCPButtonHeightInterval;
                }
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(width, height, kCPImageWidth + kCPImageRight + size.width, kCPButtonHeight);
                button.tag = index;
                button.backgroundColor = [UIColor clearColor];
                [button setImage:[UIImage imageNamed:@"icotext_tag_v5.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"icotext_tagpress_v5.png"] forState:UIControlStateHighlighted];
                [button setTitle:title forState:UIControlStateNormal];
                [button setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
                button.titleLabel.font = font;
                button.imageEdgeInsets = UIEdgeInsetsMake(1, 0, 1, size.width+kCPImageRight);
//                button.titleEdgeInsets = UIEdgeInsetsMake(0, kCPImageWidth + kCPImageRight, 0, 0);
                [button addTarget:self action:@selector(onClickChannel:) forControlEvents:UIControlEventTouchUpInside];
                
                [self addSubview:button];

                width += kCPImageWidth + kCPImageRight + size.width + kCPButtonWidthInterval;
            }
            height += kCPButtonHeight + kCPButtonHeightInterval;
            self.width = kAppScreenWidth;
            self.height = height;
            
        } else {
            for (NewsTagChannelItem *tagChannelItem in self.modelArray) {
                NSString *title = tagChannelItem.name;
                NSInteger index = [self.modelArray indexOfObject:tagChannelItem];

                CGSize size = [title textSizeWithFont:font];

                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(width + (index%3)*((kAppScreenWidth-28)/3), height+(index/3)*(kCPButtonHeight+kCPButtonHeightInterval), kCPImageWidth + kCPImageRight + size.width, kCPButtonHeight);
                button.tag = index;
                button.backgroundColor = [UIColor clearColor];
                [button setImage:[UIImage imageNamed:@"icotext_tag_v5.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"icotext_tagpress_v5.png"] forState:UIControlStateHighlighted];
                [button setTitle:title forState:UIControlStateNormal];
                [button setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
                button.titleLabel.font = font;
                button.imageEdgeInsets = UIEdgeInsetsMake(1, 0, 1, size.width+kCPImageRight);
//                button.titleEdgeInsets = UIEdgeInsetsMake(0, kCPImageWidth + kCPImageRight, 0, 0);
                [button addTarget:self action:@selector(onClickChannel:) forControlEvents:UIControlEventTouchUpInside];
                
                [self addSubview:button];
                
            }
            if (self.modelArray.count <= 3) {
                height += kCPButtonHeight +kCPButtonHeightInterval;
            } else {
                height += kCPButtonHeight*2 + kCPButtonHeightInterval*2;
            }
            
            self.width = kAppScreenWidth;
            self.height = height;
        }
    }
    return self;
}

- (void) onClickChannel:(UIButton *)channelButton
{
    NSInteger index = channelButton.tag;
    NewsChannelItem *channelItem = [self.modelArray objectAtIndex:index];
    if (channelItem.link) {
        if ([channelItem.link rangeOfString:@"&amp;"].location != NSNotFound) {//去html编码
            channelItem.link = [channelItem.link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        }
        [SNUtility openProtocolUrl:channelItem.link context:nil];
    }
}

- (void) dealloc
{
    TT_RELEASE_SAFELY(_modelArray);
    TT_RELEASE_SAFELY(_titleLabel);
    [super dealloc];
}

+ (NSInteger) heightForModelArray:(NSArray *)modelArray
{
    UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeD];
    CGFloat width = 14;
    CGFloat height = kTitleMargin + kTitleLabelHeight + kCPButtonMargin;
    if (kAppScreenWidth > 375) {
        for (NewsTagChannelItem *tagChannelItem in modelArray) {
            NSString *title = tagChannelItem.name;
            CGSize size = [title textSizeWithFont:font];
            CGFloat newWidth = width + kCPImageWidth + kCPImageRight + size.width + 14;
            if (newWidth > kAppScreenWidth) {
                width = 14;
                height += kCPButtonHeight + kCPButtonHeightInterval;
            }
            
            width += kCPImageWidth + kCPImageRight + size.width + kCPButtonWidthInterval;
        }
        height += kCPButtonHeight + kCPButtonHeightInterval;
    } else {
        if (modelArray.count <= 3) {
            height += kCPButtonHeight +kCPButtonHeightInterval;
        } else {
            height += kCPButtonHeight*2 + kCPButtonHeightInterval*2;
        }
    }
    
    return height;
}

- (void) updateTheme
{
    self.titleLabel.textColor = SNUICOLOR(kRecommnedNewsViewTitleColor);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
