//
//  SNNewsScreenSharefocalBtn.h
//  sohunews
//
//  Created by wang shun on 2017/8/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsScreenSharefocalBtnDelegate;
@interface SNNewsScreenSharefocalBtn : UIView

@property (nonatomic,weak) id <SNNewsScreenSharefocalBtnDelegate> delegate;
@end

@protocol SNNewsScreenSharefocalBtnDelegate <NSObject>

- (void)focalBtnPress:(id)sender;

@end
