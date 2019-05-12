//
//  SNLiveLinkView.m
//  sohunews
//
//  Created by chenhong on 13-4-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveLinkView.h"
#import "SNConsts.h"
#import "UIColor+ColorUtils.h"
#import "SNThemeManager.h"
#import "SNSoundManager.h"
#import "SNLiveRoomConsts.h"

@implementation SNLiveLinkView
@synthesize link=_link;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *btn = [[UIButton alloc] initWithFrame:self.bounds];
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:btn];
        //self.backgroundColor = [UIColor redColor];
        _linkLabel = [[UILabel alloc] initWithFrame:frame];
        _linkLabel.textAlignment = NSTextAlignmentLeft;
        //_linkLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _linkLabel.frame = CGRectMake(10, 0, 200, frame.size.height);
        _linkLabel.backgroundColor = [UIColor clearColor];
        //[btn setTitle:@"" forState:UIControlStateNormal];
        //[btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 150)];
        [btn addSubview:_linkLabel];
        
        [_linkLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveRoomContentColor]]];
//        [btn setTitleColor:[UIColor colorFromString:strColor] forState:UIControlStateNormal];
        
        [_linkLabel setFont:[UIFont systemFontOfSize:14]];
        
        
        UIImage *img = [UIImage imageNamed:@"live_link_btn.png"];
        if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        }
        else {
            img = [img stretchableImageWithLeftCapWidth:15 topCapHeight:15];
        }

        [btn setBackgroundImage:img forState:UIControlStateNormal];
        
        
        img = [UIImage imageNamed:@"live_link_arrow.png"];
        [btn setImage:img forState:UIControlStateNormal];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, kAppScreenWidth - 117, 0, 0)]; // 203 = 320 - 117
        
        [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
        
        _linkBtn = btn;
    }
    return self;
}

- (void)updateTheme {

    [_linkLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveRoomContentColor]]];
    
    UIImage *img = [UIImage imageNamed:@"live_link_btn.png"];
    if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    }
    else {
        img = [img stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    }
    
    [_linkBtn setBackgroundImage:img forState:UIControlStateNormal];
    img = [UIImage imageNamed:@"live_link_arrow.png"];
    [_linkBtn setImage:img forState:UIControlStateNormal];
    [_linkBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 203, 0, 0)];
}

- (void)setLink:(NSString *)link {
    if (_link != link) {
        _link = link;
    }
    
    NSString *title = @"";
    
    if (link.length > 0) {
        if ([_link hasPrefix:kProtocolLive]) {
           title = @"进入直播";
        } else if ([_link hasPrefix:kProtocolSpecial] || [_link hasPrefix:kProtocolNews]) {
            title = @"开始阅读";
        } else if ([_link hasPrefix:kProtocolPaper] || [_link hasPrefix:kProtocolDataFlow]) {
            title = @"了解一下";
        } else {
            title = @"打开链接";
        }
    }
    
    //[_linkBtn setTitle:title forState:UIControlStateNormal];
    [_linkLabel setText:title];
    
    [self setNeedsDisplay];
}

- (void)clickBtn {
    // 打开链接时，停止所有音频
    [[SNSoundManager sharedInstance] stopAll];
    // 打开链接时，停止所有视频
    [SNNotificationManager postNotificationName:kSNPlayerViewPauseVideoNotification object:nil];
    
    [SNUtility openProtocolUrl:_link
                       context:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:REFER_LIVE] forKey:kRefer]];
}

@end
