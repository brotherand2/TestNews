//
//  SNEmoticonDynamicScrollView.h
//  sohunews
//
//  Created by jialei on 14-5-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNEmoticonStaticScrollView.h"

@interface SNEmoticonDynamicScrollView : SNEmoticonStaticScrollView<UIScrollViewDelegate>

@property (nonatomic, weak) id <SNEmoticonScrollViewDelegate>emoticonDelegate;

- (id)initWithObjects:(NSArray *)objects frame:(CGRect)frame;

@end
