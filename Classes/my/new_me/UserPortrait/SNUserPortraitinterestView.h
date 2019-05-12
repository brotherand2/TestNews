//
//  SNUserPortraitinterestView.h
//  sohunews
//
//  Created by iOS_D on 2016/12/23.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNUserPortraitinterestView : UIView

@property (nonatomic,strong) UIView*  bgView;
@property (nonatomic,strong) UILabel* contentLabel;
@property (nonatomic,strong) UIImageView* yesView;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,strong) NSDictionary* info;

- (void)setContentData:(NSString*)content;

@end
