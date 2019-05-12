//
//  SNUninterestedView.h
//  sohunews
//
//  Created by 赵青 on 2016/12/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNUninterestedItem.h"

@interface SNUninterestedView : UIView {
    SNUninterestedItem *_uninterestedItem;
    NSMutableArray *_selectedReasons;
    UIButton *confirmBtn;
}

typedef void (^ConfirmBtnClickBlock)(NSArray *selectedReasons);

@property (nonatomic, copy)ConfirmBtnClickBlock confirmBtnClickBlock;

- (id)initWithUninterestedItem:(SNUninterestedItem *)item;
- (CGFloat)getHeight;

@end
