//
//  SNImmediateMessageStatusBarLabel.m
//  sohunews
//
//  Created by handy wang on 7/13/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNImmediateMessageStatusBarLabel.h"
#import "UIColor+ColorUtils.h"

#define SELF_ICON_WIDTH                                             (48/2.0f)
#define SELF_ICON_HEIGHT                                            (28/2.0f)

@implementation SNImmediateMessageStatusBarLabel

@synthesize text;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                              (self.bounds.size.height-SELF_ICON_HEIGHT)/2.0f,
                                                              SELF_ICON_WIDTH,
                                                              SELF_ICON_HEIGHT)];
    
        _icon.image = [UIImage imageNamed:@"download_statusbar_message_icon.png"];
        [self addSubview:_icon];
        _icon.hidden = YES;
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(SELF_ICON_WIDTH+2,
                                                                  0,
                                                                  self.bounds.size.width-SELF_ICON_WIDTH,
                                                                  self.bounds.size.height)];
		_messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        
        _messageLabel.textColor = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? [UIColor blackColor] : [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kMessageTextColor]];
		_messageLabel.font = [UIFont boldSystemFontOfSize:12];
        
        [self addSubview:_messageLabel];
    }
    return self;
}

-(void)updateTheme {
    _icon.image = [UIImage imageNamed:@"download_statusbar_message_icon.png"];
    _messageLabel.textColor = SNUICOLOR(kSubHomeTableCellContentTextColor);
}

- (void)updateStausBarStyle:(NSString *)style
{
    if ([style isEqualToString:@"blackStyle"])
    {
        //黑底
        _messageLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kMessageTextColor]];
    }
    else
    {
        //白底
        _messageLabel.textColor = [UIColor blackColor];
    }
}

- (void)setText:(NSString *)textParam {
    _icon.hidden = [@"" isEqualToString:textParam];
    _messageLabel.text = textParam;
}

- (NSString *)text {
    return _messageLabel.text;
}

- (void)dealloc {
    
     //(_messageLabel);
     //(_icon);
    
    
}

@end
