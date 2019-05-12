//
//  SNThirdLoginView.h
//  sohunews
//
//  Created by wang shun on 2017/4/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNThirdLoginViewDelegate;
@interface SNThirdLoginView : UIView

@property (nonatomic,weak) id <SNThirdLoginViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end

@protocol SNThirdLoginViewDelegate <NSObject>

- (void)thirdLoginWithThirdName:(NSString*)name;

@end
