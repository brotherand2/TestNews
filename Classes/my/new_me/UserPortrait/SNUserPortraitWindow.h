//
//  SNUserPortraitWindow.h
//  sohunews
//
//  Created by wang shun on 2017/1/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNUserPortraitWindow : UIView

@property (nonatomic,strong) UILabel* contentlabel;

- (void)setContentText:(NSString*)str;

@end
