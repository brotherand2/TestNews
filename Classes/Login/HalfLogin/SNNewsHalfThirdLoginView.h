//
//  SNNewsHalfThirdLoginView.h
//  sohunews
//
//  Created by wang shun on 2017/10/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNNewsHalfThirdLoginViewDelegate;

@interface SNNewsHalfThirdLoginView : UIView

@property (nonatomic,weak) id <SNNewsHalfThirdLoginViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end

@protocol SNNewsHalfThirdLoginViewDelegate <NSObject>

- (void)thirdLoginWithThirdName:(NSString*)name;

@end
