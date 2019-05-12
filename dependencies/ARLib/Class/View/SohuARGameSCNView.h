//
//  SohuARGameSCNView.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>


@class SohuARGameSCNView;

@protocol SohuARGameSCNViewHitSCNNodeDelegate <NSObject>

-(void)sohuARGameSCNView:(SohuARGameSCNView *)sohuARGameSCNView clickNode:(SCNNode *)clickNode;

@end

@interface SohuARGameSCNView : SCNView

@property(nonatomic,assign) BOOL canMoveToTouchPoint;
@property(nonatomic,weak) id<SohuARGameSCNViewHitSCNNodeDelegate> hitDelegate;

@end
