//
//  SNSubShakingItemView.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCSubscribeObject;
@class SNSubShakingCenterViewController;
@interface SNSubShakingItemView : UIView
{
    BOOL _checked;
    SCSubscribeObject* _dataObject;
    SNSubShakingCenterViewController* __weak _subViewController;
}

@property(nonatomic,assign) BOOL _checked;
@property(nonatomic,strong) SCSubscribeObject* _dataObject;
@property(nonatomic,weak) SNSubShakingCenterViewController* _subViewController;

-(id)initWithFrame:(CGRect)frame object:(SCSubscribeObject*)aObject;
-(void)checkboxTaped:(id)sender;
-(void)updateTheme:(NSNotification*)notifiction;
@end
