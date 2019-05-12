//
//  SNSubShakingCenter.m
//  sohunews
//
//  Created by Diaochunmeng on 12-11-23.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubShakingCenter.h"
#import "SNURLJSONResponse.h"
#import "SNURLDataResponse.h"
#import "SNDBManager.h"


//http://10.13.81.60:8090/pages/viewpage.action?pageId=2981898
#define kGetGetSubrecom   (@"kgetsubrecom")


@implementation SNSubShakingCenter
@synthesize _request;
@synthesize _SubArray;
@synthesize _SubShakingCenterDelegate;

//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(id)init
{
    if(self=[super init])
    {
        self._SubArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

-(void)dealloc
{
     //(_SubArray);
    [self clearRequestAndDelegate];
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 网络接口 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    TTUserInfo* userInfo = request.userInfo;
    if([userInfo.topic isEqual:kGetGetSubrecom])
    {
        if([_SubShakingCenterDelegate respondsToSelector:@selector(notifySubRecomRequestFailure:didFailLoadWithError:)])
            [_SubShakingCenterDelegate notifySubRecomRequestFailure:request didFailLoadWithError:error];
    }
}

-(void)requestDidFinishLoad:(TTURLRequest*)request
{
    TTUserInfo* userInfo = request.userInfo;
    SNURLJSONResponse* dataRes = (SNURLJSONResponse*)request.response;
    
    if([userInfo.topic isEqual:kGetGetSubrecom])
    {
        id rootData = dataRes.rootObject;
        SNDebugLog(@"get sub recomand data : %@", rootData);
        if ([rootData isKindOfClass:[NSDictionary class]])
        {
            NSArray* sublist = (NSArray*)[rootData objectForKey:@"subList"];
            if(sublist!=nil && [sublist count]>0)
            {
                for(NSInteger i=0; i<[sublist count]; i++)
                {
                    NSDictionary* dic = (NSDictionary*)[sublist objectAtIndex:i];
                    SCSubscribeObject* obj = [self parseOneSubObjFromJsonObj:dic];
                    // 同步一下数据库中的订阅item
                    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:obj addIfNotExist:YES];
                    [_SubArray addObject:obj];
                }
                
                if([_SubShakingCenterDelegate respondsToSelector:@selector(notifySubRecomSuccess)])
                    [_SubShakingCenterDelegate notifySubRecomSuccess];
            }
            else
            {
                if([_SubShakingCenterDelegate respondsToSelector:@selector(notifySubRecomFailure)])
                    [_SubShakingCenterDelegate notifySubRecomFailure];
            }
        }
        else if([_SubShakingCenterDelegate respondsToSelector:@selector(notifySubRecomFailure)])
            [_SubShakingCenterDelegate notifySubRecomFailure];
    }
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 用户接口 ----------------------------------------------
//----------------------------------------------------------------------------------------------

-(BOOL)subRecomRequest
{
    if(self._request!=nil && self._request.isLoading)
        return NO;
	
    NSString* urlFull = [NSString stringWithFormat:kSubCenterSubRecomUrl,@""];
	if(!_request)
    {
		_request = [SNURLRequest requestWithURL:urlFull delegate:self];
		_request.cachePolicy = TTURLRequestCachePolicyNoCache;
	}
    else
    {
		_request.urlPath = urlFull;
	}
	
    _request.userInfo = [TTUserInfo topic:kGetGetSubrecom strongRef:nil weakRef:nil];
	_request.response = [[SNURLJSONResponse alloc] init];
	[_request send];
    return YES;
}

-(BOOL)clearDataAndRequest
{
    [self._SubArray removeAllObjects];
    [self performSelector:@selector(subRecomRequest)];
    return YES;
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- clear -------------------------------------------
//----------------------------------------------------------------------------------------------

-(void)clearRequestAndDelegate
{
    if(_request!=nil)
    {
        [_request cancel];
        self._request = nil;
    }
    
    self._SubShakingCenterDelegate = nil;
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 内部函数 -------------------------------------------
//----------------------------------------------------------------------------------------------

-(SCSubscribeObject*)parseOneSubObjFromJsonObj:(NSDictionary*)jsonObj
{
    if (!jsonObj || [jsonObj count] <= 0)
    {
        SNDebugLog(@"ERROR %@-- invalidate jsonObj", NSStringFromSelector(_cmd));
        return nil;
    }
    
    return [SCSubscribeObject subscribeObjFromJsonDic:jsonObj];
}
@end
