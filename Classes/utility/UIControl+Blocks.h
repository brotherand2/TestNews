//
//  UIControl+Block.h
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIControlBlock)(UIControl *control);

/*
 为UIControl添加block支持，常用的有UIButton
 block会被retain
*/
@interface UIControl(CustomBlocks)
- (void)addActionBlock:(UIControlBlock)actionBlock forControlEvents:(UIControlEvents)event;
- (void)setActionBlock:(UIControlBlock)actionBlock forControlEvents:(UIControlEvents)event;
@end
