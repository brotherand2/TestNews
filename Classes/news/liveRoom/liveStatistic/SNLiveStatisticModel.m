//
//  SNLiveStatisticModel.m
//  sohunews
//
//  Created by wang yanchen on 13-4-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveStatisticModel.h"
//#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNLiveStatisticRequest.h"

@interface SNLiveStatisticModel () {
    
}

@property(nonatomic, copy) NSString *_hostTeamName;
@property(nonatomic, copy) NSString *_visitTeamName;
@property (nonatomic, strong) SNLiveStatisticRequest *liveStatisticRequest;

@end

@implementation SNLiveStatisticModel
@synthesize liveId = _liveId;
@synthesize delegate = _delegate;
@synthesize sectionArray = _sectionArray;
@synthesize hostName = _hostName;
@synthesize visitName = _visitName;
@synthesize _hostTeamName, _visitTeamName;
@synthesize hostTeamScores = _hostTeamScores;
@synthesize visitTeamScores = _visitTeamScores;

- (id)initWithLiveId:(NSString *)liveId {
    self = [super init];
    if (self) {
        self.liveId = liveId;
        
        // default
        self.hostName = @"主队";
        self.visitName = @"客队";
        
        // 加两个空的数组
        self.sectionArray = [NSMutableArray array];
        [self.sectionArray addObject:@[]];
        [self.sectionArray addObject:@[]];
    }
    return self;
}

- (void)dealloc {
    [self cancelAndCleanDelegate];
     //(_request);
     //(_sectionArray);
     //(_hostName);
     //(_visitName);
     //(_hostTeamName);
     //(_visitTeamName);
     //(_hostTeamScores);
     //(_visitTeamScores);
}

//- (void)refreshLiveStatisticFromServer {
//    if (_request && _request.isLoading) {
//        SNDebugLog(@"%@->%@ : request already running !", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//        return;
//    }
//    
//    if (!_request) {
//        NSString *requestUrl = [NSString stringWithFormat:SNLinks_Path_Live_Statistic, self.liveId];
//        _request = [SNURLRequest requestWithURL:requestUrl
//                                        delegate:nil];
//        _request.timeOut = 30;
//        _request.cachePolicy = TTURLRequestCachePolicyNoCache;
//        _request.response = [[SNURLJSONResponse alloc] init];
//    }
//    __block typeof(self) pSelf = self;
//    [_request sendWithScuccessAction:^(SNURLRequest *request) {
//        SNURLJSONResponse *json = request.response;
//        [pSelf parseDataAndNotifyDelegate:json.rootObject];
//    } failAction:^(SNURLRequest *request, NSError *error) {
//        [pSelf notifyDelegateFailToLoadWithError:error];
//    }];
//}

- (void)refreshLiveStatisticFromServer {
    if (self.liveStatisticRequest) {
        SNDebugLog(@"%@->%@ : request already running !", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    __weak typeof(self)weakself = self;
    self.liveStatisticRequest = [[SNLiveStatisticRequest alloc] initWithDictionary:@{@"liveId":self.liveId}];
    [self.liveStatisticRequest send:^(SNBaseRequest *request, id responseObject) {
        weakself.liveStatisticRequest = nil;
        [weakself parseDataAndNotifyDelegate:responseObject];
    } failure:^(SNBaseRequest *request, NSError *error) {
        weakself.liveStatisticRequest = nil;
        [weakself notifyDelegateFailToLoadWithError:error];
    }];
}


- (void)cancelAndCleanDelegate {
//    if (_request && _request.isLoading)
//        [_request cancel];
    
    self.delegate = nil;
}

- (void)setHostName:(NSString *)hostName {
     //(_hostName);
    
    if (hostName.length == 0)
        hostName = @"主队";
    
    _hostName = [[NSString stringWithFormat:@"%@球员", hostName] copy];
    self._hostTeamName = hostName;
}

- (void)setVisitName:(NSString *)visitName {
     //(_visitName);
    
    if (visitName.length == 0)
        visitName = @"客队";
    
    _visitName = [[NSString stringWithFormat:@"%@球员", visitName] copy];
    self._visitTeamName = visitName;
}

- (NSArray *)columnsTitleForTeam {
    if (_hostTeamScores.count > 5)
        return @[@"第1节",
                 @"第2节",
                 @"第3节",
                 @"第4节",
                 @"加时",
                 @"总分"];
    else
        return @[@"第1节",
                 @"第2节",
                 @"第3节",
                 @"第4节",
                 @"总分"];
}

- (NSArray *)columnsTitleForHost {
    return @[_hostName,
             @"时间",
             @"得分",
             @"篮板",
             @"助攻",
             @"投篮",
             @"三分",
             @"罚球",
             @"抢断",
             @"盖帽",
             @"失误",
             @"犯规"];
}

- (NSArray *)columnsTitleForVisit {
    return @[_visitName,
             @"时间",
             @"得分",
             @"篮板",
             @"助攻",
             @"投篮",
             @"三分",
             @"罚球",
             @"抢断",
             @"盖帽",
             @"失误",
             @"犯规"];
}

- (NSString *)hostTeamName {
    return self._hostTeamName;
}

- (NSString *)visitTeamName {
    return self._visitTeamName;
}

- (NSString *)hostTeamScore {
    return [self.hostTeamScores lastObject];
}

- (NSString *)visitTeamScore {
    return [self.visitTeamScores lastObject];
}

#pragma mark - private

// private String t_p_field_goals_made;/**三分球**/
// private String player_name; /**球员名称**/
// private String person_fouls="犯规";/**犯规**/
// private String games_started;/**是否首发**/
// private String t_p_field_goals_attempted;/**三分投球次数**/
// private String free_throws_attempted;/**总罚球数**/
// private String points="得分";/**总分**/
// private String free_throws_made;/**罚球命中数**/
// private String assists="助攻";/**助攻**/
// private String blocked_shots="封盖";/**盖帽**/
// private String field_goals_attempted;/**投篮数**/
// private String field_goals_made;/**投中数**/
// private String minutes="时间";/**上场时间**/
// private String rebounds_total="篮板";/**篮板**/
// private String steals="抢断";/**抢断**/
// private String turnovers="失误";/**失误**/

- (NSArray *)generatorOnePlayInfos:(NSDictionary *)playData {
    
    NSMutableArray *dataArray = [NSMutableArray array];
    // 名字
    [dataArray addObject:[playData stringValueForKey:@"player_name" defaultValue:@""]];
    // 时间
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"minutes" defaultValue:0]];
        [dataArray addObject:string];
    }
    
    // 得分
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"points" defaultValue:0]];
        [dataArray addObject:string];
    }

    // 篮板
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"rebounds_total" defaultValue:0]];
        [dataArray addObject:string];
    }

    // 助攻
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"assists" defaultValue:0]];
        [dataArray addObject:string];
    }
    
    // 投篮
    {
        NSString *bingo = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"field_goals_made" defaultValue:0]];
        NSString *shot = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"field_goals_attempted" defaultValue:0]];
        [dataArray addObject:[NSString stringWithFormat:@"%@-%@", bingo, shot]];
    }
    // 三分
    {
        NSString *bingo = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"t_p_field_goals_made" defaultValue:0]];
        NSString *shot = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"t_p_field_goals_attempted" defaultValue:0]];
        [dataArray addObject:[NSString stringWithFormat:@"%@-%@", bingo, shot]];
    }
    // 罚球
    {
        NSString *bingo = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"free_throws_made" defaultValue:0]];
        NSString *shot = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"free_throws_attempted" defaultValue:0]];
        [dataArray addObject:[NSString stringWithFormat:@"%@-%@", bingo, shot]];
    }
    // 抢断
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"steals" defaultValue:0]];
        [dataArray addObject:string];
    }
    
    // 盖帽
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"blocked_shots" defaultValue:0]];
        [dataArray addObject:string];
    }
    
    // 失误
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"turnovers" defaultValue:0]];
        [dataArray addObject:string];
    }
    
    // 犯规
    {
        NSString *string = [NSString stringWithFormat:@"%d", [playData intValueForKey:@"person_fouls" defaultValue:0]];
        [dataArray addObject:string];
    }
    
    return dataArray;
}

- (void)parseDataAndNotifyDelegate:(id)rootObj {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bRet = NO;
        NSError *lastError = nil;
        
        if (rootObj && [rootObj isKindOfClass:[NSDictionary class]]) {
            // players
            NSDictionary *playersDic = [(NSDictionary *)rootObj dictionaryValueForKey:@"players"
                                                                         defalutValue:nil];
            if (playersDic) {
                self.sectionArray = [NSMutableArray array];
                // host
                NSArray *hostArray = [playersDic arrayValueForKey:@"h"
                                                     defaultValue:nil];
                
                NSMutableArray *hostPlayers = [NSMutableArray array];
                for (NSDictionary *playerDic in hostArray) {
                    if ([playersDic isKindOfClass:[NSDictionary class]]) {
                        NSArray *onePlayer = [self generatorOnePlayInfos:playerDic];
                        [hostPlayers addObject:onePlayer];
                    }
                }
                [self.sectionArray addObject:hostPlayers];
                
                // visit
                NSArray *visitArray = [playersDic arrayValueForKey:@"v"
                                                      defaultValue:nil];
                
                NSMutableArray *visitPlayers = [NSMutableArray array];
                for (NSDictionary *playerDic in visitArray) {
                    if ([playerDic isKindOfClass:[NSDictionary class]]) {
                        NSArray *onePlayer = [self generatorOnePlayInfos:playerDic];
                        [visitPlayers addObject:onePlayer];
                    }
                }
                [self.sectionArray addObject:visitPlayers];
                
            }
            
            // teams
            NSDictionary *teamsDic = [(NSDictionary *)rootObj dictionaryValueForKey:@"teams"
                                                                       defalutValue:nil];
            if (teamsDic) {
                // host
                NSDictionary *hostTeamDic = [teamsDic dictionaryValueForKey:@"h"
                                                               defalutValue:nil];
                if (hostTeamDic) {
                    self.hostTeamScores = [NSMutableArray array];
                    NSArray *scores = [hostTeamDic arrayValueForKey:@"quarter_scores"
                                                       defaultValue:nil];
                    // 需要确保有四节
                    for (int i = 0; i < 4; ++i) {
                        if (i < scores.count)
                            [self.hostTeamScores addObject:[scores objectAtIndex:i]];
                        else
                            [self.hostTeamScores addObject:@"0"];
                    }
                    // 是否有加时
                    if (scores.count > 4) {
                        int totalExScore = 0;
                        NSArray *exScores = [scores subarrayWithRange:NSMakeRange(4, scores.count - 4)];
                        for (NSString *score in exScores) {
                            totalExScore += [score intValue];
                        }
                        
                        if (totalExScore > 0)
                            [self.hostTeamScores addObject:[NSString stringWithFormat:@"%d", totalExScore]];
                    }
                    
                    [self.hostTeamScores addObject:[NSString stringWithFormat:@"%d", [hostTeamDic intValueForKey:@"points"
                                                                                                    defaultValue:0]]];
                }
                // visit
                NSDictionary *visitTeamDic = [teamsDic dictionaryValueForKey:@"v"
                                                                defalutValue:nil];
                if (visitTeamDic) {
                    self.visitTeamScores = [NSMutableArray array];
                    NSArray *scores = [visitTeamDic arrayValueForKey:@"quarter_scores"
                                                        defaultValue:nil];
                    for (int i = 0; i < 4; ++i) {
                        if (i < scores.count)
                            [self.visitTeamScores addObject:[scores objectAtIndex:i]];
                        else
                            [self.visitTeamScores addObject:@"0"];
                    }
                    // 是否有加时
                    if (scores.count > 4) {
                        int totalExScore = 0;
                        NSArray *exScores = [scores subarrayWithRange:NSMakeRange(4, scores.count - 4)];
                        for (NSString *score in exScores) {
                            totalExScore += [score intValue];
                        }
                        
                        if (totalExScore > 0)
                            [self.visitTeamScores addObject:[NSString stringWithFormat:@"%d", totalExScore]];
                    }
                    
                    [self.visitTeamScores addObject:[NSString stringWithFormat:@"%d", [visitTeamDic intValueForKey:@"points"
                                                                                                    defaultValue:0]]];
                }
                
            }
            
            if (self.sectionArray.count > 0 && self.hostTeamScores.count > 0 && self.visitTeamScores.count > 0)
                bRet = YES;
            else
                lastError = [NSError errorWithDomain:@"no data parsed"
                                                code:404
                                            userInfo:nil];
        }
        else {
            // 服务器返回 空数据
            bRet = NO;
            lastError = [NSError errorWithDomain:@"not found" code:404 userInfo:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!bRet)
                [self notifyDelegateFailToLoadWithError:lastError];
            else if (_delegate && [_delegate respondsToSelector:@selector(didFinishLoadStatistic)])
                [_delegate didFinishLoadStatistic];
        });
    });
    
}

- (void)notifyDelegateFailToLoadWithError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(didFailToLoadStatisticWithError:)])
        [_delegate didFailToLoadStatisticWithError:error];
}

@end
