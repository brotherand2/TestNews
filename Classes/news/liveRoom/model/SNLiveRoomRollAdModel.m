//
//  SNLiveRoomRollAdModel.m
//  sohunews
//
//  Created by lijian on 15-4-4.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomRollAdModel.h"
//#import "SNURLJSONResponse.h"
//#import "SNURLDataResponse.h"
#import "SNLiveContentObjects.h"
#import "SNADReport.h"
#import "SNVideoAdContext.h"
#import "SNAdManager.h"
#import "SNLiveAdFlowRequest.h"
@interface SNLiveRoomRollAdModel()
{
//    SNURLRequest    *_adRequest;        //流内直播请求
    
}
@end

@implementation SNLiveRoomRollAdModel

- (id)initWithLiveId:(NSString *)liveId
{
    if (self = [super init]) {
        self.liveId             = liveId;//TEST_LIVEID;//
        self.isLoadMore         = NO;
        self.loadNum            = 0;
    }
    return self;
}

- (void)dealloc
{
     //(_adRequest);
}

// 请求最新
//http://testapi.k.sohu.com/api/live/adflow.go?liveId=156140&p1=NTkwNTU5NzYxMjQyNTY1NDM5OA==&gid=02ffff1106111123145b67f8801bdb1e22fd7c19ffbf40&token=46c17d0c951e8a5694b69d48b1f787a
//- (void)requestAdvertising {
//    
//    static int i = 1;
//    NSString *url = [NSString stringWithFormat:SNLinks_Path_Live_AdFlow, _liveId,1,[[SNVideoAdContext sharedInstance] getCurrentChannelID]];
//    url = [NSString stringWithFormat:@"%@&count=%d",url,i];
//    i++;
//    url = [SNAdManager urlByAppendingAdParameter:url];
//    if (!_adRequest) {
//        _adRequest = [SNURLRequest requestWithURL:url delegate:self];
//        _adRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
//    } else {
//        if (![_adRequest.delegates containsObject:self]) {
//            [_adRequest.delegates addObject:self];
//        }
//        _adRequest.urlPath = url;
//    }
//    
//    _adRequest.response = [[SNURLJSONResponse alloc] init];
//    [_adRequest send];
//}
//?liveId=%@&num=%d&channelID=%@
- (void)requestAdvertising {
    static int i = 1;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:_liveId forKey:@"liveId"];
    [params setValue:[NSString stringWithFormat:@"%zd",i] forKey:@"count"];
    i++;
    [[[SNLiveAdFlowRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {
        //lijian 2015.04.03 检查是否为 流内广告
        NSArray *adInfo = [rootData arrayValueForKey:@"adinfo" defaultValue:nil];
        if (adInfo ) {
            SNLiveRollAdContentObject *obj = [[SNLiveRollAdContentObject alloc] init];
            if([self updateContentAdvertisingObj:obj withData:rootData]){
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
                [tempArray addObject:obj];
                
                if(YES == self.isFirstLoad)
                {
                    if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdShouldInsertFirstLoadAdvertising:)]){
                        [_delegate liveRoomRollAdShouldInsertFirstLoadAdvertising:tempArray];
                    }
                    return;
                }
                
                if(NO == self.isLoadMore){
                    if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdShouldThrowAdvertising:maxNumber:)]){
                        [_delegate liveRoomRollAdShouldThrowAdvertising:tempArray maxNumber:obj.step];
                    }
                }else{
                    if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdShouldAddAdvertising:loadNum:)]){
                        [_delegate liveRoomRollAdShouldAddAdvertising:tempArray loadNum:self.loadNum];
                    }
                }
            }
            return;
        }
        
        if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdDidFinishLoad)]){
            [_delegate liveRoomRollAdDidFinishLoad];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        if ([_delegate respondsToSelector:@selector(liveRoomRollAdDidFailLoadWithError:)]) {
            [_delegate liveRoomRollAdDidFailLoadWithError:error];
        }
    }];
}

- (BOOL)updateContentAdvertisingObj:(SNLiveRollAdContentObject *)obj withData:(NSDictionary *)dict
{
    if(nil == obj || nil == dict){
        return NO;
    }
    
    NSArray *adInfo = [dict arrayValueForKey:@"adinfo" defaultValue:nil];
    obj.step = [dict longValueForKey:@"step" defaultValue:0];
    for (NSDictionary *adInfoDic in adInfo) {
        
        obj.adInfo.reportID = [SNADReport parseLiveRoomStreamData:adInfoDic root:dict];
        //加载
        [SNADReport reportLoad:obj.adInfo.reportID];

        
        obj.adInfo.gbCode = [adInfoDic stringValueForKey:@"gbcode" defaultValue:nil];
        obj.adInfo.adpType = [adInfoDic stringValueForKey:@"adp_type" defaultValue:nil];
        
        NSDictionary *data = [adInfoDic dictionaryValueForKey:@"data" defalutValue:nil];
        if(nil != data){
            
            if([data count] == 0){
                return NO;
            }
            
            NSString *error = [data stringValueForKey:@"error" defaultValue:nil];
            if(nil != error && [error isEqualToString:@"1"]){
                return NO;
            }
            
            obj.adInfo.adId = [data stringValueForKey:@"adid" defaultValue:nil];
            obj.adInfo.adSpaceId = [data stringValueForKey:@"itemspaceid" defaultValue:nil];
            obj.adInfo.clickmonitor = [data stringValueForKey:@"clickmonitor" defaultValue:nil];
            obj.adInfo.viewmonitor = [data stringValueForKey:@"viewmonitor" defaultValue:nil];
            obj.adInfo.dsp_source = [data stringValueForKey:@"dsp_source" defaultValue:nil];
            
            NSString *resIconName = nil;
            NSString *resPic = nil;
            NSString *resTitle = nil;
            NSString *resIcon = nil;
            //资源
            NSDictionary *specialDic = [data dictionaryValueForKey:@"special" defalutValue:nil];
            if(nil != specialDic){
                NSDictionary *dic = [specialDic dictionaryValueForKey:@"dict" defalutValue:nil];
                if(nil != dic){
                    resIconName = [dic stringValueForKey:@"icon_name" defaultValue:nil];
                    resPic = [dic stringValueForKey:@"picture" defaultValue:nil];
                    resTitle = [dic stringValueForKey:@"title" defaultValue:nil];
                    resIcon = [dic stringValueForKey:@"icon" defaultValue:nil];
                }
            }
            
            NSDictionary *tempDic = nil;
            if(nil != resIconName){
                tempDic = [data dictionaryValueForKey:resIconName defalutValue:nil];
                if(nil != tempDic){
                    obj.author = [tempDic stringValueForKey:@"text" defaultValue:nil];
                }
            }
            if(nil != resPic){
                tempDic = [data dictionaryValueForKey:resPic defalutValue:nil];
                if(nil != tempDic){
                    obj.contentPic = [tempDic stringValueForKey:@"file" defaultValue:nil];
                    obj.contentPicLink = [tempDic stringValueForKey:@"click" defaultValue:nil];
                }
            }
            if(nil != resTitle){
                tempDic = [data dictionaryValueForKey:resTitle defalutValue:nil];
                if(nil != tempDic){
                    obj.action = [tempDic stringValueForKey:@"text" defaultValue:nil];
                }
            }
            if(nil != resIcon){
                tempDic = [data dictionaryValueForKey:resIcon defalutValue:nil];
                if(nil != tempDic){
                    if(nil == obj.authorInfo){
                        obj.authorInfo = [[SNLiveRoomAuthorInfo alloc] init];
                    }
                    obj.authorInfo.authorimg = [tempDic stringValueForKey:@"file" defaultValue:nil];
                }
            }
        }
        
        //是否是push过来的广告，还是loadmore的广告
        obj.isPushAd = !self.isLoadMore;
        obj.searchContentID = self.searchContentID;
        
        break;
    }
    
    return YES;
}


//#pragma mark - TTURLRequestDelegate
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;
//    id rootData = dataRes.rootObject;
//    
//    //lijian 2015.04.03 检查是否为 流内广告
//    NSArray *adInfo = [rootData arrayValueForKey:@"adinfo" defaultValue:nil];
//    if (adInfo ) {
//        SNLiveRollAdContentObject *obj = [[SNLiveRollAdContentObject alloc] init];
//        if([self updateContentAdvertisingObj:obj withData:rootData]){
//            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:20];
//            [tempArray addObject:obj];
//            
//            if(YES == self.isFirstLoad)
//            {
//                if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdShouldInsertFirstLoadAdvertising:)]){
//                    [_delegate liveRoomRollAdShouldInsertFirstLoadAdvertising:tempArray];
//                }
//                return;
//            }
//            
//            if(NO == self.isLoadMore){
//                if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdShouldThrowAdvertising:maxNumber:)]){
//                    [_delegate liveRoomRollAdShouldThrowAdvertising:tempArray maxNumber:obj.step];
//                }
//            }else{
//                if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdShouldAddAdvertising:loadNum:)]){
//                    [_delegate liveRoomRollAdShouldAddAdvertising:tempArray loadNum:self.loadNum];
//                }
//            }
//        }
//        return;
//    }
//
//    if(_delegate && [_delegate respondsToSelector:@selector(liveRoomRollAdDidFinishLoad)]){
//        [_delegate liveRoomRollAdDidFinishLoad];
//    }
//}
//
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
//{
//    if ([_delegate respondsToSelector:@selector(liveRoomRollAdDidFailLoadWithError:)]) {
//        [_delegate liveRoomRollAdDidFailLoadWithError:error];
//    }
//}
//
//- (void)requestDidCancelLoad:(TTURLRequest*)request {
//    if ([_delegate respondsToSelector:@selector(liveRoomRollAdDidCancelLoad)]) {
//        [_delegate liveRoomRollAdDidCancelLoad];
//    }
//}
@end
