//
//  SNHomeScrollView.m
//  sohunews
//
//  Created by HuangZhen on 2017/11/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNHomeScrollView.h"

@implementation SNHomeScrollView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[SNHomeScrollView class]] && [otherGestureRecognizer.view isKindOfClass:[UICollectionView class]]) {
        [gestureRecognizer requireGestureRecognizerToFail:otherGestureRecognizer];
    }
    return NO;
}


@end
