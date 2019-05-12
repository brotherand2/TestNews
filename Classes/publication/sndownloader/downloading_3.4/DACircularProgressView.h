//
//  DACircularProgressView.h
//  DACircularProgress
//
//  Created by Daniel Amitay on 2/6/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

/* 使用demo
 目前_trackRadius属性还没有完全支持，设了也白设置，别都好
 可以调用updateProgress法更新进度
 progressRect = CGRectMake(17+2, 18+44+2, 80, 80);
 _progressBar = [[DACircularProgressView alloc] initWithFrame:progressRect];
 _progressBar.innerRadius = 35;
 _progressBar.backgroundColor = [UIColor clearColor];
 _progressBar.trackTintColor = [UIColor clearColor];
 _progressBar.progressTintColor = [UIColor redColor];
 [self.view addSubview:_progressBar];
 */

#import <UIKit/UIKit.h>

#define DEFAULT_RADIUS (0.0f)
#define DEFAULT_TRACK_RATE (0.3f)
#define DEFAULT_RECT (CGRectMake(0.0f, 0.0f, 40.0f, 40.0f))
#define DEGREES_2_RADIANS(x) (0.0174532925 * (x))
#define UPDATE_STEP (0.1f) //动画过程中每次更新的比率,代表0.1%
#define UPDATE_INTERVAL (0.01f)
#define UPDATE_TIME_EACH (1.0f) //每次动画更新所给的时间
//#define DACIRCULARPROGRESS_DEBUG

typedef enum
{
    EUnset,
	EClockwise,
    ECounter_clockwise
} TDirection;

@protocol DACircularProgressViewDelegate <NSObject>
@optional
-(void)notifyAnimationUpdateTo:(NSInteger)aPercent;
@end

@interface DACircularProgressView : UIView
{
    //根据进度情况动态设置速度，这样做的目的是不至于因为执行动画而落后实际进度太多;默认为false;
    BOOL _dySpeed;
    //进度只许加不许减，避免出现因调整下载内容而出现的进度条回跑的尴尬情况；模式为false
    BOOL _increaseOnly;
    NSInteger _lastNotifyUpdate;
    //颜色描述，有默认，不设走默认
    UIColor* _trackTintColor;       //背景色
    UIColor* _progressTintColor;    //前景色
    //圆环绕尺寸信息，可以设置尺寸，尺寸优先于比率；有默认，不设走默认
    CGFloat _trackRate;
    CGFloat _trackRadius;
    CGFloat _innerRadius;
    //回调，animation时使用
    id<DACircularProgressViewDelegate> _delegate;
}

@property(nonatomic, assign)BOOL dySpeed;
@property(nonatomic, assign)BOOL increaseOnly;
@property(nonatomic, assign)NSInteger lastNotifyUpdate;
@property(nonatomic, assign)id<DACircularProgressViewDelegate> delegate;
@property(nonatomic, strong)UIColor* trackTintColor;
@property(nonatomic, strong)UIColor* progressTintColor;
@property(nonatomic, assign)CGFloat trackRate;
@property(nonatomic, assign)CGFloat trackRadius;
@property(nonatomic, assign)CGFloat innerRadius;

-(void)resetNow;
-(void)updateProgress:(CGFloat)progress anmiated:(BOOL)aAnimated; //progress must be bettween [0 and 1]
-(void)invalidateTimer;

@end