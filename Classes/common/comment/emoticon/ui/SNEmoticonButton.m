//
//  SNEmoticonButton.m
//  sohunews
//
//  Created by jialei on 14-5-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNEmoticonButton.h"
#import "SNEmoticonObject.h"

#define SN_EMOTICON_DES_FONT            (24 / 2)
#define SN_EMOTICON_ICON_WIDTH          (86 / 2)
#define SN_EMOTICON_DES_GAP             (6 / 2)

@implementation SNEmoticonButton

- (id)initWithEmoticon:(SNEmoticonObject *)emoticon frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.emoticonObj = emoticon;
        [self createView];
        [self addTarget:self action:@selector(emoticonBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc
{
     //(_emoticonObj);
     //(_clickedBlock);
    
}

- (void)createView
{
    // 表情ImageView.
    UIImageView *emoticonImageView = [[UIImageView alloc] init];
    emoticonImageView.size = CGSizeMake(SN_EMOTICON_ICON_WIDTH, SN_EMOTICON_ICON_WIDTH);
    emoticonImageView.top = 0;
    emoticonImageView.centerX = self.centerX;
    
    emoticonImageView.image = [_emoticonObj emoticonImage];
    emoticonImageView.contentMode = UIViewContentModeCenter;
    emoticonImageView.alpha = themeImageAlphaValue();
    [self addSubview:emoticonImageView];
    
    // 表情提示label
    UILabel *emoticonDesLabel = [[UILabel alloc] init];
    
    CGSize size = [_emoticonObj.description sizeWithFont:[UIFont systemFontOfSize:SN_EMOTICON_DES_FONT]];
    emoticonDesLabel.size = CGSizeMake(size.width + 2, size.height + 2);
    emoticonDesLabel.top = emoticonImageView.bottom + SN_EMOTICON_DES_GAP;
    emoticonDesLabel.centerX = self.centerX;
    emoticonDesLabel.text = _emoticonObj.description;
    emoticonDesLabel.font = [UIFont systemFontOfSize:SN_EMOTICON_DES_FONT];
    emoticonDesLabel.textColor = RGBCOLOR(66,66,66);;//SNUICOLOR(kCommentTextTipColor);
    emoticonDesLabel.contentMode = UIViewContentModeCenter;
    emoticonDesLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:emoticonDesLabel];
}

#pragma mark- clickAction
- (void)emoticonBtnClicked
{
    //todo
//    [SNNotificationManager postNotificationName:notificationBigEmoticonSelect object:_emoticonObj];
    if (self.clickedBlock) {
        self.clickedBlock(self.emoticonObj);
    }
}

@end
