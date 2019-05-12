//
//  SohuARGameSCNView.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuARGameSCNView.h"
#import "SohuARGameBaseScene.h"
#import "SohuARSingleton.h"

@implementation SohuARGameSCNView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.allowsCameraControl=NO;
    if ([[[SohuARSingleton sharedInstance] arConfigurations][@"canMoveToTouchPoint"] boolValue]) {
    }
    [self click3DModelWithEvent:event];
}

-(void)move3DModelToTouchPointWithEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    SohuARGameBaseScene *scene=(SohuARGameBaseScene*)self.scene;
    [scene modelMoveToPoint:point];
}

-(void)click3DModelWithEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    NSArray *hitTestResult =[self hitTest:point options:nil];
    if (hitTestResult.count>0) {
        SCNHitTestResult * result=hitTestResult[0];
        SohuARGameBaseScene *scene=(SohuARGameBaseScene *)self.scene;
        [scene clickNode:result.node];
    }
}

@end
