//
//  SNVideoChannelObjects.h
//  sohunews
//
//  Created by jojo on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// 热播管理 section 数据块
@interface SNVideoHotChannelCategoriSectionObj : NSObject

@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *categoryType; // type:分类类型 0普通分类 1社交分类
@property (nonatomic, copy) NSString *categoryStatus;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *categoryTitle; // 绑定列表本地写死，其余的服务器控制
@property (nonatomic, copy) NSString *utime;
@property (nonatomic, copy) NSString *ctime;
@property (nonatomic, copy) NSString *descn;

@property (nonatomic, strong) NSMutableArray *categories; // array of SNVideoChannelCategoryObject
@property (nonatomic, assign) UITextAlignment textAlignment;

+ (SNVideoHotChannelCategoriSectionObj *)sectionObjWithDataObject:(id)obj;
- (void)parseSectionObjs:(NSArray *)sectionObjs;

@end

#pragma mark -

/*
 {
 "id": 1,
 "type": 0,
 "owner": 0,
 "status": 0,
 "title": "新浪微博",
 "author": {
    "name": "新闻客户端用户",
    "id": -1,
    "type": -1,
    "icon": "http://pic5.qiyipic.com/image/20131012/v_100445335_m_601.jpg"
 },
 "url": "http://passport.sohu.com/openlogin/request.action?provider=sina&appid=1106&hun=0&type=mapp&ru=http://api.k.sohu.com/api/usercenter/login.go",
 "ctime": 1377862957891,
 "utime": 1377862957891,
 "binding": false,
 "sub": false
 }
 */

// 视频频道下的具体分类结构

@interface SNVideoChannelCategoryObjectAuthor : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *icon;

+ (SNVideoChannelCategoryObjectAuthor *)authorObjFromDataInfo:(NSDictionary *)infoDic;

@end

@interface SNVideoColumnCacheObj : NSObject

@property (nonatomic, copy) NSString *columnId;
@property (nonatomic, copy) NSString *columnTitle;
@property (nonatomic, copy) NSString *isSubed;
@property (nonatomic, copy) NSString *readCount;

@end

@interface SNVideoChannelCategoryObject : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *owner;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *categoryId; // 对应服务器返回的id
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *ctime;
@property (nonatomic, copy) NSString *utime;
@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *sub;
@property (nonatomic, strong) SNVideoChannelCategoryObjectAuthor *author;
//表示是否处于取消勾选的网络请求中，用于解决当剩下两个栏目时同时被退订的情况
@property (nonatomic, assign) BOOL isUnsubLoading;

+ (SNVideoChannelCategoryObject *)categoryObjFromDataObj:(id)obj;
- (SNVideoColumnCacheObj *)toVideoColumnObj;

@end



#pragma mark -

/*
 "sort": 9999,
 "status": 0,
 "title": "热播",
 "descn": "热播",
 "id": 1,
 "ctime": 1377851415199,
 "utime": 1377851415199
 */

//
// 视频频道数据结构
@interface SNVideoChannelObject : NSObject

@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *descn;
@property (nonatomic, copy) NSString *channelId; // 与服务器返回数据id对应
@property (nonatomic, copy) NSString *ctime;
@property (nonatomic, copy) NSString *utime;

//4.0.1添加sortable，up
@property (nonatomic, copy) NSString *sortable; // 是否可排序，1：可以， 0：不可以
@property (nonatomic, copy) NSString *up; // 是否在上面 1-在 0-不在

//transient
@property (nonatomic, assign) BOOL isNew; // 新增的频道

// obj support NSDictionary , maybe xml obj someday.
+ (SNVideoChannelObject *)chennelObjectFromDataObj:(id)obj;

// json str
- (NSString *)json;

@end



