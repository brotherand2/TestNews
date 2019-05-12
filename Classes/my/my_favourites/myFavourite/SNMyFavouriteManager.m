//
//  SNBaseFavouriteObject.m
//  sohunews
//
//  Created by Gao Yongyue on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMyFavouriteManager.h"
#import "SNDBManager.h"
#import "SNCloudSaveService.h"
#import "SNUserManager.h"
#import "SHH5NewsWebViewController.h"
#import "SNCommonNewsController.h"
#import "SNURLJSONResponse.h"
#import "SNCorpusNewsViewController.h"
#import "SNNewsCollectFive.h"
#import "SNNewsLoginManager.h"

@interface SNMyFavouriteManager () <SNCloudSaveDelegate>
{
    SNCloudSaveService *_userInfoModel;
    BOOL _isDeleteNetworkOperation; //收藏取消收藏的正常页面
    BOOL _isFromFavouritesView; //来源于收藏页面
}
@property (nonatomic, strong)NSDictionary *corpusDict;
@property (nonatomic, copy)NSString *idString;
@property (nonatomic,strong) SNNewsCollectFive* collectFive;//收藏5次
@end

@implementation SNMyFavouriteManager

- (id)init
{
    if (self = [super init]) {
        _userInfoModel = [[SNCloudSaveService alloc] init];
        _userInfoModel.cloudSaveDelegate = self;
        self.collectFive = [[SNNewsCollectFive alloc] init];
    }
    return self;
}

- (void)dealloc {
    _userInfoModel = nil;
}

+ (instancetype)shareInstance {
    static id shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = self.new;
    });
    return shareInstance;
}

- (BOOL)checkIfInMyFavouriteList:(SNBaseFavouriteObject *)baseFavourite {
    SNMyFavourite *myFavourite = [baseFavourite myFavouriteObjectConvertedByBaseFavouriteObject];
    SNMyFavourite *localData = [[SNDBManager currentDataBase] getMyFavourite:myFavourite.myFavouriteRefer contentLeveloneID:myFavourite.contentLeveloneID contentLeveltwoID:myFavourite.contentLeveltwoID];
    SNCloudSave *cloudData = [[SNDBManager currentDataBase] getMyCloudSave:myFavourite.myFavouriteRefer contentLeveloneID:myFavourite.contentLeveloneID contentLeveltwoID:myFavourite.contentLeveltwoID];
    return (localData || cloudData);
}

- (void)addToMyFavouriteList:(SNBaseFavouriteObject *)baseFavourite {
    if (!baseFavourite) return;
    _isFromFavouritesView = NO;

    SNCloudSave *cloudSave = [baseFavourite cloudSaveObjectConvertedByBaseFavouriteObject];
    NSArray *addArray = @[cloudSave];
//    if ([_userInfoModel cloudSaveFavouriteArray:addArray])
    if ([_userInfoModel cloudSaveFavouriteArray:addArray corpusDict:self.corpusDict]) {
        //走接口，加收藏
        _isDeleteNetworkOperation = NO;
    } else {
        //走接口不成功，走本地收藏
        SNMyFavourite *myFavourite = [baseFavourite myFavouriteObjectConvertedByBaseFavouriteObject];
        BOOL addSuccess = [[SNDBManager currentDataBase] saveMyFavourite:myFavourite];
        if (addSuccess) {
            [self showToast];
        }
    }
}

- (void)deleteFromMyFavouriteList:(SNBaseFavouriteObject *)baseFavourite {
    if (!baseFavourite) return;
    _isFromFavouritesView = NO;
    SNMyFavourite *myFavourite = [baseFavourite myFavouriteObjectConvertedByBaseFavouriteObject];
    SNMyFavourite *localData = [[SNDBManager currentDataBase] getMyFavourite:myFavourite.myFavouriteRefer contentLeveloneID:myFavourite.contentLeveloneID contentLeveltwoID:myFavourite.contentLeveltwoID];
    if (localData != nil) {
        //是本地数据，直接删除本地数据即可，不需要走接口
        BOOL deleteSuccess = [[SNDBManager currentDataBase] deleteMyFavourite:myFavourite];
        if (deleteSuccess) {
            [self showCancelToast];
            if (_delegate && [_delegate respondsToSelector:@selector(addToMyFavourite:)]) {
                [self.delegate addToMyFavourite:NO];
            }
        }
    } else {
        //需要云同步
        SNCloudSave *cloudData = [[SNDBManager currentDataBase] getMyCloudSave:myFavourite.myFavouriteRefer contentLeveloneID:myFavourite.contentLeveloneID contentLeveltwoID:myFavourite.contentLeveltwoID];
        if (cloudData != nil) {
            //[_userInfoModel._cloudSaveRequest cancel];
            NSArray *deleteArray = @[cloudData];
            if ([_userInfoModel cloudDelFavouriteArray:deleteArray]) {
                _isDeleteNetworkOperation = YES;
            }
        }
    }
}

//专门为收藏页面的
- (void)deleteMultipleFromMyFavouriteList:(NSArray *)favourites {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        if (_delegate && [_delegate respondsToSelector:@selector(sendDeleteFavouritesRequest:)]) {
            [_delegate sendDeleteFavouritesRequest:NO];
        }
        return;
    }
    
    _isFromFavouritesView = YES;
    //本地收藏
    NSMutableArray *localData = [NSMutableArray arrayWithCapacity:0];
    //云收藏
    NSMutableArray *cloudData = [NSMutableArray arrayWithCapacity:0];
    [favourites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[SNMyFavourite class]]) {
            [localData addObject:obj];
        } else if ([obj isKindOfClass:[SNCloudSave class]]) {
            [cloudData addObject:obj];
        }
    }];
    
    //删除本地收藏
    if ([localData count]) {
        [[SNDBManager currentDataBase] deleteMyFavourites:localData];
        if (_delegate && [_delegate respondsToSelector:@selector(syncMyFavourites:)]) {
            [_delegate syncMyFavourites:localData];
        }
    }
    if ([cloudData count]) {
        //删除云端
        BOOL success = [_userInfoModel cloudDelFavouriteArray:cloudData];
        if (_delegate && [_delegate respondsToSelector:@selector(sendDeleteFavouritesRequest:)]) {
            [_delegate sendDeleteFavouritesRequest:success];
        }
    }
}

- (void)addOrDeleteFavourite:(SNBaseFavouriteObject *)baseFavourite {
    if ([self checkIfInMyFavouriteList:baseFavourite]) {
        //已加入收藏,则取消收藏
        [self deleteFromMyFavouriteList:baseFavourite];
    } else {
        [self addToMyFavouriteList:baseFavourite];
    }
}

- (void)addOrDeleteFavourite:(SNBaseFavouriteObject *)baseFavourite corpusDict:(NSDictionary *)corpusDict {//V5.3.0使用这个
    if (![corpusDict objectForKey:kCorpusID]) {
        NSString *h5wt = [corpusDict stringValueForKey:kH5WebType defaultValue:@""];
        corpusDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", kCorpusID, kCorpusMyFavourite, kCorpusFolderName, kNoCorpusCreat, kNoCorpusFolderName, h5wt, kH5WebType, nil];
    }
    self.corpusDict = corpusDict;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([self checkIfInMyFavouriteList:baseFavourite]) {
        //已加入收藏,则取消收藏
        [self deleteFromMyFavouriteList:baseFavourite];
        
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kIsCancelCollectTag];
    } else {
        
        [self addToMyFavouriteList:baseFavourite];
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kIsCancelCollectTag];
    }
    [userDefaults synchronize];
}

//仅正文页
- (void)addOrDeleteFavouriteFromSHH5Web:(SNBaseFavouriteObject *)baseFavourite corpusDict:(NSDictionary *)corpusDict {//V5.3.0使用这个
    if (![corpusDict objectForKey:kCorpusID]) {
        NSString *h5wt = [corpusDict stringValueForKey:kH5WebType defaultValue:@""];
        corpusDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", kCorpusID, kCorpusMyFavourite, kCorpusFolderName, kNoCorpusCreat, kNoCorpusFolderName, h5wt, kH5WebType, nil];
    }
    self.corpusDict = corpusDict;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([self checkIfInMyFavouriteList:baseFavourite]) {
        //已加入收藏,则取消收藏
        [self deleteFromMyFavouriteList:baseFavourite];
        
        [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kIsCancelCollectTag];
    } else {
        
        if (baseFavourite) {
            BOOL b = [self.collectFive save];
            if (b == YES) {
                [SNNewsLoginManager halfLoginData:@{@"halfScreenTitle":@"一键登录，即可点评收藏文章"} Successed:^(NSDictionary *info) {
                    
                } Failed:nil];
            }
        }
        
        [self addToMyFavouriteList:baseFavourite];
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kIsCancelCollectTag];
    }
    [userDefaults synchronize];
}

//这个获取收藏列表是为收藏列表用的
//- (void)fetchMyFavouriteList {
//    NSString *username = [SNUserManager getUserId];
//    //获取上次没有云同步成功的
//    NSArray *cloudDeleteFavourites = [[SNDBManager currentDataBase] getToDeleteFav:username];
//    if (cloudDeleteFavourites == nil || [cloudDeleteFavourites count] == 0) {
//        [_userInfoModel cloudGetRequest:SNCloudGetFavourite];
//    } else {
//        _isFromFavouritesView = YES;
//        NSMutableArray *deleteArrays = [NSMutableArray arrayWithCapacity:0];
//        [cloudDeleteFavourites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            SNMyFavourite *myFavourite = (SNMyFavourite *)obj;
//            SNBaseFavouriteObject *baseFavourite = [[SNBaseFavouriteObject alloc] initWithMyFavourite:myFavourite];
//            SNCloudSave* cloudSave = [baseFavourite cloudSaveObjectConvertedByBaseFavouriteObject];
//            [deleteArrays addObject:cloudSave];
//        }];
//        _userInfoModel.isGetFavouriteList = YES;
//        [_userInfoModel cloudDelFavouriteArray:deleteArrays];
//    }
//}

- (NSMutableDictionary *)propertiesFromScheme:(NSString *)scheme {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    
    NSArray *components = [scheme componentsSeparatedByString:@"&"];
    for(NSString *component in components) {
        NSArray *parameter = [component componentsSeparatedByString:@"="];
        [properties setObject:parameter[1] forKey:parameter[0]];
    }
    return properties;
}


#pragma mark - SNCloudSaveDelegate
-(void)notifyCloudSaveSuccess:(SNBaseRequest*)request responseObject:(id)responseObject userInfo:(id)userInfo {
    id rootData = responseObject;
    NSArray *favouritesArray = nil;
    
    if([rootData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDict = [rootData objectForKey:@"data"];
        favouritesArray = [dataDict objectForKey:@"favorites"];
        if ([favouritesArray count] > 0) {
            NSDictionary *newsDict = [favouritesArray objectAtIndex:0];
            if (newsDict && [newsDict isKindOfClass:[NSDictionary class]]) {
                  self.idString = [newsDict stringValueForKey:@"id" defaultValue:nil];
            }
        }
    }
    NSArray *array = (NSArray *)userInfo;

    if (_isFromFavouritesView) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [[SNDBManager currentDataBase] deleteMyFavouriteEx:obj];
        }];
        if (_delegate && [_delegate respondsToSelector:@selector(didDeleteFromMyFavouriteSuccessfully:)]) {
            [_delegate didDeleteFromMyFavouriteSuccessfully:array];
        }
        _delegate = nil;
        return;
    }
    
    if (!_isDeleteNetworkOperation) {
        //云同步成功 收藏
        if(array && [array count] == 1) {
            SNCloudSave *cloudSave = (SNCloudSave *)array[0];
            [[SNDBManager currentDataBase] saveMyCloudSave:cloudSave];
        }
        
        [self showToast];
        if (_delegate && [_delegate respondsToSelector:@selector(addToMyFavourite:)]) {
            [self.delegate addToMyFavourite:YES];
        }
    } else {
        if(array && [array count] == 1) {
            SNCloudSave *cloudSave = (SNCloudSave *)array[0];
            [[SNDBManager currentDataBase] deleteMyCloudSave:cloudSave];
        }
        [self showCancelToast];
        if (_delegate && [_delegate respondsToSelector:@selector(addToMyFavourite:)]) {
            [self.delegate addToMyFavourite:NO];
        }
    }
    self.isHandleFavorite = NO;
}

-(void)notifyCloudSaveFailure:(SNBaseRequest*)request userInfo:(id)userInfo stutas:(NSInteger)aStatus msg:(NSString*)aMsg {
    [SNMyFavouriteManager shareInstance].isHandleFavorite = NO;
    NSArray *array = userInfo;
    if (_isFromFavouritesView) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNCloudSave *cloudSave = (SNCloudSave *)obj;
            SNBaseFavouriteObject *baseFavourite = [[SNBaseFavouriteObject alloc] initWithCloudSave:cloudSave];
            SNMyFavourite *myFavourite = [baseFavourite myFavouriteObjectConvertedByBaseFavouriteObject];
            [[SNDBManager currentDataBase] saveMyFavourite:myFavourite];
            [[SNDBManager currentDataBase] deleteMyCloudSave:cloudSave];
        }];
        if (_delegate && [_delegate respondsToSelector:@selector(didDeleteFromMyFavouriteFail)]) {
            [_delegate didDeleteFromMyFavouriteFail];
        }
        _delegate = nil;
        return;
    }
    [SNNotificationCenter hideLoading];
    if (!_isDeleteNetworkOperation) {
        //云同步收藏失败，加入本地收藏
        __block BOOL result = NO;
        if (array.count > 0) {
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[SNMyFavourite class]]) {
                    result = [[SNDBManager currentDataBase] saveMyFavourite:obj];
                    if (!result)
                        *stop = YES;
                } else if ([obj isKindOfClass:[SNCloudSave class]]) {
                    SNBaseFavouriteObject *baseFavourite = [[SNBaseFavouriteObject alloc] initWithCloudSave:obj];
                    SNMyFavourite *myFavourite = [baseFavourite myFavouriteObjectConvertedByBaseFavouriteObject];
                    result = [[SNDBManager currentDataBase] saveMyFavourite:myFavourite];
                    if (!result)
                        *stop = YES;
                }
            }];
            //以下两个分支是兼容，一般情况下不会进入
        } else if ([userInfo isKindOfClass:[SNMyFavourite class]]) {
            SNMyFavourite *myFavourite = userInfo;
            result = [[SNDBManager currentDataBase] saveMyFavourite:myFavourite];
        } else if ([userInfo isKindOfClass:[SNCloudSave class]]) {
            result = [[SNDBManager currentDataBase] saveMyFavourite:[SNMyFavourite generateMyFavFromSNCloudSave:userInfo]];
        }
        if(result) {
            [self showToast];
            if (_delegate && [_delegate respondsToSelector:@selector(addToMyFavourite:)]) {
                [self.delegate addToMyFavourite:YES];
            }
        }
    } else {
        //云同步取消收藏失败
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[SNCloudSave class]]) {
                SNBaseFavouriteObject *baseFavourite = [[SNBaseFavouriteObject alloc] initWithCloudSave:obj];
                SNMyFavourite *myFavourite = [baseFavourite myFavouriteObjectConvertedByBaseFavouriteObject];
                
                [[SNDBManager currentDataBase] saveMyFavourite:myFavourite];
                [[SNDBManager currentDataBase] deleteMyCloudSave:obj];
            } else if ([obj isKindOfClass:[SNMyFavourite class]]) {
                SNBaseFavouriteObject *baseFavourite = [[SNBaseFavouriteObject alloc] initWithMyFavourite:obj];
                SNCloudSave* cloudSave = [baseFavourite cloudSaveObjectConvertedByBaseFavouriteObject];
                [[SNDBManager currentDataBase] saveMyFavourite:obj];
                [[SNDBManager currentDataBase] deleteMyCloudSave:cloudSave];
            }
        }];
        [self showCancelToast];
        if (_delegate && [_delegate respondsToSelector:@selector(addToMyFavourite:)]) {
            [self.delegate addToMyFavourite:NO];
        }
    }
}

-(void)notifyCloudSaveFailure:(SNBaseRequest*)request userInfo:(id)userInfo didFailLoadWithError:(NSError*)error {
    [self notifyCloudSaveFailure:request userInfo:userInfo stutas:0 msg:nil];
}

-(void)notifyCloudGetSuccess {
    if (_delegate && [_delegate respondsToSelector:@selector(fetchCloudFavouritesSuccessfully)]) {
        [_delegate fetchCloudFavouritesSuccessfully];
    }
    _delegate = nil;
}

-(void)notifyCloudGetFailure:(NSInteger)aStatus msg:(NSString*)aMsg {
    if (_delegate && [_delegate respondsToSelector:@selector(fetchCloudFavouritesFailed)]) {
        [_delegate fetchCloudFavouritesFailed];
    }
    _delegate = nil;
}

-(void)notifyCloudGetFailure:(SNBaseRequest*)request didFailLoadWithError:(NSError*)error {
    [self notifyCloudGetFailure:0 msg:nil];
}

- (void)showToast { // 加入收藏toast
    
    if (self.isFromArticle) {
        self.isFromArticle = NO;
        return;
    }
    NSString *corpusID = nil;
    if (_isFromFavouritesView) {
        corpusID = [self.corpusDict objectForKey:kCorpusID];
    } else {
        corpusID = @"0";
    }
    NSString *urlString = [NSString stringWithFormat:@"%@corpusId=%@&folderName=%@&id=%@", kProtocolOpenCorpus, corpusID, [self.corpusDict objectForKey:kCorpusFolderName], self.idString];

    [[SNCenterToast shareInstance] showCenterToastWithTitle:kAlreadyCollect toUrl:urlString userInfo:self.corpusDict mode:SNCenterToastModeSuccess];
    
    [SNUtility requestRedPackerAndCoupon:[NSString stringWithFormat:@"news://newsId=%@", self.idString] type:@"2"];
}

- (void)showCancelToast { // 取消收藏toast
    
    if (!self.isFromArticle) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"failed_to_add_myfavourite", nil) toUrl:nil mode:SNCenterToastModeSuccess];
    } else {
        self.isFromArticle = NO;
    }
}

@end
