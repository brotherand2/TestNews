//
//  SNCommentShareToolBar.h
//  sohunews
//
//  Created by jialei on 14-3-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCommentShareToolBar : UIView<SNShareManagerDelegate>

@property (nonatomic, assign)BOOL   showView;
@property (nonatomic, strong)NSMutableDictionary *appIdDic;
@property (nonatomic, assign)BOOL   hasSelectedItem;

@end
