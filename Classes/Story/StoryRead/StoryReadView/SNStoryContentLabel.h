//
//  SNStoryContentLabel.h
//  StorySoHu
//
//  Created by chuanwenwang on 16/10/12.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNStoryContentLabel : UILabel
- (void)drawTextInRect:(CGRect)rect;
@property (nonatomic, copy)NSString *content;

@property (nonatomic, strong) UIFont *cur_font;

- (void)updateNovelTheme;

@end
