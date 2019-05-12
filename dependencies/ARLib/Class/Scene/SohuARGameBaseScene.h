//
//  SohuARGameBaseScene.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import "SohuFileManager.h"
#import "SohuToolbar.h"
#import "SohuNavigationBar.h"
#import "SohuARAlertView.h"
#import "SohuReadyView.h"

typedef NS_ENUM(NSInteger ,SohuModelActionType) {
    SohuModelActionTypePlusCounter,
};

typedef NS_ENUM(NSInteger ,SohuSceneType) {
    SohuSceneTypeClick,
    SohuSceneTypeAnimation,
    SohuSceneTypeProduct,
    SohuSceneTypeSohuPhotograph,
};

@class SohuARGameBaseScene;

@protocol SohuARGameBaseSceneDelegate <NSObject>

-(void)sohuARGameBaseScene:(SohuARGameBaseScene *)sohuARGameBaseScene
                  didClick:(NSInteger)index;

@end

@interface SohuARGameBaseScene : SCNScene

@property(nonatomic,strong) SCNNode *cameraNode;
@property(nonatomic,strong) SCNNode *modelNode;
@property(nonatomic,strong) UIView *superview;
@property(nonatomic,assign) NSInteger sloganInterval;
@property(nonatomic,strong) NSMutableArray *actionArray;
@property(nonatomic,strong) NSArray *modelPathArray;
@property(nonatomic,weak)   id<SohuARGameBaseSceneDelegate> delegate;

@property(nonatomic,strong) SohuNavigationBar *navigationBar;
@property(nonatomic,strong) SohuToolbar *toolBar;
@property(nonatomic,strong) SohuARAlertView *alertView;

@property(nonatomic,assign) BOOL enbleStar;
@property(nonatomic,assign) BOOL enbleEnd;

@property(nonatomic,strong) NSMutableArray *animationArray;
@property(nonatomic,strong) CAAnimationGroup *animationGroup;
@property(nonatomic,assign) NSInteger currentTimeOffset;
@property(nonatomic,assign) CGFloat maxDuration;

-(void)setupView;
-(void)deviceMotionUpdatesWithDeviceMotion:(CMDeviceMotion *)motion;
-(void)clickNode:(SCNNode *)node;
-(void)modelMoveToPoint:(CGPoint)point;
-(void)sceneDidAppear;
-(void)sceneDidDisappear;
-(void)setupSceneWith3DModelPathArray:(NSArray *)modelPathArray;
-(void)sohuARAlertView:(SohuARAlertView *)sohuARAlertView
      didClickItemType:(ARAlertViewItemType)arARAlertViewItemType
             parameter:(NSDictionary *)parameter;


@end
