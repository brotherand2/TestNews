//
//  SNUserPortrait.h
//  sohunews
//
//  Created by wang shun on 2017/1/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SNUserPortrait : NSObject

@property(nonatomic, strong) NSDictionary *faceInfo;
@property(nonatomic, assign) NSInteger top_space;
@property(nonatomic, assign) BOOL isOpenFaceInfo;

//访问接口
- (void)getUserPortraitFaceInfoCompletionBlock:(void(^)(void))method;

//get save 本地数据
- (void)getUserPortraitLocalInfoData:(NSDictionary*)info;
- (void)saveUserPortraitLocalInfoData:(NSDictionary*)info;

//处理数据
- (NSMutableArray*)addUserPortraitInitData:(NSMutableArray*)sectionArr;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath ;


+ (BOOL)isFirstOpen;
+ (UIView*)OpenWindow:(UIView*)view;
+ (void)closeUserWindow;
+ (UIFont*)windowFont;

+ (void)getCurrentFaceInfoData;

@end
