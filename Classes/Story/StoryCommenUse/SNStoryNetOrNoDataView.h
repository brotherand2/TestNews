//
//  SNStoryNetOrNoDataView.h
//  sohunews
//
//  无网络或无数据的view
//
//  Created by chuanwenwang on 16/11/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNStoryNetOrNoDataView : UIButton
{
    UILabel *_storyLabel;
    NSString *_imageName;
    UIFont *_font;
    float _gap;
    BOOL _isTap;
}

@property(nonatomic, assign)NSUInteger pageType;
@property(nonatomic, strong)UILabel *storyLabel;
@property(nonatomic, strong)UIImageView *failImageView;
@property(nonatomic, strong)NSString *imageName;
@property(nonatomic, strong)UIFont *font;
@property(nonatomic, assign)float gap;
@property(nonatomic, assign)BOOL isTap;
@end
