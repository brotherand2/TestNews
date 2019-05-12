//
//  SNTableErrorView.m
//  sohunews
//
//  Created by qi pei on 4/18/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTableErrorView.h"
#define kPadding1      (45/2.0)
#define kPadding2      (24/2.0)
#define kPadding3      (10.0f)

@implementation SNTableErrorView

- (void)layoutSubviews {
    _titleView.font = [UIFont systemFontOfSize:59.0/2];
    _subtitleView.font = [UIFont systemFontOfSize:32.0/2];
    
    _subtitleView.size = [_subtitleView sizeThatFits:CGSizeMake(self.width - kPadding3*2, 0)];
    [_titleView sizeToFit];
    [_imageView sizeToFit];
    
    CGFloat maxHeight = _imageView.height + _titleView.height + _subtitleView.height
    + kPadding1 + kPadding2;
    BOOL canShowImage = _imageView.image && self.height > maxHeight;
    
//    CGFloat totalHeight = 0.0f;
//    
//    if (canShowImage) {
//        totalHeight += _imageView.height;
//    }
//    if (_titleView.text.length) {
//        totalHeight += (totalHeight ? kPadding1 : 0) + _titleView.height;
//    }
//    if (_subtitleView.text.length) {
//        totalHeight += (totalHeight ? kPadding2 : 0) + _subtitleView.height;
//    }
    
    CGFloat top = 93;//floor(self.height/2 - totalHeight/2);
    
    if (canShowImage) {
        _imageView.origin = CGPointMake(floor(self.width/2 - _imageView.width/2), top);
        _imageView.hidden = NO;
        top += _imageView.height + kPadding1;
        
    } else {
        _imageView.hidden = YES;
    }
    if (_titleView.text.length) {
        _titleView.origin = CGPointMake(floor(self.width/2 - _titleView.width/2), top);
        top += _titleView.height + kPadding2;
    }
    if (_subtitleView.text.length) {
        _subtitleView.origin = CGPointMake(floor(self.width/2 - _subtitleView.width/2), top);
    }
}


@end
