//
//  SNPushSettingModel.m
//  sohunews
//
//  Created by 李 雪 on 11-7-1.
//  update by sampanli
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNPushSettingController.h"
#import "SNPushSettingModel.h"
#import "SNPushSettingItem.h"
#import "SNPushSettingSectionInfo.h"
#import "SNDBManager.h"
#import "SNNotificationCenter.h"
//#import "SNURLJSONResponse.h"
//#import "SNURLRequest.h"
#import "SNTableViewController.h"
#import "SNSubscribeCenterService.h"
#import "SNDatabase_SubscribeCenter.h"

#import "SNCenterToast.h"
#import "SNBookShelf.h"
#import "SNRollingNews.h"

#import "SNPushChangeRequest.h"


//push setting
//本地
#define kPushKey							(@"pushKey")
//服务器 - 获取推送设置信息
#define kUpdate								(@"update")
#define kKey								(@"key")
#define kPubType							(@"pubType")
#define kPubTypeName						(@"name")
#define kPaper								(@"paper")
#define	kSubId								(@"subId")
#define kPubId								(@"pubId")
#define kPubName							(@"pubName")
#define kPubIcon							(@"pubIcon")
#define kPubPush							(@"pubPush")

//服务器 － 提交推送设置更改后的返回
#define kReturnStatus						(@"returnStatus")
#define kReturnMsg							(@"returnMsg")

static SNPushSettingModel *pushModelInstance = nil;

@interface SNPushSettingModel(private)
//- (void)requestPushSettingsFromSrv:(BOOL)bASyn;
@end

@implementation SNPushSettingModel
@synthesize controller=_controller;
@synthesize settingSections=_settingSections;
@synthesize requestAryForChangePushSetting=_requestAryForChangePushSetting;
@synthesize _dicSavePushData;
@synthesize isSucessfull = _isSucessfull;
@synthesize isAllOperation;


+ (SNPushSettingModel *)instance 
{
	@synchronized(self)
    {
        if (pushModelInstance == nil)
        {
            pushModelInstance = [[SNPushSettingModel alloc] init];
        }
    }
    return pushModelInstance;
}

- (NSMutableArray*)settingNovels {
    if (nil == _settingNovels) {
        _settingNovels = [[NSMutableArray alloc] init];
    }
    return _settingNovels;
}

-(NSMutableArray*)settingSections
{
	if (_settingSections == nil) {
		_settingSections =	[[NSMutableArray alloc] init];
	}
	return _settingSections;
}

-(NSMutableArray*)requestAryForChangePushSetting
{
	if (_requestAryForChangePushSetting == nil) {
		_requestAryForChangePushSetting =	[[NSMutableArray alloc] init];
	}
	return _requestAryForChangePushSetting;
}

- (void)dealloc {
}

- (BOOL)isLoaded {
	return !![self.settingSections count];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    if (!self.isLoading) {
        if (PushSettingSwith) {
            NSInteger pushAction = [[NSUserDefaults standardUserDefaults] integerForKey:@"kPushAction"];
            switch (pushAction) {
                case 0:
                    [self loadNormalPushSettingFromCache];
                    break;
                case 1:
                    [self loadSubscribePushSettingFromCache];
                    break;
                case 2:
                    [self loadStockPushSettingFromCache];
                    break;
                    
                default:
                    [self loadNormalPushSettingFromCache];
                    break;
            }
        }
        else{
            [self loadPushSettingFromCache];
        }
    }
}

- (BOOL)loadNormalPushSettingFromCache{
    SNPushSettingItem *subExpressItem = nil;
    
    //返回快讯
    NSArray *subscribeList = [[SNDBManager currentDataBase] getSubArrayWithExpress];
    if ([subscribeList count] != 0) {
        for (SCSubscribeObject *subscribeItem in subscribeList) {
            if (subscribeItem == nil) {
                continue;
            }
            
            SNPushSettingItem *settingItem	= [[SNPushSettingItem alloc] init];
            settingItem.subId	= subscribeItem.subId;
            settingItem.pubId	= subscribeItem.pubIds;
            settingItem.pubName	= subscribeItem.subName;
            settingItem.pubIcon	= subscribeItem.subIcon;
            settingItem.pubPush	= subscribeItem.isPush;
            
            if ([settingItem.subId isEqualToString:kExpressPushId]) {
                subExpressItem = settingItem;
                subExpressItem.pubName	= @"快讯";
                
                NSString *newsPushSet = [[NSUserDefaults standardUserDefaults] stringForKey:kNewsPushSet];
                if (newsPushSet&&![newsPushSet isEqualToString:@"-1"]) {
                    subExpressItem.pubPush	= newsPushSet;
                }
            }
        }
    }
    
    if (!subExpressItem) {
        subExpressItem	= [[SNPushSettingItem alloc] init];
        subExpressItem.subId	= kExpressPushId;
        subExpressItem.pubId	= @"6,29";
        subExpressItem.pubName	= @"快讯";
        subExpressItem.pubIcon	= SNLinks_FixedUrl_Express_IconPic;
        NSString *newsPushSet = [[NSUserDefaults standardUserDefaults] stringForKey:kNewsPushSet];
        if ([newsPushSet isEqualToString:@"0"]) {
            subExpressItem.pubPush	= @"0";
        } else {
            subExpressItem.pubPush	= @"1";
        }
    }
 
    SNPushSettingSectionInfo *sectionTypeInfo = [[SNPushSettingSectionInfo alloc] init];
    sectionTypeInfo.name	= @"";
    [sectionTypeInfo.settingItems addObject:subExpressItem];
    
    SNPushSettingItem *subExpressItem1 = [[SNPushSettingItem alloc] init];
    subExpressItem1.pubName	= @"媒体";
    subExpressItem1.pubPush = @"pubPush";
    
    SNPushSettingItem *subExpressItem2 = [[SNPushSettingItem alloc] init];
    subExpressItem2.pubName	= @"自选股公告";
    subExpressItem2.pubPush = @"pubPush";
   
    [sectionTypeInfo.settingItems addObject:subExpressItem1];
    [sectionTypeInfo.settingItems addObject:subExpressItem2];
    [self.settingSections addObject:sectionTypeInfo];
    
    
    [self didFinishLoad];
    
    return YES;
}

- (BOOL)loadSubscribePushSettingFromCache
{
    NSArray *subscribeList = [[SNDBManager currentDataBase] getSubArrayWithoutExpressOrYouMayLike];
    
    SNPushSettingSectionInfo *sectionTypeInfo = nil;
    if([self.settingSections count] == 0)
    {
        sectionTypeInfo = [[SNPushSettingSectionInfo alloc] init];
        sectionTypeInfo.name	= @"";
        [self.settingSections addObject:sectionTypeInfo];
    }

    for (SCSubscribeObject *subscribeItem in subscribeList) {
        if (subscribeItem == nil) {
            continue;
        }
        
        SNPushSettingItem *settingItem	= [[SNPushSettingItem alloc] init];
        settingItem.subId	= subscribeItem.subId;
        settingItem.pubId	= subscribeItem.pubIds;
        settingItem.pubName	= subscribeItem.subName;
        settingItem.pubIcon	= subscribeItem.subIcon;
        settingItem.pubPush	= subscribeItem.isPush;
        
        [sectionTypeInfo.settingItems addObject:settingItem];

        
    }
   
    [self didFinishLoad];
    
    return YES;
}

- (BOOL)loadStockPushSettingFromCache{
    [self didFinishLoad];
    return YES;
}

- (BOOL)loadPushSettingFromCache
{
//    NSArray *subscribeList = [[SNDBManager currentDataBase] getSubArrayWithoutYouMayLike];

    SNPushSettingSectionInfo *sectionTypeInfo1 = nil;
    SNPushSettingSectionInfo *sectionTypeInfo2 = nil;
    if([self.settingSections count] == 0)
    {
        sectionTypeInfo1 = [[SNPushSettingSectionInfo alloc] init];
        sectionTypeInfo1.name	= @"";
        [self.settingSections addObject:sectionTypeInfo1];
        
        sectionTypeInfo2 = [[SNPushSettingSectionInfo alloc] init];
        sectionTypeInfo2.name	= @"";
        [self.settingSections addObject:sectionTypeInfo2];
    }
    else if(([self.settingSections count] == 1)) {
        sectionTypeInfo1	= [self.settingSections objectAtIndex:0];
        sectionTypeInfo2 = [[SNPushSettingSectionInfo alloc] init];
        sectionTypeInfo2.name	= @"";
        [self.settingSections addObject:sectionTypeInfo2];
    }
    //屏蔽订阅刊物推送
    /*
	for (SCSubscribeObject *subscribeItem in subscribeList) {
	    if (subscribeItem == nil) {
			continue;
		}
				
		SNPushSettingItem *settingItem	= [[SNPushSettingItem alloc] init];
		settingItem.subId	= subscribeItem.subId;
		settingItem.pubId	= subscribeItem.pubIds;
		settingItem.pubName	= subscribeItem.subName;
        settingItem.pubIcon	= subscribeItem.subIcon;
        settingItem.pubPush	= subscribeItem.isPush;
        
        if (![settingItem.subId isEqualToString:kExpressPushId]) {
        [sectionTypeInfo2.settingItems addObject:settingItem];
        }
	}
    */
    [sectionTypeInfo1.settingItems insertObject:[self getExpressPushItem] atIndex:0];
    [sectionTypeInfo1.settingItems insertObject:[self getMediaPushItem] atIndex:1];
    [sectionTypeInfo1.settingItems insertObject:[self getSNSPushItem] atIndex:2];
    [sectionTypeInfo1.settingItems insertObject:[self getNovelPushItem] atIndex:3];
    
	[self didFinishLoad];
	
	return YES;
}

//快讯推送开关
- (SNPushSettingItem *)getExpressPushItem {
    SNPushSettingItem *expressItem = [[SNPushSettingItem alloc] init];
    expressItem.subId	= kExpressPushId;
    expressItem.pubId	= @"6,29";
    expressItem.pubName	= kExpressName;
    expressItem.pubIcon	= SNLinks_FixedUrl_Express_IconPic;
    NSString *newsPushSet = [[NSUserDefaults standardUserDefaults] stringForKey:kNewsPushSet];
    if ([newsPushSet isEqualToString:@"0"]) {
        expressItem.pubPush	= @"0";
    } else {
        expressItem.pubPush	= @"1";
    }
    
    return expressItem;
}
//小说推送开关
- (SNPushSettingItem *)getNovelPushItem {
    SNPushSettingItem *novelPushItem = [[SNPushSettingItem alloc] init];
    novelPushItem.pubName = @"小说";
    novelPushItem.pubPush = @"pubPush";
    novelPushItem.isNovelPushSetting = YES;
    
    [[SNPushSettingModel instance].settingNovels removeAllObjects];
    
    //小说总开关
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *novelSwitch = [userDefault objectForKey:kReaderPushSet];
    if (!novelSwitch || novelSwitch.length <= 0) {//服务端没有值，客户端默认为开
        novelSwitch = @"1";
        [userDefault setObject:@"1" forKey:kReaderPushSet];
    }
    
    NSDictionary *dic = @{@"remind":novelSwitch,@"title":@"小说推送"};
    SNBook *book = [SNRollingNews createBookWithDictionary:dic];
    [[SNPushSettingModel instance].settingNovels addObject:book];
    
    //每一本小说开关
    [SNBookShelf getBooks:@"" count:@"" complete:^(BOOL success,NSArray *books) {
        if (books) {
            
            for (NSDictionary * dic in books) {
                SNBook *book = [SNRollingNews createBookWithDictionary:dic];
                [[SNPushSettingModel instance].settingNovels addObject:book];
            }
        }
    }];
    
    return novelPushItem;
}

//媒体推送，订阅媒体的总开关
- (SNPushSettingItem *)getMediaPushItem {
    SNPushSettingItem *mediaPushItem	= [[SNPushSettingItem alloc] init];
    mediaPushItem.pubName = kMediaPushName;
    mediaPushItem.subId = kMediaPushID;
    NSString *mediaPushSet = [[NSUserDefaults standardUserDefaults] stringForKey:kPaperPushSet];
    if ([mediaPushSet isEqualToString:@"0"]  || ![SNUtility judgeOldSubscribePushSwitch]) {
        mediaPushItem.pubPush = @"0";
    } else {
        mediaPushItem.pubPush = @"1";
    }
    
    return mediaPushItem;
}

//狐友推送开关
- (SNPushSettingItem *)getSNSPushItem {
    SNPushSettingItem *snsPushItem = [[SNPushSettingItem alloc] init];
    snsPushItem.pubName = @"狐友";
    snsPushItem.pubPush = @"pubPush";
    snsPushItem.isSNSPushSetting = YES;
    return snsPushItem;
}

-(void)changePushSetting:(BOOL)bASync data:(NSArray*)changeItems
{
    SNDebugLog(@"changeItems : %@",changeItems);
	if ([changeItems count] == 0) {
		SNDebugLog(@"SNPushSettingModel - changePushSetting : Invalid change items");
		return;
	}
	
	NSMutableString *subIdListForOpenPush		= [[NSMutableString alloc] init];
	NSMutableString *subIdListForClosePush		= [[NSMutableString alloc] init];
	PushSettingChangeRequestItem *requestItem	= [[PushSettingChangeRequestItem alloc] init];
	
	for (PushSettingChangeItem *item in changeItems) {
		if (item.nPushStatus == 0) {
			if ([subIdListForClosePush length] != 0) {
				[subIdListForClosePush appendString:@","];
			}
			
			[subIdListForClosePush appendString:item.settingItem.subId];
		}
		else {
			if ([subIdListForOpenPush length] != 0) {
				[subIdListForOpenPush appendString:@","];
			}
			
            if (item.settingItem.subId.length > 0) {
               [subIdListForOpenPush appendString:item.settingItem.subId];
            }
		}

		[requestItem.changeItems addObject:item];
	}
	
	if ([requestItem.changeItems count] == 0) {
		SNDebugLog(@"SNPushSettingModel - changePushSetting : Empty valid change items");
		return;
	}
	if (requestItem.changeItems.count == 1) {
        PushSettingChangeItem *item = [requestItem.changeItems objectAtIndex:0];
        if (item.settingItem.subId==nil || item.settingItem.subId.length==0 || [item.settingItem.subId isEqualToString:kExpressPushId] || [item.settingItem.subId isEqualToString:kMediaPushID]) {
            SNUserSettingModeType mode = SNUserSettingNewsPushMode;
            if ([item.settingItem.subId isEqualToString:kMediaPushID]) {
                mode = SNUserSettingMediaPushMode;
            }
            
            [[[SNUserSettingRequest alloc] initWithUserSettingMode:mode andModeString:[NSString stringWithFormat:@"%zd",item.nPushStatus]] send:^(SNBaseRequest *request, id responseObject) {
                
                [self handleChangePushSettingRequest:requestItem OnLoadFinished:responseObject];
                [self.requestAryForChangePushSetting removeObject:requestItem];
                
                [SNNotificationCenter hideLoadingAndBlock];
            } failure:^(SNBaseRequest *request, NSError *error) {
                [self handleChangePushSettingRequestFailed:requestItem];
                [self.requestAryForChangePushSetting removeObject:requestItem];
   
                NSString *msg = nil;
                if (![SNUtility getApplicationDelegate].isNetworkReachable) {
                    msg	= NSLocalizedString(@"network error", @"");
                }
                else if (msg.length == 0){//网络中断，立即操作，app不能捕获到网络中断；避免msg为空
                    msg	= NSLocalizedString(@"network error", @"");
                }
                [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeError];
            }];
            
            return;
        }
    }
    //屏蔽订阅刊物推送
    /*
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
	if ([subIdListForOpenPush length] != 0) {
        [params setValue:subIdListForOpenPush forKey:@"yes"];
	}
	
	if ([subIdListForClosePush length] != 0) {
        [params setValue:subIdListForClosePush forKey:@"no"];
	}
	
	//发起请求
	[self.requestAryForChangePushSetting addObject:requestItem];
	
    [[[SNPushChangeRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        BOOL bRequestHandled = NO;
        for (PushSettingChangeRequestItem *item in self.requestAryForChangePushSetting) {
            [self handleChangePushSettingRequest:item OnLoadFinished:responseObject];
            [self.requestAryForChangePushSetting removeObject:item];
            bRequestHandled = YES;
            break;
        }
        if (!bRequestHandled) {
            SNDebugLog(@"SNPushSettingModel - requestDidFinishLoad : push setting change request is not handled on finished");
        }
        [SNNotificationCenter hideLoadingAndBlock];

    } failure:^(SNBaseRequest *request, NSError *error) {
        [SNNotificationCenter hideLoadingAndBlock];
        
        for (PushSettingChangeRequestItem *item in self.requestAryForChangePushSetting) {
            
            [self handleChangePushSettingRequestFailed:item];
            [self.requestAryForChangePushSetting removeObject:item];
            break;
        }
        NSString *msg = nil;
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            msg	= NSLocalizedString(@"network error", @"");
        }
        else if (msg.length == 0){//网络中断，立即操作，app不能捕获到网络中断；避免msg为空
            msg	= NSLocalizedString(@"network error", @"");
        }
        [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeError];
    }];
    */
}

-(SNPushSettingItem*)parsePushSettingItemInfo:(NSDictionary*)pushSettingItemInfo
{
	if ([pushSettingItemInfo count] == 0) {
		SNDebugLog(@"SNPushSettingModel : parsePushSettingItemInfo ,Invalid push setting item info");
		return nil;
	}
	
	SNPushSettingItem *pushSettingItem	= [[SNPushSettingItem alloc] init];
	pushSettingItem.subId		= [pushSettingItemInfo objectForKey:kSubId];
	pushSettingItem.pubId		= [pushSettingItemInfo objectForKey:kPubId];
	pushSettingItem.pubName		= [pushSettingItemInfo objectForKey:kPubName];
	pushSettingItem.pubIcon		= [pushSettingItemInfo objectForKey:kPubIcon];
	pushSettingItem.pubPush		= [pushSettingItemInfo objectForKey:kPubPush];
	return pushSettingItem;
}

-(bool)parsePubTypeItemInfo:(NSDictionary*)pubTypeItemInfo
{
	if ([pubTypeItemInfo count] == 0) {
		SNDebugLog(@"SNPushSettingModel : parsePubTypeItemInfo ,Invalid pubType item info");
		return false;
	}
	
	id paper	= [pubTypeItemInfo objectForKey:kPaper];
	if (paper == nil) {
		SNDebugLog(@"SNPushSettingModel ： parsePubTypeItemInfo,No paper info");
		return false;
	}
	
	//通知中不再分类
	SNPushSettingSectionInfo *sectionInfo	= nil;
	if ([self.settingSections count] == 0) {
		sectionInfo	= [[SNPushSettingSectionInfo alloc] init];
		sectionInfo.name	= @"";
		[self.settingSections addObject:sectionInfo];
	}
	else {
		sectionInfo = [self.settingSections objectAtIndex:0];
	}

	//该订阅类型下只有一订阅需要更新通知状态
	if ([paper isKindOfClass:[NSDictionary class]]) {
		SNPushSettingItem *pushSettingItem = [self parsePushSettingItemInfo:paper];
		if (pushSettingItem == nil) {
			SNDebugLog(@"SNPushSettingModel ： parsePubTypeItemInfo,the only paper push setting info is invalid,break");
			return false;
		}
		else {
			[sectionInfo.settingItems addObject:pushSettingItem];
		}
	}
	//该订阅类型下有多个订阅需要更新通知状态
	else if([paper isKindOfClass:[NSArray class]]){
		for (id paperItem in paper) {
			if (![paperItem isKindOfClass:[NSDictionary class]]) {
				SNDebugLog(@"SNPushSettingModel ： parsePubTypeItemInfo,Find an invalid paperItem class type,continue");
			}
			else {
				SNPushSettingItem *pushSettingItem = [self parsePushSettingItemInfo:paperItem];
				if (pushSettingItem == nil) {
					SNDebugLog(@"SNPushSettingModel ： parsePubTypeItemInfo,Find an invalid paper push setting info,continue");
				}
				else {
					[sectionInfo.settingItems addObject:pushSettingItem];
				}
			}
		}
		
		//没有解析到一个有效的设置
		if ([sectionInfo.settingItems count] == 0) {
			SNDebugLog(@"SNPushSettingModel ： parsePubTypeItemInfo,Can't find any invalid paper push setting info,break");
			return false;
		}
	}
	//无法判断
	else {
		SNDebugLog(@"SNPushSettingModel ： parsePubTypeItemInfo,the only pubType class is invalid,break");
		return false;
	}
	
	//[self.settingSections addObject:sectionInfo];
	
	return true;
}

-(bool)parsePushSettings:(NSDictionary*)pushSettingInfo
{
	//读取更新标记字段
	NSString *update	= [pushSettingInfo objectForKey:kUpdate];
	if ([update length] == 0) {
		SNDebugLog(@"SNPushSettingModel ： parsePushSettings,Invalid update flag");
		return false;
	}
	
	//判断服务器是否返回了有效的key
	NSString *returnKey	= [pushSettingInfo objectForKey:kKey];
	if([returnKey length] == 0)
	{
		SNDebugLog(@"SNPushSettingModel ： parsePushSettings,Invalid key,parse break");
		return false;
	}
	
	//判断是否需要更新
	if ([update intValue] == 0) {
		//无需更新，但是需要保存key
		[[NSUserDefaults standardUserDefaults] setObject:returnKey forKey:kPushKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		SNDebugLog(@"SNPushSettingModel ： parsePushSettings,update flag = 0,key=%@,parse break",returnKey);
		return false;
	}
	
	//读取需要更新的订阅类型
	id pubType	= [pushSettingInfo objectForKey:kPubType];
	if (pubType == nil) {
		SNDebugLog(@"SNPushSettingModel ： parsePushSettings,No pubType info");
		return false;
	}
	
	//只有一种待更新通知设置状态的订阅
	if ([pubType isKindOfClass:[NSDictionary class]]) {
		if (![self parsePubTypeItemInfo:pubType]) {
			return false;
		}
	}
	//有多种待更新通知设置状态的订阅
	else if([pubType isKindOfClass:[NSArray class]]) {
		for (id pubTypeItem in pubType) {
			if (![pubTypeItem isKindOfClass:[NSDictionary class]]) {
				SNDebugLog(@"SNPushSettingModel ： parsePushSettings,Find an invalid pubTypeItem class type,continue");
			}
			else {
				[self parsePubTypeItemInfo:pubTypeItem];
			}
		}
	}
	else {
		SNDebugLog(@"SNPushSettingModel ： parsePushSettings,Invalid pubType class type");
	}
	
	if ([self.settingSections count] == 0) {
		return false;
	}
	else {
		//记录本次更新的key
		NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:kPushKey];
		if (returnKey && ![returnKey isEqualToString:savedKey]) {
			[[NSUserDefaults standardUserDefaults] setObject:returnKey forKey:kPushKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		
		return true;
	}
}

-(void)handleGetPushSettingRequestOnLoadFinished:(NSDictionary*)resData
{
}

-(void)handleChangePushSettingRequest:(PushSettingChangeRequestItem*)requestItem OnLoadFinished:(NSDictionary *)resData
{
    [SNNotificationCenter hideLoadingAndBlock];
    
	if (requestItem == nil || [resData count] == 0) {
		SNDebugLog(@"SNPushSettingModel - handleChangePushSettingRequest : Invalid param");
		return;
	}
	
	NSString *returnStatus	= [resData objectForKey:kStatus];//总开关
    if ([returnStatus length] == 0) {
        returnStatus = [resData objectForKey:kReturnStatus];//子开关，服务端设定的字段不同
    }
	if ([returnStatus length] == 0) {
		SNDebugLog(@"SNPushSettingModel - handleChangePushSettingRequest : Invalid return status");
		return;
	}
	
	//返回状态码!=200表示网络提交成功，但是服务器处理此请求失败
	if (![returnStatus isEqualToString:@"200"]) {
		SNDebugLog(@"SNPushSettingModel - handleChangePushSettingRequest : Change push setting falied.returnStatus=%@,returnMsg=%@"
			  ,returnStatus,[resData objectForKey:kReturnMsg]);
		
		for(PushSettingChangeItem *changeItem in requestItem.changeItems)
		{
             SNMoreSwitcher*switchCtrl = (SNMoreSwitcher*)changeItem.switcher;
            if (switchCtrl.currentIndex==1) {
                //设为关
                [switchCtrl setCurrentIndex:0 animated:YES inEvent:NO];
                changeItem.settingItem.pubPush=@"0";
            }else
            {
                //设为开
                [switchCtrl setCurrentIndex:1 animated:YES inEvent:NO];
                changeItem.settingItem.pubPush=@"1";
                
            }
		}
        NSString *msg = nil;
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            msg	= [NSString  stringWithFormat:@"暂时无法连接网络"];
        }
        else{
            NSString *str = NSLocalizedString(@"Change push setting failed",@"");
            NSString *strNet = @"网络不稳定";
            msg	= [NSString  stringWithFormat:@"%@,%@",strNet,str];
        }
    
        [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeError];
		return;
	}
	//请求成功，更新本地数据库状态
	for (PushSettingChangeItem *item in requestItem.changeItems) {
		NSDictionary *valuePairs	= [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",item.nPushStatus] 
															   forKey:@"isPush"];
        if ([item.settingItem.subId isEqualToString:kExpressPushId]||item.settingItem.subId.length==0) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",item.nPushStatus] forKey:kNewsPushSet];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if ([item.settingItem.subId isEqualToString:kMediaPushID]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",item.nPushStatus] forKey:kPaperPushSet];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            // 更新到新的数据库
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:item.settingItem.subId withValuePairs:valuePairs];
        }
        [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil];
	}
    
	[SNDBManager currentDataBase].isChangePushSetting = YES;
}

-(void)handleChangePushSettingRequestFailed:(PushSettingChangeRequestItem*)requestItem
{
    self.isSucessfull = NO;
    for(PushSettingChangeItem *changeItem in requestItem.changeItems)
	{
        SNMoreSwitcher*switchCtrl = (SNMoreSwitcher*)changeItem.switcher;
        if(switchCtrl.currentIndex==1)
        {
            //设为关
            [switchCtrl setCurrentIndex:0 animated:YES inEvent:NO];
            changeItem.settingItem.pubPush=@"0";
        }
        else {
            //设为开
            [switchCtrl setCurrentIndex:1 animated:YES inEvent:NO];
            changeItem.settingItem.pubPush=@"1";
        }
	}

    [SNNotificationCenter hideLoadingAndBlock];
}

@end

@implementation PushSettingChangeItem 
@synthesize settingItem=_settingItem;
@synthesize switcher=_switcher;
@synthesize nPushStatus = _nPushStatus;


@end

@implementation PushSettingChangeRequestItem
@synthesize changeItems=_changeItems;
@synthesize requestForChangePushSetting=_requestForChangePushSetting;


-(NSMutableArray*)changeItems
{
	if (_changeItems == nil) {
		_changeItems = [[NSMutableArray alloc] init];
	}
	
	return _changeItems;
}


@end
