//
//  SNBaseFavouriteObject.h
//  sohunews
//
//  Created by Gao Yongyue on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kContentLevelFirstID  @"contentLevelFirstID"
#define kContentLevelSecondID @"contentLevelSecondID"
#define kContentTitle         @"contentTitle"
#define kPublicationDate      @"publicationDate"
#define kContentType          @"contentType"
#define kContentImageUrl      @"contentImageUrl"
#define kContentLink2         @"kContentLink2"
#define kContentTemplateType  @"templateType"

@class SNMyFavourite;
@class SNCloudSave;

@interface SNBaseFavouriteObject : NSObject
{
    NSString *_title;
    NSString *_contentLevelFirstID;
    NSString *_contentLevelSecondID; //视频的secondID统一传100
    NSString *_publicationDate;
    NSString *_imageUrl;
    NSString *_link2; //二代协议，有的是直接给的，少了拼参数的风险
    int _type;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *contentLevelFirstID;
@property (nonatomic, copy) NSString *contentLevelSecondID;
@property (nonatomic, copy) NSString *publicationDate;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *link2;
@property (nonatomic, copy) NSString *templateType;
@property (nonatomic, copy) NSString *showType;
@property (nonatomic, assign) int type;

- (id)initWithMyFavourite:(SNMyFavourite *)myFavourite;
- (id)initWithCloudSave:(SNCloudSave *)cloudSave;
//返回属性字典，子类必须都要继承此方法！！！思密达
- (NSMutableDictionary *)localProperties;

//以下方法不需要子类继承！！！思密达
//由于底层数据库表的原因，有以下几个转换，等重构完这层，重构底层数据库表结构的时候，会再做调整，思密达
// SNMyFavourite ----> SNCloudSave
- (SNCloudSave *)cloudSaveObjectConvertedByMyFavouriteObject:(SNMyFavourite *)myFavourite;

// SNCloudSave ---> SNMyFavourite
- (SNMyFavourite *)myFavouriteObjectConvertedByCloudSaveObject:(SNCloudSave *)cloudSave;

// SNBaseFavouriteObject ---> SNMyFavourite
- (SNMyFavourite *)myFavouriteObjectConvertedByBaseFavouriteObject;

// SNBaseFavouriteObject ---> SNCloudSave
- (SNCloudSave *)cloudSaveObjectConvertedByBaseFavouriteObject;

- (NSString *)schemeFromProperties;
@end
