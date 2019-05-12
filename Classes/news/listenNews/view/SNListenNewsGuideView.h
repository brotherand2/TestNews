//
//  SNListenNewsGuideView.h
//  sohunews
//
//  Created by jialei on 14-6-27.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SN_GIDEVIEW_HEIGHT  (140 / 2)
#define SN_GIDEVIEW_WIDTH   (400 / 2)

typedef void (^SNListenNewsGuideClickBlock)();
@interface SNListenNewsGuideView : UIView<UIGestureRecognizerDelegate>
@property (nonatomic, copy) SNListenNewsGuideClickBlock guideBlock;
@end
