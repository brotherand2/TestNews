//
//  SNDingImageView.h
//  sohunews
//
//  Created by lhp on 6/28/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kApprovalViewWidth  25
#define kApprovalViewHeight 25

@interface SNDingView : UIView{
    
    UIImageView *_dingImageView;
    BOOL _animating;
}

@property(nonatomic,strong) UIImageView *dingImageView;
- (void)beginAnimation;
- (void)doAnimation:(BOOL)isHighLight;
- (void)updateTheme;
@end
