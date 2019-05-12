//
//  SNNewsScreenCheckBoxView.h
//  sohunews
//
//  Created by wang shun on 2017/8/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNNewsScreenCheckBoxViewdelegate;
@interface SNNewsScreenCheckBoxView : UIView

@property (nonatomic,weak) id <SNNewsScreenCheckBoxViewdelegate> delegate;

- (void)setCheckBoxSelected:(BOOL)isSelected;
- (void)setExpired:(BOOL)expired;

@end

@protocol SNNewsScreenCheckBoxViewdelegate <NSObject>

- (BOOL)selectedCheckBox:(BOOL)isSelected;

@end
