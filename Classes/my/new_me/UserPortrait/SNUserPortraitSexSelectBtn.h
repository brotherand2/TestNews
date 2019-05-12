//
//  SNUserPortraitSexSelectBtn.h
//  sohunews
//
//  Created by wang shun on 2017/1/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNUserPortraitSexSelectBtnDelegate;
@interface SNUserPortraitSexSelectBtn : UIView

@property (nonatomic,strong) UIImageView* bgImgView;
@property (nonatomic,strong) UIButton* btn;
@property (nonatomic,strong) NSString* imgUrl;

@property (nonatomic,assign) BOOL selected;

@property (nonatomic,weak) id <SNUserPortraitSexSelectBtnDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame WithImage:(NSString*)image;

@end

@protocol SNUserPortraitSexSelectBtnDelegate <NSObject>

- (void)click:(SNUserPortraitSexSelectBtn*)b;

@end
