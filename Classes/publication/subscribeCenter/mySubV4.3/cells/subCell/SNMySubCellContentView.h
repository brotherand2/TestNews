//
//  SNMySubCellContentView.h
//  sohunews
//
//  Created by jojo on 14-5-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNMySubCellContentView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) SCSubscribeObject *subObj;

- (void)updateTheme;

@end
