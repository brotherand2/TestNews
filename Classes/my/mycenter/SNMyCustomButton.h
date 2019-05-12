//
//  SNMyCustomButton.h
//  sohunews
//
//  Created by weibin cheng on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBubbleTipView.h"

@interface SNMyCustomButton : UIView
{
//    UIButton* _button;
    UIImageView* _imageView;
    UILabel* _label;
    SNBubbleTipView* _bubbleView;
}
@property(nonatomic, strong) NSString* iconName;
@property(nonatomic, strong) NSString* text;
@property(nonatomic, assign) SEL clickSelector;
@property(nonatomic, weak) id delegate;

-(id)initWithFrame:(CGRect)frame;
-(void)setTipCount:(NSInteger)count;
- (void)fixDotImageViewPos;
-(void)updateTheme;
- (void)resetImageViewAndLabelOrigin;
@end
