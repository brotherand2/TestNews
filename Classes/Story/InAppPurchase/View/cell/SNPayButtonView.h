//
//  SNPayButtonView.h
//  sohunews
//
//  Created by Huang Zhen on 2017/9/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNPayButtonViewDelegate <NSObject>

- (void)payButtonClicked:(UIButton *)sender;

@end

@interface SNPayButtonView : UICollectionReusableView

@property (nonatomic, assign) id <SNPayButtonViewDelegate>delegate;

@end
