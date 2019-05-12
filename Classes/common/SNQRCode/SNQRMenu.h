//
//  SNQRMenu.h
//  HZQRCodeDemo
//
//  Created by H on 15/11/4.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNQRItem.h"

typedef void(^QRMenuDidSelectedBlock)(SNQRItem *item);

@interface SNQRMenu : UIView

@property (nonatomic, copy) QRMenuDidSelectedBlock didSelectedBlock;

@property (nonatomic, retain) SNQRItem * lightBtn;

- (instancetype)initWithFrame:(CGRect)frame;

@end
