//
//  SNUserinfoService.m
//  sohunews
//
//  Created by weibin cheng on 14-2-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNUserinfoService.h"
#import "SNURLJSONResponse.h"
#import "SNUserManager.h"
#import "SNWeatherCenter.h"
#import "SNDBManager.h"
#import "SNUserUtility.h"
#import "SNUserConsts.h"
#import "AFHTTPRequestOperationManager.h"
#import "SNUserInfoRequest.h"

#define kUserInfoCircle  (@"kUserinfoCircle")
#define kUpdateUserinfo  (@"kupdateuserinfo")
#define kPostHeader      (@"kpostheader")

@implementation SNUserinfoService
@synthesize userInfoRequest = _userInfoRequest;
@synthesize userinfoDelegate = _userinfoDelegate;
@synthesize postHeaderDelegate = _postHeaderDelegate;
@synthesize postHeaderRequest = _postHeaderRequest;
@synthesize updateUserinfoDelegate = _updateUserinfoDelegate;
@synthesize updateUserinfoRequest = _updateUserinfoRequest;
@synthesize usrinfo = _usrinfo;

-(id)init
{
    self = [super init];
    if(self)
    {
        _usrinfo = [[SNUserinfoEx alloc] init];
    }
    return self;
}

-(void)dealloc
{
     //(_usrinfo);
    if(_userInfoRequest)
    {
        [_userInfoRequest cancel];
         //(_userInfoRequest);
    }
    self.userinfoDelegate = nil;
    if(_updateUserinfoRequest)
    {
        [_updateUserinfoRequest cancel];
         //(_updateUserinfoRequest);
    }
    self.updateUserinfoDelegate = nil;
    if(_postHeaderRequest)
    {
        [_postHeaderRequest cancel];
         //(_postHeaderRequest);
    }
    self.postHeaderDelegate = nil;
}
//----------------------------------------------------------------------------------------------
//-------------------------------------- 阅读圈用户信息 -------------------------------------------
// 参数为空表示获取自己的用户信息
//----------------------------------------------------------------------------------------------
//manual 是否是用户手动触发的操作
-(BOOL)circle_userinfoRequest:(NSString*)aUsername loginFrom:(NSString *)loginFrom
{
    if(self.userInfoRequest!=nil && self.userInfoRequest.isLoading)
        return NO;
    
    BOOL isSelf = YES;
    SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
    if(nil == aUsername)
    {
        if(userinfo.pid.length>0)
            aUsername = userinfo.pid;
        else
            aUsername = @"1";
    }
    else if(![aUsername isEqualToString:userinfo.uid] && ![aUsername isEqualToString:userinfo.userName] && ![aUsername isEqualToString:userinfo.pid])
        isSelf = NO;

    if (!loginFrom) {
        loginFrom = kLoginFromEmpty;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:loginFrom forKey:@"loginfrom"];
    [params setValue:@"" forKey:aUsername]; // what？
    
    [[[SNUserInfoRequest alloc] initWithDictionary:params andIsSelf:isSelf] send:^(SNBaseRequest *request, id responseObject) {
        NSHTTPURLResponse *response = nil;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            AFHTTPRequestOperation *operation = request.requestObject;
            response = operation.response;
        } else {
            NSURLSessionDataTask *dataTask = request.requestObject;
            response = (NSHTTPURLResponse *)dataTask.response;
        }
        [self requestDidFinishLoad:responseObject isSelf:isSelf response:response];
    } failure:^(SNBaseRequest *request, NSError *error) {
        if(_userinfoDelegate && [_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoFailure:didFailLoadWithError:)]) {
            [_userinfoDelegate notifyGetUserinfoFailure:nil didFailLoadWithError:error];
        }
    }];
    return YES;
}

-(BOOL)postImageRequest:(NSString*)aUserId image:(UIImage*)aImage
{
    if(aImage==nil || aUserId==nil)
        return NO;
    
    NSString* urlFull = [NSString stringWithString:kUrlPostHeader];
	if(!_postHeaderRequest)
    {
		_postHeaderRequest = [TTURLRequest requestWithURL:urlFull delegate:self];
		_postHeaderRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	}
    else
    {
		_postHeaderRequest.urlPath = urlFull;
	}
    
    //根据uuid,创建boundary
	CFUUIDRef uuid = CFUUIDCreate(nil);
	NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuid));
	CFRelease(uuid);
	NSString* stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:aUserId forKey:@"userId"];
    [params setObject:[SNUserManager getP1] forKey:@"p1"];
    
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",stringBoundary];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //如果key不是pic，说明value是字符类型，比如name：Boris·
        if(![key isEqualToString:@"pic"])
        {
            //添加分界线，换行
            [body appendFormat:@"%@\r\n",MPboundary];
            //添加字段名称，换2行
            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            //添加字段的值
            [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        }
    }
    
    //添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"authorimg\"; filename=\"1.png\"\r\n"];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    NSData* data = UIImagePNGRepresentation(aImage);
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString* content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    _postHeaderRequest.userInfo = [TTUserInfo topic:kPostHeader strongRef:nil weakRef:nil];
	_postHeaderRequest.response = [[SNURLJSONResponse alloc] init];
    [_postHeaderRequest setValue:content forHTTPHeaderField:@"Content-Type"];
    [_postHeaderRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [_postHeaderRequest setHttpBody:myRequestData];
    [_postHeaderRequest setHttpMethod:@"POST"];
    [_postHeaderRequest send];
    return YES;
}

//----------------------------------------------------------------------------------------------
//-------------------------------------------3.3 updateUserInfo --------------------------------
//----------------------------------------------------------------------------------------------

//加密算法
//参数列表拆分+排序+分别base65+拼到一块+md5+code=
-(BOOL)updateUserInfo:(NSString*)aUserId key:(NSString*)aKey value:(NSString*)aValue key2:(NSString*)aKey2 value2:(NSString*)aValue2
{
    if(aUserId==nil || aKey==nil || aValue==nil)
        return NO;
    if([aValue isEqualToString:@"city"] && (aKey2==nil || aValue2==nil))
        return NO;
    
    NSMutableDictionary* educationDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [educationDic setObject:@"初中" forKey:@"1"];
    [educationDic setObject:@"高中" forKey:@"2"];
    [educationDic setObject:@"专科/本科" forKey:@"3"];
    [educationDic setObject:@"硕士" forKey:@"4"];
    [educationDic setObject:@"博士" forKey:@"5"];
    [educationDic setObject:@"博士后" forKey:@"6"];
    
    NSString* encodeValue = [aValue URLEncodedString];
    NSString* encodeValue2 = [aValue2 URLEncodedString];
    
    NSString* urlFull;
    if(aKey2==nil || aValue2==nil)
        urlFull = [NSString stringWithFormat:kUrlUpdateUserInfo, aUserId, aKey, encodeValue];
    else
        urlFull = [NSString stringWithFormat:kUrlUpdateUserInfo2, aUserId, aKey, encodeValue, aKey2, encodeValue2];
    
    //    urlFull = [SNUtility addParamP1ToURL:urlFull];
    //    urlFull = [[SNEncryptManager GetInstance] EncrptUpdateUserinfoString:urlFull];
    //    urlFull = [urlFull stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
	if(!_updateUserinfoRequest)
    {
		_updateUserinfoRequest = [SNURLRequest requestWithURL:urlFull delegate:self];
		_updateUserinfoRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	}
    else
    {
		_updateUserinfoRequest.urlPath = urlFull;
	}
    _updateUserinfoRequest.userInfo = [TTUserInfo topic:kUpdateUserinfo strongRef:nil weakRef:nil];
	_updateUserinfoRequest.response = [[SNURLJSONResponse alloc] init];
	[_updateUserinfoRequest send];
    return YES;
}

//----------------------------------------------------------------------------------------------
//-------------------------------------- 获取云存储频道列表 -------------------------------------------
//----------------------------------------------------------------------------------------------

- (void)getCloudChannelInfo
{
    //wangshun sohu login
    [SNNotificationManager postNotificationName:kRollingChannelReloadNotification object:nil];
}

#pragma -mark TTUrlRequestDelegate
-(void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    TTUserInfo* userInfo = request.userInfo;
    if([userInfo.topic isEqualToString:kUserInfoCircle])
    {
        if(_userinfoDelegate && [_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoFailure:didFailLoadWithError:)])
           [_userinfoDelegate notifyGetUserinfoFailure:request didFailLoadWithError:error];
    }
    else if([userInfo.topic isEqual:kPostHeader])
    {
        if(_postHeaderDelegate && [_postHeaderDelegate respondsToSelector:@selector(notifyPostHeaderFailure:didFailLoadWithError:)])
            [_postHeaderDelegate notifyPostHeaderFailure:request didFailLoadWithError:error];
    }
    else if([userInfo.topic isEqualToString:kUpdateUserinfo])
    {
        if(_updateUserinfoDelegate && [_updateUserinfoDelegate respondsToSelector:@selector(notifyUpdateUserinfoFailure:didFailLoadWithError:)])
            [_updateUserinfoDelegate notifyUpdateUserinfoFailure:request didFailLoadWithError:error];
    }
}

-(void)requestDidFinishLoad:(id)reponseObject isSelf:(BOOL)isSelf response:(NSHTTPURLResponse *)response
{//wangshun sohu login
    id rootData = reponseObject;
    
    SNDebugLog(@"user info circle json data : %@", reponseObject);
    if ([rootData isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* result = [rootData objectForKey:@"result"];
        NSNumber* code = [result objectForKey:@"code"];
        NSString* msg = [result objectForKey:@"msg"];
        
        if([code intValue]==200)
        {
            [SNUserUtility parseUserinfo:_usrinfo fromDictionary:rootData];
            id subInfoList = [rootData objectForKey:@"subInfoList"];
            _usrinfo.personMediaArray = subInfoList;
            NSMutableArray* mediaArray = [NSMutableArray arrayWithCapacity:3];
            //因为现在只获取自己用户信息，所有在此处存储数据
            if(isSelf)
            {
                NSString* setCookie   = [response.allHeaderFields objectForKey:@"set-Cookie"];
                SNUserinfoEx* defaultUserinfo = [SNUserinfoEx userinfoEx];
                if(setCookie.length > 0)
                {
                    if(defaultUserinfo.cookieValue )
                    {
                        if([defaultUserinfo.cookieValue rangeOfString:setCookie options:NSCaseInsensitiveSearch].location==NSNotFound)
                        {
                            defaultUserinfo.cookieValue = [NSString stringWithFormat:@"%@; %@", _usrinfo.cookieValue, setCookie];
                        }
                    }
                    else
                    {
                        defaultUserinfo.cookieValue = setCookie;
                        defaultUserinfo.cookieName = kSetCookie;
                    }
                }
                [SNUserUtility parseUserinfo:defaultUserinfo fromDictionary:rootData];
                _usrinfo.date = [NSDate date];
                [defaultUserinfo saveUserinfoToUserDefault];
            }
            
            if([_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoSuccess:)]) {
                [_userinfoDelegate notifyGetUserinfoSuccess:mediaArray];
                //wangshun sohu login
                [SNNotificationManager postNotificationName:kNotifyGetUserinfoSuccess object:nil];
            }
            
            //同步本地数据
            /*
             if(_usrinfo!=nil && [_usrinfo isSelfUser])
             {
             NSArray* myFavourites = [[[[SNDBManager currentDataBase] getMyFavourites] mutableCopy] autorelease];
             if(myFavourites!=nil && [myFavourites count]>0)
             [self performSelector:@selector(cloudSaveFavouriteArray:) withObject:myFavourites afterDelay:0.1];
             else
             [self performSelector:@selector(cloudGetRequest:) withObject:[NSNumber numberWithInt:ECloudGetAll] afterDelay:0.1];
             }*/
            
            //登录用户获取云存储频道列表
            [self getCloudChannelInfo];
        }
        else
        {
            if([_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoFailure:msg:)])
                [_userinfoDelegate notifyGetUserinfoFailure:[code intValue] msg:msg];
        }
    }
    else
    {
        if([_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoFailure:msg:)])
            [_userinfoDelegate notifyGetUserinfoFailure:0 msg:NSLocalizedString(@"network error", nil)];
    }
}

-(void)requestDidFinishLoad:(TTURLRequest*)request
{
    TTUserInfo* userInfo = request.userInfo;
    SNURLJSONResponse* dataRes = (SNURLJSONResponse*)request.response;
    if([userInfo.topic isEqual:kUserInfoCircle])
    {
    id rootData = dataRes.rootObject;
    
        SNDebugLog(@"user info circle json data : %@", rootData);
        if ([rootData isKindOfClass:[NSDictionary class]])
        {
            BOOL isSelf = [(NSNumber*)userInfo.strongRef boolValue];
            NSDictionary* result = [rootData objectForKey:@"result"];
            NSNumber* code = [result objectForKey:@"code"];
            NSString* msg = [result objectForKey:@"msg"];
            
            if([code intValue]==200)
            {
                [SNUserUtility parseUserinfo:_usrinfo fromDictionary:rootData];
                id subInfoList = [rootData objectForKey:@"subInfoList"];
                _usrinfo.personMediaArray = subInfoList;
                NSMutableArray* mediaArray = [NSMutableArray arrayWithCapacity:3];
                //因为现在只获取自己用户信息，所有在此处存储数据
                if(isSelf)
                {
                    //3.5.1扩展cookie
                    SNURLJSONResponse* data = (SNURLJSONResponse*)request.response;
                    NSString* setCookie   = [data.responceHeader objectForKey:@"set-Cookie"];
                    SNUserinfoEx* defaultUserinfo = [SNUserinfoEx userinfoEx];
                    if(setCookie.length > 0)
                    {
                        if(defaultUserinfo.cookieValue )
                        {
                            if([defaultUserinfo.cookieValue rangeOfString:setCookie options:NSCaseInsensitiveSearch].location==NSNotFound)
                            {
                                defaultUserinfo.cookieValue = [NSString stringWithFormat:@"%@; %@", _usrinfo.cookieValue, setCookie];
                            }
                        }
                        else
                        {
                            defaultUserinfo.cookieValue = setCookie;
                            defaultUserinfo.cookieName = kSetCookie;
                        }
                    }
                    [SNUserUtility parseUserinfo:defaultUserinfo fromDictionary:rootData];
                    _usrinfo.date = [NSDate date];
                    [defaultUserinfo saveUserinfoToUserDefault];
                }
                
                if([_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoSuccess:)]) {
                    [_userinfoDelegate notifyGetUserinfoSuccess:mediaArray];
                    [SNNotificationManager postNotificationName:kNotifyGetUserinfoSuccess object:nil];
                }
                
                //同步本地数据
                /*
                if(_usrinfo!=nil && [_usrinfo isSelfUser])
                {
                    NSArray* myFavourites = [[[[SNDBManager currentDataBase] getMyFavourites] mutableCopy] autorelease];
                    if(myFavourites!=nil && [myFavourites count]>0)
                        [self performSelector:@selector(cloudSaveFavouriteArray:) withObject:myFavourites afterDelay:0.1];
                    else
                        [self performSelector:@selector(cloudGetRequest:) withObject:[NSNumber numberWithInt:ECloudGetAll] afterDelay:0.1];
                }*/
                
                //登录用户获取云存储频道列表
                [self getCloudChannelInfo];
            }
            else
            {
                if([_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoFailure:msg:)])
                    [_userinfoDelegate notifyGetUserinfoFailure:[code intValue] msg:msg];
            }
        }
        else
        {
            if([_userinfoDelegate respondsToSelector:@selector(notifyGetUserinfoFailure:msg:)])
                [_userinfoDelegate notifyGetUserinfoFailure:0 msg:NSLocalizedString(@"network error", nil)];
        }
    }
    else if([userInfo.topic isEqual:kUpdateUserinfo])
    {
        id rootData = dataRes.rootObject;
        SNDebugLog(@"get update user info json data : %@", rootData);
        if([rootData isKindOfClass:[NSDictionary class]])
        {
            NSNumber* status = [rootData objectForKey:@"status"];
            NSString* msg = [rootData objectForKey:@"msg"];
            
            if(status!=nil && [status intValue]==0)
            {
                if([_updateUserinfoDelegate respondsToSelector:@selector(notifyUpdateUserinfoSuccess)])
                    [_updateUserinfoDelegate notifyUpdateUserinfoSuccess];
            }
            else
            {
                if([_updateUserinfoDelegate respondsToSelector:@selector(notifyUpdateUserinfoFailure:msg:)])
                    [_updateUserinfoDelegate notifyUpdateUserinfoFailure:[status intValue] msg:msg];
            }
        }
        else
        {
            if([_updateUserinfoDelegate respondsToSelector:@selector(notifyUpdateUserinfoFailure:msg:)])
                [_updateUserinfoDelegate notifyUpdateUserinfoFailure:0 msg:NSLocalizedString(@"network error", nil)];
        }
    }
    else if([userInfo.topic isEqual:kPostHeader])
    {
        id rootData = dataRes.rootObject;
        SNDebugLog(@"get post header json data : %@", rootData);
        if([rootData isKindOfClass:[NSDictionary class]])
        {
            NSNumber* status = [rootData objectForKey:@"status"];
            NSString* msg = [rootData objectForKey:@"msg"];
            
            if(status!=nil && [status intValue]==0)
            {
                NSString* thumb = [rootData objectForKey:@"thumb"];
                if([_postHeaderDelegate respondsToSelector:@selector(notifyPostHeaderSuccess:)])
                    [_postHeaderDelegate notifyPostHeaderSuccess:thumb];
            }
            else
            {
                if([_postHeaderDelegate respondsToSelector:@selector(notifyPostHeaderFailure:msg:)])
                    [_postHeaderDelegate notifyPostHeaderFailure:[status intValue] msg:msg];
            }
        }
        else
        {
            if([_postHeaderDelegate respondsToSelector:@selector(notifyPostHeaderFailure:msg:)])
                [_postHeaderDelegate notifyPostHeaderFailure:0 msg:NSLocalizedString(@"network error", nil)];
        }
    }
}
@end
