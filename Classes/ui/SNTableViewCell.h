//
//  SNTableViewCell.h
//  sohunews
//
//  Created by Gao Yongyue on 13-9-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectButtonWidth ((kAppScreenWidth > 375.0) ? 63.0/3 : 42.0/2)
#define kSelectButtonLeftDistance ((kAppScreenWidth > 375.0) ? 42.0/3 : 32.0/2)

@interface SNTableViewCell : UITableViewCell {
    UIButton *_selectButton;
    NSString *_idsString;
    NSString *_linkString;
}

@property(nonatomic, strong)UIButton *selectButton;
@property(nonatomic, strong)NSString *idsString;
@property(nonatomic, strong)NSString *linkString;

- (void)setEditMode;
- (void)setNormalMode;
- (void)initSelectButton;
- (void)setLineTop:(CGFloat)top hidden:(BOOL)hidden;//5.9.4 wangchuanwen add
- (void)updateTheme;
@end
