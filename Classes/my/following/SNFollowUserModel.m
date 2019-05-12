//
//  SNFollowUserModel.m
//  sohunews
//
//  Created by weibin cheng on 13-12-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNFollowUserModel.h"
//#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNUserConsts.h"
#import "SNUserManager.h"
#import "SNFollowRequest.h"

#define kFollowPageSize 10

@interface SNFollowUserModel()
{
    BOOL _isRefreshing;
}
@property(nonatomic, strong) NSString* nextCursor;//
//@property(nonatomic, strong) SNURLRequest* followRequest;
@property(nonatomic, strong) SNFollowRequest* followRequest;
@property(nonatomic, strong) NSString* pid;
@end
@implementation SNFollowUserModel
@synthesize isFollowing = _isFollowing;
@synthesize hasMore = _hasMore;
@synthesize nextCursor = _nextCursor;
@synthesize userArray = _userArray;
@synthesize delegate = _delegate;
@synthesize followRequest = _followRequest;
@synthesize pid = _pid;
@synthesize lastRequestDate = _lastRequestDate;
-(id)initWithPid:(NSString *)pid
{
    self = [super init];
    if(self)
    {
        _userArray= [[NSMutableArray alloc] initWithCapacity:10];
        if(pid)
            self.pid = pid;
        else
            self.pid = [SNUserManager getPid];
    }
    return self;
}
-(void)dealloc
{
    [_followRequest cancel];
}

//-(void)refresh
//{
//    if(self.followRequest.isLoading)
//        return;
//    if(self.pid.length == 0)
//        return;
////    [_userArray removeAllObjects];
////    if(_isFollowing && [SNUserinfoEx isSelfUser:_pid])
////    {
////        SNUserinfoEx* addFriend = [[[SNUserinfoEx alloc] init] autorelease];
////        addFriend._relation = [NSString stringWithFormat:@"%d", SNCircleSelf];
////        addFriend._nickname = @"添加好友";
////        [self.userArray addObject:addFriend];
////    }
//    NSString* urlFull = [NSMutableString stringWithFormat:kUrlCircleFollowing, self.pid];
//    if(!_isFollowing)
//        urlFull = [NSMutableString stringWithFormat:kUrlCircleFollowed, self.pid];
//    urlFull = [SNUtility addParamsToURLForReadingCircle:urlFull];
//    urlFull = [urlFull stringByAppendingFormat:@"&pageSize=%d", kFollowPageSize];
//    SNURLRequest* request = [SNURLRequest requestWithURL:urlFull delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.urlPath = urlFull;
//    request.response = [[SNURLJSONResponse alloc] init];
//    [request send];
//    self.followRequest = request;
//    _isRefreshing = YES;
//}

-(void)refresh {
    if (self.followRequest) return;
    if (self.pid.length == 0) return;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:[NSString stringWithFormat:@"%zd",kFollowPageSize] forKey:@"pageSize"];
    self.followRequest = [[SNFollowRequest alloc] initWithDict:params pid:self.pid andIsFollowing:_isFollowing];
    __weak typeof(self)weakself = self;
    [self.followRequest send:^(SNBaseRequest *request, id responseObject) {
        weakself.followRequest = nil;
        [weakself requestDidFinishLoadWithResponse:responseObject];
    } failure:^(SNBaseRequest *request, NSError *error) {
        weakself.followRequest = nil;
        [weakself requestDidFailLoadWithError:error];
    }];
    _isRefreshing = YES;
}

//-(void)loadMore
//{
//    if(self.followRequest.isLoading)
//        return;
//    if(self.pid.length == 0)
//        return;
//    if(!self.hasMore)
//        return;
//    NSString* urlFull = [NSMutableString stringWithFormat:kUrlCircleFollowing, self.pid];
//    if(!_isFollowing)
//        urlFull = [NSMutableString stringWithFormat:kUrlCircleFollowed, self.pid];
//    urlFull = [SNUtility addParamsToURLForReadingCircle:urlFull];
//    if(_nextCursor.length>0)
//        urlFull = [NSString stringWithFormat:@"%@&nextCursor=%@", urlFull, _nextCursor];
//    urlFull = [urlFull stringByAppendingFormat:@"&pageSize=%d", kFollowPageSize];
//    
//    SNURLRequest* request = [SNURLRequest requestWithURL:urlFull delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.urlPath = urlFull;
//    request.response = [[SNURLJSONResponse alloc] init];
//    [request send];
//    self.followRequest = request;
//    _isRefreshing = NO;
//}

-(void)loadMore {
    if(self.followRequest) return;
    if(self.pid.length == 0) return;
    if(!self.hasMore) return;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:[NSString stringWithFormat:@"%zd",kFollowPageSize] forKey:@"pageSize"];
    if(_nextCursor.length>0) [params setValue:_nextCursor forKey:@"nextCursor"];
    
    self.followRequest = [[SNFollowRequest alloc] initWithDict:params pid:self.pid andIsFollowing:_isFollowing];
    __weak typeof(self)weakself = self;
    [self.followRequest send:^(SNBaseRequest *request, id responseObject) {
        weakself.followRequest = nil;
        [weakself requestDidFinishLoadWithResponse:responseObject];
    } failure:^(SNBaseRequest *request, NSError *error) {
        weakself.followRequest = nil;
        [weakself requestDidFailLoadWithError:error];
    }];
    _isRefreshing = NO;
}

-(void)requestDidFinishLoadWithResponse:(id)responseObject {
    
    if(_isRefreshing == YES)
    {
        [_userArray removeAllObjects];
        if(_isFollowing && [SNUserinfoEx isSelfUser:_pid])
        {
            SNUserinfoEx* addFriend = [[SNUserinfoEx alloc] init];
            addFriend.relation = [NSString stringWithFormat:@"%ld", (long)SNCircleSelf];
            addFriend.nickName = @"添加好友";
            [self.userArray addObject:addFriend];
        }
        _isRefreshing = NO;
    }
    
    NSDictionary* result = [responseObject objectForKey:@"result"];
    NSNumber* code = [result objectForKey:@"code"];
    NSString* msg = [result objectForKey:@"msg"];
    if(msg.length>0) {
        msg = NSLocalizedString(@"network error", nil);
        //        [[SNToast shareInstance] showToastWithTitle:NSLocalizedString(@"network error", @"")
        //                                              toUrl:nil
        //                                               mode:SNToastUIModeWarning];
    }
    
    if([code intValue]==200)
    {
        self.lastRequestDate = [NSDate date];
        self.nextCursor = [responseObject stringValueForKey:@"nextCursor" defaultValue:nil];
        NSArray* followingList = [responseObject objectForKey:@"followingList"];
        if(!_isFollowing)
            followingList = [responseObject objectForKey:@"followedList"];
        if(followingList.count < kFollowPageSize)
            self.hasMore = NO;
        else
            self.hasMore = YES;
        for(NSDictionary* dic in followingList)
        {
            SNUserinfoEx* info = [[SNUserinfoEx alloc] init];
            info.headImageUrl = [dic objectForKey:@"headUrl"];
            info.nickName = [dic objectForKey:@"nickName"];
            info.pid = [dic stringValueForKey:@"pid" defaultValue:nil];
            info.relation = [dic stringValueForKey:@"relation" defaultValue:nil];
            [_userArray addObject:info];
        }
        
        if(_delegate && [_delegate respondsToSelector:@selector(requestUserModelDidFinish:)])
            [_delegate requestUserModelDidFinish:self.hasMore];
    }
    else
    {
        if(_delegate && [_delegate respondsToSelector:@selector(requestUserModelDidServerError:)])
            [_delegate requestUserModelDidServerError:msg];
    }
}

-(void)requestDidFailLoadWithError:(NSError *)error
{
    _isRefreshing = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(requestUserModelDidNetworkError:)])
        [_delegate requestUserModelDidNetworkError:error];
}

//#pragma -mark TTURLRequestDelegate
//-(void)requestDidFinishLoad:(TTURLRequest *)request
//{
//    if(_isRefreshing == YES)
//    {
//        [_userArray removeAllObjects];
//        if(_isFollowing && [SNUserinfoEx isSelfUser:_pid])
//        {
//            SNUserinfoEx* addFriend = [[SNUserinfoEx alloc] init];
//            addFriend.relation = [NSString stringWithFormat:@"%ld", (long)SNCircleSelf];
//            addFriend.nickName = @"添加好友";
//            [self.userArray addObject:addFriend];
//        }
//        _isRefreshing = NO;
//    }
//    SNURLJSONResponse* dataRes = request.response;
//    id rootData = dataRes.rootObject;
//    SNDebugLog(@"kUserInfoFollowing json data : %@", rootData);
//    
//    NSDictionary* result = [rootData objectForKey:@"result"];
//    NSNumber* code = [result objectForKey:@"code"];
//    NSString* msg = [result objectForKey:@"msg"];
//    if(msg.length>0) {
//        msg = NSLocalizedString(@"network error", nil);
////        [[SNToast shareInstance] showToastWithTitle:NSLocalizedString(@"network error", @"")
////                                              toUrl:nil
////                                               mode:SNToastUIModeWarning];
//    }
//    
//    if([code intValue]==200)
//    {
//        self.lastRequestDate = [NSDate date];
//        self.nextCursor = [rootData stringValueForKey:@"nextCursor" defaultValue:nil];
//        NSArray* followingList = [rootData objectForKey:@"followingList"];
//        if(!_isFollowing)
//            followingList = [rootData objectForKey:@"followedList"];
//        if(followingList.count < kFollowPageSize)
//            self.hasMore = NO;
//        else
//            self.hasMore = YES;
//        for(NSDictionary* dic in followingList)
//        {
//            SNUserinfoEx* info = [[SNUserinfoEx alloc] init];
//            info.headImageUrl = [dic objectForKey:@"headUrl"];
//            info.nickName = [dic objectForKey:@"nickName"];
//            info.pid = [dic stringValueForKey:@"pid" defaultValue:nil];
//            info.relation = [dic stringValueForKey:@"relation" defaultValue:nil];
//            [_userArray addObject:info];
//        }
//        
//        if(_delegate && [_delegate respondsToSelector:@selector(requestUserModelDidFinish:)])
//           [_delegate requestUserModelDidFinish:self.hasMore];
//    }
//    else
//    {
//        if(_delegate && [_delegate respondsToSelector:@selector(requestUserModelDidServerError:)])
//            [_delegate requestUserModelDidServerError:msg];
//    }
//}
//
//-(void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error
//{
//    _isRefreshing = NO;
//    if(_delegate && [_delegate respondsToSelector:@selector(requestUserModelDidNetworkError:)])
//        [_delegate requestUserModelDidNetworkError:error];
//}

@end
