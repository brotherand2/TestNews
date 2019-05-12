//
//  SNTrainClickLabel.h
//  sohunews
//
//  Created by Huang Zhen on 2017/10/31.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SNTrainLabelClickBlock)();

@interface SNTrainClickLabel : UILabel

@property (nonatomic, copy) SNTrainLabelClickBlock clickBlock;

@end
