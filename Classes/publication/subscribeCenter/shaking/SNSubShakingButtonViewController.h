//
//  SNSubShakingButtonViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//



@class SNSubShakingCenterViewController;
@interface SNSubShakingButtonViewController : SNBaseViewController
{
    SNSubShakingCenterViewController* _subViewController;
}

@property(nonatomic,strong) SNSubShakingCenterViewController* _subViewController;

-(BOOL)ischecking;
-(void)appearWithAnimation;
@end
