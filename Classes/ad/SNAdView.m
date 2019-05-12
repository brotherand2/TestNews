//
//  SNAdView.m
//  sohunews
//
//  Created by Xiang Wei Jia on 2/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAdView.h"

@interface SNAdView()

@end

@implementation SNAdView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)exposure
{
    if (nil != _exposureBlock)
    {
        _exposureBlock(self);
    }
}

// 此接口的点击逻辑需要所有子类来完成，因为需要传入点击的控件
- (void)click
{

}

- (void)uninteresting
{
    if (nil != _uninterestingBlock)
    {
        _uninterestingBlock(self);
    }
}


@end
