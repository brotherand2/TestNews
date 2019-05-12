//
//  SNGalleryDataModel.h
//  sohunews
//
//  Created by HuangZhen on 07/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNGalleryBrowserView.h"

typedef void(^FetchGalleryDataCompleteBlock)(id galleryData);

@interface SNGalleryDataModel : NSObject

@property (nonatomic, copy) NSString * channelId;
@property (nonatomic, copy) NSString * termId;

/**
 通过newsId获取组图数据

 @param newsId newsid
 @param type 组图还是图文
 @param completeBlock 完成回调
 */
- (void)getJsKitStorageItemWithNewsId:(NSString *)newsId type:(SNGalleryBrowserType)type completed:(FetchGalleryDataCompleteBlock)completeBlock;

/**
 通过gid获取组图数据

 @param groupId 组图id
 @param type type 组图还是图文
 @param completeBlock 完成回调
 */
- (void)getJsKitStorageItemWithGroupId:(NSString *)groupId type:(SNGalleryBrowserType)type completed:(FetchGalleryDataCompleteBlock)completeBlock;

@end
