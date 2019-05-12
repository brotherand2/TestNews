//
//  SNUserinfo.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-16.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNUserConsts.h"


@interface SNUserItem : NSObject<NSCoding>
{
    NSString* _imageUrl;
    NSString* _imageUrlhl;
    NSString* _imageUrlNight;
    NSString* _imageUrlNighthl;
    NSString* _name;
    NSString* _link;
}

@property(nonatomic,strong) NSString* _imageUrl;
@property(nonatomic,strong) NSString* _imageUrlhl;
@property(nonatomic,strong) NSString* _imageUrlNight;
@property(nonatomic,strong) NSString* _imageUrlNighthl;
@property(nonatomic,strong) NSString* _name;
@property(nonatomic,strong) NSString* _link;
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define LoginTimeout (60*5) //目前超时时间简设为5分钟

@interface SNUserinfo : NSObject<NSCoding>
{
    BOOL      _isSelf; //是否是自己
    NSString* _uid;
    NSString* _userName;
    NSString* _password;
    NSString* _nickName;
    NSString* _headImageUrl;
    NSString* _cookieName;
    NSString* _cookieValue;

    NSMutableArray* _itemArray;
    NSDate* _date;
    //temp
    NSString* _flushCodeUrl;

    NSString* _token;
    NSString* _pid;
}

@property(nonatomic,assign) BOOL            isSelf;
@property(nonatomic,strong) NSString*       uid;
@property(nonatomic,strong) NSString*       userName;//passport
@property(nonatomic,strong) NSString*       password;
@property(nonatomic,strong) NSString*       nickName;
@property(nonatomic,strong) NSString*       headImageUrl;
@property(nonatomic,strong) NSString*       cookieName;
@property(nonatomic,strong) NSString*       cookieValue;
@property(nonatomic,strong) NSMutableArray* itemArray;
@property(nonatomic,strong) NSDate*         date;
@property(nonatomic,strong) NSString*       flushCodeUrl;
@property(nonatomic,strong) NSString*       token;
@property(nonatomic,strong) NSString*       pid;

+(id)userinfo;
+(void)clearUserinfoFromUserDefaults;

-(NSData*)getData;
-(BOOL)isSelfUser;
-(BOOL)isValidateDate;
-(NSString*)getUsername;
-(NSString*)getNickname;
-(void)resetUserinfo;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//版本3.3做字段扩展
//2012 12 18 by diaochunmeng
@interface SNUserinfoEx : SNUserinfo
{
    NSString* _gender;
    NSString* _birthday;
    NSString* _province;
    NSString* _city;
    NSString* _education;
    NSString* _mobile;
    //最新回复我的评论的id
    NSString* _lastCommentId;
    UIImage* _tempHeader;
    
    //版本3.5社交化扩展
    NSString* _description;     //字符串	描述信息
    NSString* _actionCount;     //整数	动态数
    NSString* _followingCount;	//整型	关注数
    NSString* _followedCount;	//整型	粉丝数
    NSString* _relation;        //整型	当前登陆用户与当前被访问用户的关系(0未关注 1 已关注 -1自己)
    NSString* _userBindList;    //列表	第三方列表节点，每项包含 (thirdPartyId,thirdPartyName,thirdPartyUrl,icon)四个节点
    NSString* _thirdPartyId;    //整型	第三方标识(与分享列表一致)
    NSString* _thirdPartyName;	//字符串	 第三方名称
    NSString* _thirdPartyUrl;	//字符串	 第三方主页url
    NSString* _icon;            //字符串	 iconurl
    NSString* _backImg;         //字符串 	背景图片地址
    NSString* _from;            //字符串 	1:新浪微博2:腾讯微博 3搜狐微博 4 人人 5 开心 6 qzone 7百度 8淘宝
}

@property(nonatomic,strong) NSString* gender;         //1男，2女
@property(nonatomic,strong) NSString* birthday;
@property(nonatomic,strong) NSString* province;
@property(nonatomic,strong) NSString* city;
@property(nonatomic,strong) NSString* education;
@property(nonatomic,strong) NSString* mobile;
@property(nonatomic,strong) NSString* passport;//passport
@property(nonatomic,strong) NSString* ppLoginFlag;//passport wangshun 2017.11.23 passport.sohu.com 登录标识 用于存cookie ,如果是passport登录 本地种cookie SNNewsPPLoginCookie  
//最新回复我的评论的id
@property(nonatomic,strong) NSString* lastCommentId;
@property(nonatomic,strong) UIImage*  tempHeader;

//版本3.5社交化扩展
@property(nonatomic,strong) NSString* description;     //字符串	描述信息
@property(nonatomic,strong) NSString* actionCount;     //整数	动态数
@property(nonatomic,strong) NSString* followingCount;	//整型	关注数
@property(nonatomic,strong) NSString* followedCount;	//整型	粉丝数
@property(nonatomic,strong) NSString* relation;        //整型	当前登陆用户与当前被访问用户的关系(0未关注 1 已关注 -1自己)
@property(nonatomic,strong) NSString* userBindList;    //列表	第三方列表节点，每项包含 (thirdPartyId,thirdPartyName,thirdPartyUrl,icon)四个节点
@property(nonatomic,strong) NSString* thirdPartyId;    //整型	第三方标识(与分享列表一致)
@property(nonatomic,strong) NSString* thirdPartyName;	//字符串	 第三方名称
@property(nonatomic,strong) NSString* thirdPartyUrl;	//字符串	 第三方主页url
@property(nonatomic,strong) NSString* icon;            //字符串	 iconurl
@property(nonatomic,strong) NSString* backImg;         //字符串 	背景图片地址
@property(nonatomic,strong) NSString* from;            //来源
@property(nonatomic,strong) NSArray*  personMediaArray; //自媒体内容
@property(nonatomic,strong) NSString* cmsRegUrl;        //开通自媒体url
@property(nonatomic,assign) BOOL      isRegcms;         //是否需要开通自媒体
@property(nonatomic,strong) NSArray*  signList;         //徽章
@property(nonatomic,assign) BOOL      isShowManage;     //是否显示自媒体管理按钮
@property(nonatomic,assign) BOOL      audugcAuth;       //是否显示语音ugc入口
@property(nonatomic,assign) BOOL      isRealName;       //是否是实名制登录

+(BOOL)isLogin;

+(SNUserinfoEx*)userinfoEx;

+(BOOL)isSelfUser:(NSString*)pid;

+(NSString *)passport;

+(id)userinfoExData:(NSData*)data;

-(NSString*)getGender;

-(NSString*)getTerm;

-(NSString*)getPlace;

- (NSString *)getMobileNum;

-(NSArray*)getPersonMediaObjects;

-(BOOL)hasPersonMedia;

-(void)saveUserinfoToUserDefault;

-(void)parseUserinfoFromDictionary:(NSDictionary*)dic;

//pplogin @wangshun 2017.11.10
-(void)ppSaveUserInfo:(NSDictionary*)dic;

-(void)copyEditUserinfo:(SNUserinfoEx*)aUserinfo;

-(SNUserType)getUserType;
@end
