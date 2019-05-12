//
//  SNFBTypeModel.h
//  sohunews
//
//  Created by 李腾 on 2016/10/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNFBTypeModel : NSObject

/*
 http://testapi.k.sohu.com/api/feedback/feedBackTypeList.go
 data[
 {
 id:  //意见反馈问题类别id
 name:  //意见反馈问题类别名字
 icon:  //意见反馈问题类别iocn地址
 }
 ]
 */

/**
 意见反馈问题类别id
 */
@property (nonatomic, copy) NSNumber *typeID;

/**
 意见反馈问题类别名字
 */
@property (nonatomic, copy) NSString *name;

/**
 意见反馈问题类别iocn地址
 */
@property (nonatomic, copy) NSString *icon;


+ (void)requestFBTypeListWithFinishHandle:(void(^)(NSArray <SNFBTypeModel *> *typeList))finishHandle failure:(void(^)(NSError *error))failure;


@end
