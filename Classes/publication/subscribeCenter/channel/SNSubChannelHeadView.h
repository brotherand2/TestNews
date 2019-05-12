//
//  SNSubChannelHeadView.h
//  sohunews
//
//  Created by wang yanchen on 13-4-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDateLabel.h"

typedef void (^SubBtnAction)();

@interface SNSubChannelHeadView : UIView {
    UILabel *_subTitleLabel;
    UIButton *_subBtn;
    SNDateLabel *_complexLabel;
    UILabel *_timeLabel;
}

@property(nonatomic, copy) NSString *subTitle;
@property(nonatomic, assign) BOOL isSubed;
@property(nonatomic, copy) SubBtnAction action;
@property(nonatomic, copy) NSString *subId;

- (void)setDateString:(NSString *)publishDate;

- (void)updateTheme;

@end
