//
//  SNBubbleTipView.h
//  sohunews
//
//  Created by weibin cheng on 13-9-3.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum 
{
    SNHeadBubbleType,
    SNTableBubbleType,
    SNTabbarBubbleType
}SNBubbleType;

typedef enum
{
    SNBubbleAlignLeft,
    SNBubbleAlignRight,
}SNBubbleAlignType;


@interface SNBubbleTipView : UIView
{
    UIImageView* _imageView;
    UILabel* _label;
    SNBubbleType _type;
}

@property(nonatomic, assign) int tipCount;
@property(nonatomic, strong) UIImage* image;
@property(nonatomic, assign) SNBubbleAlignType alignType;
@property(nonatomic, readonly) int defaultHeight;
@property(nonatomic, readonly) int defaultWidth;

- (id)initWithType:(SNBubbleType)type;

- (void)fixDotImageViewPos;

- (void)setBubbleImageFrame:(CGRect) imageFrame withImage:(UIImage *) image;

- (void)updateTheme;
@end
