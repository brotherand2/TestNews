//
//  SNVideoComplexImageView.h
//  sohunews
//
//  Created by weibin cheng on 14-8-8.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"
#import "SNGlobal_ios7.h"

#define kVideoCellComplexImageViewWidth 93
#define kVideoCellComplexImageViewHeight (73 *kAppScreenWidth / 320)

typedef void(^SNVideoComplexImageViewClickBlock)(NSInteger tag);

@interface SNVideoComplexImageView : UIView
{
    SNWebImageView* _imageView;
    UILabel*        _titleLabel;
}
@property (nonatomic, copy) SNVideoComplexImageViewClickBlock clickBlock;

- (void)setImageUrl:(NSString*)url;

- (void)setTitle:(NSString*)title;

- (void)updateTheme;
@end
