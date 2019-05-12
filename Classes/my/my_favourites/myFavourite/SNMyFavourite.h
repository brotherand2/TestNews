//
//  SNMyFavourite.h
//  sohunews
//
//  Created by handy wang on 8/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MYFAVOURITE_REFER_NONE                                              = 0,
    
    MYFAVOURITE_REFER_PUB_HOME                                          = 1,
    MYFAVOURITE_REFER_NEWS_IN_PUB                                       = 2,
    MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS                               = 3,
    MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWSJOKE                           = 17,
    MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWSNEWVIDEO                           = 18,
    
    MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_PUB                             = 4,
    MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS                     = 5,
    MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_PUB_MAG_HOME                 = 6,
    MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_PUB_PHOTOLIST                = 7,
    MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_ROLLINGNEWS_PHOTOLIST        = 8,
    MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_GROUPPHOTOTAB_CATEGORY       = 9,
    MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_GROUPPHOTOTAB_TAG            = 10,
    
    MYFAVOURITE_REFER_WEIBO_HOT                                         = 11,
#ifdef SHARE_SPECIAL_NEWS
    //MYFAVOURITE_REFER_SPECAIL                                           = 12,
#endif
    MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL                         = 13,//频道新闻里的组图
    MYFAVOURITE_REFER_RECOMMEND_NEWS_IN_CHANNEL                         = 14, //频道新闻里的推荐新闻 //!!!!!以后可以不使用这个字段了，把推荐新闻当普通新闻来看待
    MYFAVOURITE_REFER_VIDEO                                             = 15,
    MYFAVOURITE_REFER_VIDEOMEDIA                                        = 16
} MYFAVOURITE_REFER;

@interface SNMyFavourite : NSObject {

    NSInteger _ID;
    NSString *_title;
    NSString *_imgURL;
    MYFAVOURITE_REFER _myFavouriteRefer;//标识在什么地方进行的收藏；
    
    /**
     * 注意：
     * 当收藏刊物首页时，即contentType是刊物，contentLeveloneID的值是pubID，contentLeveltwoID的值是termID；
     * 当收藏新闻最终页时，即contentType是新闻最终页：
        当在刊物里收藏时，contentLeveloneID的值是termID，contentLeveltwoID的值是newsID；
        当在滚动新闻里收藏时，contentLeveloneID的值是channelID，contentLeveltwoID的值是newsID；
     * 当收藏组图列表时，即contentType是PhotoList：
        当在刊物的PhotoList里收藏时，contentLeveloneID的值是termID，contentLeveltwoID的值是newsID；
        当在滚动新闻组图PhotoList里收藏时，contentLeveloneID的值是channelID，contentLeveltwoID的值是newsID；
     * 当收藏组图Gallery时，即contentType是Gallery：
        当在画报刊物首页进入Gallery里收藏时，contentLeveloneID的值是termID，contentLeveltwoID的值是newsID；
        当在刊物的PhotoList下的Gallery里收藏时，contentLeveloneID的值是termID，contentLeveltwoID的值是newsID；
        当在滚动新闻组图PhotoList下的Gallery里收藏时，contentLeveloneID的值是channelID，contentLeveltwoID的值是newsID；
        当在组图tab下的Gallery里收藏时，contentLeveloneID的值是typeID(categoryID或tagID)，contentLeveltwoID的值是newsID(gID)；
     */
    NSString *_contentLeveloneID;
    
    NSString *_contentLeveltwoID;
    
    NSString  *_isRead;
    
    NSString *_pubDate;
    
    
    //Transient
    BOOL _isEditMode;
    
    //Transient
    BOOL _isSelected;
    
    //3.3.1版新加字段
    //为了达到离线删除收藏的功能，如果该字段为空，表示这条信息是公共的，下次登录的用户将认领此收藏
    //而如果此字段非空，则表示这个收藏被离线删除了，下次同步！！！ By diao
    NSString* _userId;
}

@property(nonatomic, assign)NSInteger ID;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *imgURL;
@property(nonatomic, assign)MYFAVOURITE_REFER myFavouriteRefer;
@property(nonatomic, copy)NSString *contentLeveloneID;
@property(nonatomic, copy)NSString *contentLeveltwoID;
@property(nonatomic, copy)NSString *isRead;
@property(nonatomic, copy)NSString *pubDate;
@property(nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *templateType;
@property (nonatomic, copy)NSString *showType;

//Transient
@property(nonatomic, assign)BOOL isEditMode;
//Transient
@property(nonatomic, assign)BOOL isSelected;

-(NSString*)generCloudLink;
+(NSString*)generCloudLinkEx:(MYFAVOURITE_REFER)myFavouriteRefer contentLeveloneID:(NSString*)contentLeveloneID contentLeveltwoID:(NSString*)contentLeveltwoID showType:(NSString *)showType;
+(SNMyFavourite*)generateMyFavFromSNCloudSave:(SNCloudSave*)aCloudSave;
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface SNCloudSave : NSObject
{
    NSInteger _ID;
    NSString* _title;
    NSString* _link;
    NSString* _collecttime;
    NSString* _userid;
    //兼容之前版本
    MYFAVOURITE_REFER _myFavouriteRefer;//标识在什么地方进行的收藏；
    NSString* _contentLeveloneID;
    NSString* _contentLeveltwoID;
    
    //Transient
    BOOL _isEditMode;
    //Transient
    BOOL _isSelected;
}

@property(nonatomic,assign) NSInteger _ID;
@property(nonatomic,strong) NSString* _title;
@property(nonatomic,strong) NSString* _link;
@property(nonatomic,strong) NSString* _collectTime;
@property(nonatomic,strong) NSString* _userId;
@property(nonatomic,assign) MYFAVOURITE_REFER _myFavouriteRefer;
@property(nonatomic,strong) NSString* _contentLeveloneID;
@property(nonatomic,strong) NSString* _contentLeveltwoID;
@property (nonatomic, strong) NSString *templateType;
@property (nonatomic, copy)NSString *showType;

//Transient
@property(nonatomic, assign)BOOL isEditMode;
//Transient
@property(nonatomic, assign)BOOL isSelected;

-(BOOL)parserLink;
-(NSString*)generCloudLink;
@end
