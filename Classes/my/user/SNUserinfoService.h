//
//  SNUserinfoService.h
//  sohunews
//
//  Created by weibin cheng on 14-2-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@protocol SNUserinfoServiceGetUserinfoDelegate <NSObject>
@optional
//Get user info
-(void)notifyGetUserinfoSuccess:(NSArray*)mediaArray;
-(void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol SNUserinfoServiceUpdateUserinfoDelegate <NSObject>
@optional
//Get user info
-(void)notifyUpdateUserinfoSuccess;
-(void)notifyUpdateUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyUpdateUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol SNUserinfoServicePostHeaderDelegate <NSObject>
@optional
//Get user info
-(void)notifyPostHeaderSuccess:(NSString*)imageUrl;
-(void)notifyPostHeaderFailure:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyPostHeaderFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;
@end

@interface SNUserinfoService : NSObject<TTURLRequestDelegate>

@property(nonatomic,weak)id<SNUserinfoServiceGetUserinfoDelegate> userinfoDelegate;
@property(nonatomic,weak)id<SNUserinfoServiceUpdateUserinfoDelegate> updateUserinfoDelegate;
@property(nonatomic,weak)id<SNUserinfoServicePostHeaderDelegate> postHeaderDelegate;

@property(nonatomic,strong)SNUserinfoEx* usrinfo;
@property(nonatomic,strong)SNURLRequest* updateUserinfoRequest;
@property(nonatomic,strong)TTURLRequest* postHeaderRequest;
@property(nonatomic,strong)SNURLRequest* userInfoRequest;

-(BOOL)circle_userinfoRequest:(NSString*)aPid loginFrom:(NSString *)loginFrom; //阅读圈用户中心入口，参数为空表示自己

-(BOOL)updateUserInfo:(NSString*)aUserId key:(NSString*)aKey value:(NSString*)aValue key2:(NSString*)aKey2 value2:(NSString*)aValue2;
//Post image
-(BOOL)postImageRequest:(NSString*)aUserId image:(UIImage*)aImage;

@end
