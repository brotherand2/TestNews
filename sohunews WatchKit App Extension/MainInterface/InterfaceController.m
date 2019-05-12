//
//  InterfaceController.m
//  sohunews WatchKit App Extension
//
//  Created by iEvil on 12/4/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import "InterfaceController.h"
#import "SNWDefine.h"
#import "SNWTools.h"
#import "WatchSessionManager.h"
#import "SNWNewsListRowType.h"

typedef NS_ENUM(NSInteger, SNWMainICLoadMoreViewStatus) {
    SNWMainICLoadMoreViewLoading,
    SNWMainICLoadMoreViewEnd,
};

@interface InterfaceController() {
    NSMutableArray *_dataArray;
    BOOL _isRefreshing;
}

@property (weak, nonatomic) IBOutlet WKInterfaceTable *newsTable;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *loadMoreGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *loadMoreButton;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *hudGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *hudImage;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *loadMoreImage;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self p_updateAppInfo];
    [self p_initUI];
    [self p_updateData];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark -
- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
                            inTable:(WKInterfaceTable *)table
                           rowIndex:(NSInteger)rowIndex {
    //点击任何一条数据返回的字典
    if ([segueIdentifier isEqualToString:snw_push_detail_identifier]) {
        return @{
                 snw_handoff_news_url : _dataArray[rowIndex][snw_list_link],
                 snw_handoff_news_log_params : [NSString stringWithFormat:@"&newsid=%@&newstype=%@",_dataArray[rowIndex][snw_list_newsId], _dataArray[rowIndex][snw_list_newsType]]
                 };
    }
    return nil;
}

- (void)handleActionWithIdentifier:(NSString *)identifier
             forRemoteNotification:(NSDictionary *)remoteNotification {
    //从通知过来也需要刷新
    [self doRefreshAction];
}

- (void)handleUserActivity:(NSDictionary *)userInfo {
    if ([userInfo[snw_handoff_version]
         isEqualToString:snw_handoff_current_version]) {
        //从At Glance过来需要刷新
        [self doRefreshAction];
    }
}

#pragma mark - 
- (void)p_initUI {
    //初始化
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    
    [self.hudImage setImageNamed:@"dot"];
    [self.loadMoreImage setImageNamed:@"dot"];
}

- (void)p_updateData {
    if (!_isRefreshing) {
        //开始更新数据
        _isRefreshing = YES;
        [self startHud];
        [self p_fetchDataWithBlock:^(NSArray *list) {
            if (list.count == 0) {
                //Update UI
                _isRefreshing = NO;
                [self switchLoadMoreView:SNWMainICLoadMoreViewEnd];
                [self.loadMoreGroup setHidden:NO];
                [self.loadMoreButton setTitle:@"暂无数据, 请尝试重新连接网络."];
                [self.loadMoreButton setEnabled:NO];
                [self stopHud];
                return;
            }
            [self.newsTable setNumberOfRows:[list count]
                                withRowType:snw_list_row_type];
            
            [list enumerateObjectsUsingBlock:^(NSDictionary *dict,
                                               NSUInteger idx, BOOL *stop) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    SNWNewsListRowType *cell = [self.newsTable rowControllerAtIndex:idx];
                    NSArray *imageArray = dict[snw_list_image_url];
                    if ([imageArray isKindOfClass:[NSArray class]] && imageArray.count > 0) {
                        [cell setImageWithUrl:imageArray[0]
                                        title:dict[snw_list_title]
                                         time:dict[snw_list_updateTime]];
                    } else {
                        [cell setImageWithUrl:nil
                                        title:dict[snw_list_title]
                                         time:dict[snw_list_updateTime]];
                    }
                }
            }];
            
            //Update UI
            _isRefreshing = NO;
            [self updateLoadingMoreUI];
            [self stopHud];
        }];
    }
}

- (void)p_updateAppInfo {
    [[WatchSessionManager sharedInstance] updateAppInfo];
}

#pragma mark - 
- (void)p_fetchDataWithBlock:(void(^)(NSArray *list))doneBlock {
    [SNWTools getDataFromServerWithType:RequestType_getList Url:nil Reply:^(NSDictionary *replyInfo, NSError *error) {
        //如果没有数据, 直接返回NIL
        if (!replyInfo || ![replyInfo isKindOfClass:[NSDictionary class]]) {
            doneBlock(nil);
            return;
        }
        
        //类型检测
        NSArray *list = replyInfo[snw_list_pushs];
        if (!list || ![list isKindOfClass:[NSArray class]]) {
            doneBlock(nil);
            return;
        }
        
        [_dataArray removeAllObjects];
        [_dataArray addObjectsFromArray:list];
        
        doneBlock(list);
    }];
}

- (void)loadMoreWithBlock:(void(^)(NSArray *list))doneBlock {
    [SNWTools getDataFromServerWithType:RequestType_loadMore Url:nil Reply:^(NSDictionary *replyInfo, NSError *error) {
        if (!replyInfo || ![replyInfo isKindOfClass:[NSDictionary class]]) {
            doneBlock(nil);
            return;
        }
        
        NSArray *list = replyInfo[snw_list_pushs];
        if (!list || ![list isKindOfClass:[NSArray class]]) {
            doneBlock(nil);
            return;
        }
        
        [_dataArray addObjectsFromArray:list];
        doneBlock(list);
    }];
}

#pragma mark -
- (void)startHud {
    [self.hudGroup setHidden:NO];
    [self.hudImage startAnimating];
}

- (void)stopHud {
    [self.hudImage stopAnimating];
    [self.hudGroup setHidden:YES];
}

- (void)updateLoadingMoreUI {
    [self switchLoadMoreView:SNWMainICLoadMoreViewEnd];
    
    [self.loadMoreButton setTitle:@"查看更多新闻"];
    [self.loadMoreButton setEnabled:YES];
    //判断当前列表数量, 如果大于50条不再加载更多
    if (self.newsTable.numberOfRows >= 50) {
        [self.loadMoreGroup setHidden:YES];
    } else {
        [self.loadMoreGroup setHidden:NO];
    }
}

- (void)switchLoadMoreView:(SNWMainICLoadMoreViewStatus)status {
    switch (status) {
        case SNWMainICLoadMoreViewLoading : {
            [self.loadMoreButton setHidden:YES];
            [self.loadMoreImage setHidden:NO];
            [self.loadMoreImage startAnimating];
        }
            break;
        case SNWMainICLoadMoreViewEnd : {
            [self.loadMoreButton setHidden:NO];
            [self.loadMoreImage stopAnimating];
            [self.loadMoreImage setHidden:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
- (IBAction)doRefreshAction {
    //滚动到第一行 突出加载视图
    [self.newsTable scrollToRowAtIndex:0];
    
    //刷新数据
    [self p_updateData];
}

- (IBAction)doLoadMoreAction {
    //加载中...
    [self switchLoadMoreView:SNWMainICLoadMoreViewLoading];
    //获取最后一行的index
    NSInteger rowIndex = self.newsTable.numberOfRows - 1;
    
    //加载更多数据
    [self loadMoreWithBlock:^(NSArray *list) {
        if (list.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self updateLoadingMoreUI];
            });
            return;
        }
        
        NSIndexSet *indexSets = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(rowIndex + 1, [list count])];
        [self.newsTable insertRowsAtIndexes:indexSets
                                withRowType:snw_list_row_type];
        
        __block NSInteger objNumber = 0;
        [indexSets enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSDictionary *obj = list[objNumber];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                SNWNewsListRowType *cell = [self.newsTable rowControllerAtIndex:idx];
                NSArray *imageArray = obj[snw_list_image_url];
                if ([imageArray isKindOfClass:[NSArray class]] && imageArray.count > 0) {
                    [cell setImageWithUrl:imageArray[0]
                                    title:obj[snw_list_title]
                                     time:obj[snw_list_updateTime]];
                } else {
                    [cell setImageWithUrl:nil
                                    title:obj[snw_list_title]
                                     time:obj[snw_list_updateTime]];
                }
            }
            objNumber++;
        }];
        
        [self updateLoadingMoreUI];
    }];
}

@end
