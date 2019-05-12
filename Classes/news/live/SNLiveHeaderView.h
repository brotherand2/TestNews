//
//  SNLiveHeaderView.h
//  sohunews
//
//  Created by yanchen wang on 12-6-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MoreButtonPressBlock)(NSDictionary *dict);

@interface SNLiveHeaderView : UIView {
    UILabel *_titleLabel;
    UIView *_bar;
}

@property (nonatomic, readonly)UILabel *titleLabel;
@property (strong, nonatomic) NSDictionary *dataDict;
@property (nonatomic, strong) UIView *bar;

- (void)setMoreActionBlock:(MoreButtonPressBlock)block;

@end
