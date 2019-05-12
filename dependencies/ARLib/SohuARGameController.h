//
//  SohuARGameController.h
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class SohuARGameController;

@protocol SohuARGameControllerDelegate <NSObject>

-(void)sohuARGameController:(nullable SohuARGameController *)sohuARGameController webViewParameter:(nullable NSDictionary *)parameter;

@end

@interface SohuARGameController : SNBaseViewController

@property(nonatomic,strong,nonnull) NSString *  userID;
@property(nonatomic,strong,nonnull) NSString * activityID;
@property(nonatomic,strong,nonnull) NSDictionary *  otherParameter;
@property(nullable,nonatomic,weak) id<SohuARGameControllerDelegate> delegate;

@end
