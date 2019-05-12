//
//  SohuReadyView.h
//  SohuAR
//
//  Created by sun on 2016/12/12.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SohuReadyView : UIView

@property(nonatomic, strong) UIImageView *readyView;
@property(nonatomic, strong) UIImageView *goView;

- (void)setupReadyViewWithAnimation;

@end
