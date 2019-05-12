//
//  SNVoucherCenterViewModel.h
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVoucherCenterViewController.h"

@interface SNVoucherCenterViewModel : NSObject<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray * products;
@property (nonatomic, weak) SNVoucherCenterViewController * controller;

- (void)registAllCell;

@end
