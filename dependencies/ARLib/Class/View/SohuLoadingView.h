//
//  SohuLoadingView.h
//  SohuAR
//
//  Created by sun on 2016/11/30.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SohuLoadingView : UIView

@property(nonatomic,assign) CGFloat downloadProgress;
@property(nonatomic,strong) UILabel *loadingLabel;

@end
