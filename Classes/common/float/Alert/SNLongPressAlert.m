//
//  SNLongPressAlert.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/4/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNLongPressAlert.h"
#import "SNNewAlertView.h"

#define kBtnHeight  45.0f
#define kBtnMaigin  8.0f

typedef void(^SNLongPressAlertShareBlock)();
typedef void(^SNLongPressAlertSaveBlock)();

@interface SNLongPressAlert ()

@property (nonatomic, strong) SNNewAlertView *longPressAlert;
@property (nonatomic, copy) SNLongPressAlertShareBlock shareBlock;
@property (nonatomic, copy) SNLongPressAlertSaveBlock saveBlock;
@property (nonatomic, strong) UIView *longPressView;
@end

@implementation SNLongPressAlert


- (void)showLongPressAlertWithShareBlock:(void(^)())shareBlock andSaveBlock:(void(^)())saveBlock {
    
    SNNewAlertView *longPressAlert = [[SNNewAlertView alloc] initWithContentView:self.longPressView cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    self.longPressAlert = longPressAlert;
    self.shareBlock = shareBlock;
    self.saveBlock = saveBlock;
    [longPressAlert show];
}


// 保存按钮点击事件
- (void)saveButtonClick {
    
    [self.longPressAlert dismiss];
    if (self.saveBlock) {
        self.saveBlock();
    }
}
// 分享按钮点击事件
- (void)shareButtonClick {
    __weak typeof(self)weakself = self;
    [self.longPressAlert dismissWithCompletion:^{
        if (weakself.shareBlock) {
            weakself.shareBlock();
        }
    }];
}

- (UIView *)longPressView {
    if (_longPressView == nil) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kBtnHeight*2 + kBtnMaigin*2)];
        bgView.backgroundColor = [UIColor clearColor];
        UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [topBtn setTitle:@"分享" forState:UIControlStateNormal];
        [topBtn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
        topBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        topBtn.backgroundColor = [UIColor clearColor];
        topBtn.frame = CGRectMake(0,kBtnMaigin,kAppScreenWidth,kBtnHeight);
        [topBtn addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:topBtn];
        
        UIButton *midBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [midBtn setTitle:@"保存" forState:UIControlStateNormal];
        [midBtn setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
        midBtn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        midBtn.backgroundColor = [UIColor clearColor];
        midBtn.frame = CGRectMake(0,kBtnHeight + kBtnMaigin,kAppScreenWidth,kBtnHeight);
        [midBtn addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:midBtn];
        _longPressView = bgView;
    }
    return _longPressView;
}

@end
