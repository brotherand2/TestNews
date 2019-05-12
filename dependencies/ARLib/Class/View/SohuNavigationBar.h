//
//  SohuNavigationBar.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SohuNavigationBar;

@protocol SohuNavigationBarDelegate <NSObject>

-(void)sohuNavigationBar:(SohuNavigationBar *) sohuNavigationBar countdownCount:(NSInteger)countdownCount;

@end

@interface SohuNavigationBar : UIView

@property(nonatomic,assign) NSInteger countdownCount;
@property(nonatomic,assign) NSInteger counter;
@property(nonatomic,strong) UIImage  *counterImage;
@property(nonatomic,strong) NSTimer *gameTimer;
@property(nonatomic,weak)   id<SohuNavigationBarDelegate> barDelegate;

-(void)stopTimer;
-(void)pauseTimer;
-(void)resumeTimer;
-(void)resettingTimer;

-(void)setupCounterWithCounter:(NSInteger)counter;
-(void)setupCounterWithCountdownCount:(NSInteger)downCount;

-(void)startDownCount;

@end
