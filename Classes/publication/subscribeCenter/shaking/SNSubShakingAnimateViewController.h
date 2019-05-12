//
//  SNSubShakingAnimateViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//



@class SNSubShakingCenterViewController;
@interface SNSubShakingAnimateViewController : SNBaseViewController
{
    SNSubShakingCenterViewController* _subViewController;
    //Shaking info
    float _currentAngle;
	NSInteger _currentIndex;
	NSMutableArray* _infoArray;
    NSMutableArray* _guideInfoArray;
    BOOL _animationOpen;  //是否正在进行动画
    BOOL _animationReady; //动画时间是否超过最短时间
    BOOL _animationWillStop;
}

@property(nonatomic,strong) NSMutableArray* _infoArray;
@property(nonatomic,strong) NSMutableArray* _guideInfoArray;
@property(nonatomic,strong) SNSubShakingCenterViewController* _subViewController;
@property(nonatomic,assign) BOOL _animationOpen;
@property(nonatomic,assign) BOOL _animationReady;
@property(nonatomic,assign) BOOL _animationWillStop;

-(void)startAnimation;
-(void)startGuideAnimation;
-(void)stopAnimation:(NSInteger)aResult; //0成功 1网络失败 2取不到了
@end
