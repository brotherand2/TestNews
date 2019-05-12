//
//  SNMyFeedBackViewController.m
//  UserFeedBack
//
//  Created by 李腾 on 2016/10/2.
//  Copyright © 2016年 suhu. All rights reserved.
//

#import "SNMyFeedBackViewController.h"
#import "SNFeedBackBaseCell.h"
#import "SNFeedBackModel.h"
#import "SNFeedBackTextModel.h"
#import "SNFeedBackTextCell.h"
#import "SNFeedBackImageCell.h"
#import "SNFeedBackImageModel.h"
#import "UIImage+Utility.h"
#import "SNDatabase+NewFeedBack.h"
#import "SNDBManager.h"
#import "SNFeedBackListRequest.h"
#import "SNSendFeedBackRequest.h"
#import "SNSerQuestionListRequest.h"

#define kDefaultRowHeight 276

@interface SNMyFeedBackViewController () <UITableViewDelegate, UITableViewDataSource, FeedBackTextCellDelegate>

@property (nonatomic, strong) NSMutableArray *feedbacks;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *questionArray;
@property (nonatomic, assign) CGFloat FirstRowHeight;

@end

@implementation SNMyFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = SNUICOLOR(kThemeBg2Color);
    self.questionArray = [self getFirstRowDefaultHotQuestion];
    self.FirstRowHeight = kDefaultRowHeight;
    [self createfbTableView];
    __weak typeof(self)weakself = self;
    [self loadQuestionFromServiceWithServiceQuestionHandle:^(NSArray *serviceQuestionArray) {
        if (serviceQuestionArray.count > 0) {
            weakself.questionArray = serviceQuestionArray;
            weakself.FirstRowHeight = kDefaultRowHeight -  (kQuestionCount-serviceQuestionArray.count)* kDefaultEachQuestionHeight;
            [weakself.fbTableView reloadData];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self loadFeedBackFromDB];
        [self loadFeedBackFromServiceWithFbId:@"0"];
    });
}

#pragma mark - loadFeedBackFromDB
- (void)loadFeedBackFromDB {
    
    SNFeedBackModel *model = self.feedbacks[0];
    NSMutableArray *arrM = [NSMutableArray array];
    [arrM addObject:model];
    [arrM addObjectsFromArray:[[SNDBManager currentDataBase] loadAllFeedBacks]];
    
    self.feedbacks = arrM;
    [self compareDateWithFbArray:self.feedbacks andFromIndex:2];
    [_fbTableView reloadData];
    [_fbTableView scrollToBottom:NO];
    self.fbTableView.scrollsToTop = YES;
}

#pragma mark - loadFeedBackFromService
- (void)loadFeedBackFromServiceWithFbId:(NSString *)fbId{
    if (fbId == nil) {
        [self.refreshControl endRefreshing];
        return;
    }
    NSMutableDictionary *paramM = [NSMutableDictionary dictionary];
    [paramM setObject:fbId forKey:@"id"];
    
    [[[SNFeedBackListRequest alloc] initWithDictionary:paramM] send:^(SNBaseRequest *request, id responseObject) {
        NSDictionary *data = [responseObject objectForKey:@"data"];
        if (!data) return;
        NSArray *messageAndReplyList = data[@"messageAndReplyList"];
        if (messageAndReplyList.count == 0) {
            [self.refreshControl endRefreshing];
            return;
        }
        SNFeedBackTextModel *lastModel = nil;
        if ([fbId isEqualToString:@"0"]) {
            
            SNFeedBackModel *model = self.feedbacks[0];
            if (self.feedbacks.count > 2 && [self.feedbacks.lastObject isKindOfClass:[SNFeedBackTextModel class]]) {
                SNFeedBackTextModel *last = self.feedbacks.lastObject;
                if (last.fbType == FeedBackTypeReply) {
                    lastModel = last;
                }
            }
            [self.feedbacks removeAllObjects];
            [self.feedbacks addObject:model];
        }
        NSMutableArray *arrM = [NSMutableArray array];
        [messageAndReplyList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *content = [obj objectForKey:@"content"];
            NSString * dateStr = [obj objectForKey:@"leaveTime"];
            //设置转换格式
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            //NSString转NSDate
            NSDate *date=[formatter dateFromString:dateStr];
            
            if (content.length > 0) {
                
                SNFeedBackTextModel *textModel = [[SNFeedBackTextModel alloc] init];
                textModel.fbID = [obj objectForKey:@"id"];
                textModel.fbText = [obj objectForKey:@"content"];
                textModel.date = [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
                textModel.fbType = FeedBackTypeMe;
                [arrM addObject:textModel];
            }
            if ([obj objectForKey:@"imageUrl"]) {
                NSArray *imageArr = [obj objectForKey:@"image"];
                [imageArr enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull imgObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    SNFeedBackImageModel *imageModel = [[SNFeedBackImageModel alloc] init];
                    if (content.length == 0) {
                        imageModel.date = [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
                    }
                    imageModel.fbID = [obj objectForKey:@"id"];
                    imageModel.imageUrl = [imgObj objectForKey:@"thumbnail"];
                    imageModel.originalImageUrl = [imgObj objectForKey:@"original"];
                    imageModel.imgHeight = [[imgObj objectForKey:@"height"] floatValue];
                    imageModel.imgWidth = [[imgObj objectForKey:@"width"] floatValue];
                    [arrM addObject:imageModel];
                }];
            }
            NSString *clientReply = [obj objectForKey:@"clientReply"];
            if (clientReply.length > 0) {
                SNFeedBackTextModel *textModel = [[SNFeedBackTextModel alloc] init];
                textModel.date = [obj objectForKey:@"replyTime"];
                textModel.fbType = FeedBackTypeReply;
                textModel.fbText = clientReply;
                [arrM addObject:textModel];
            }
        }];
        
        if (self.feedbacks.count > 1) {
            
            for (NSInteger i = 1; i < self.feedbacks.count; i++) {
                [arrM addObject:self.feedbacks[i]];
            }
        }
        [arrM insertObject:self.feedbacks[0] atIndex:0];
        if (lastModel) {
            [arrM addObject:lastModel];
        }
        self.feedbacks = arrM;
        
        [self compareDateWithFbArray:self.feedbacks andFromIndex:2];
        [self.refreshControl endRefreshing];
        [self.fbTableView reloadData];
        if ([fbId isEqualToString:@"0"]) {
            
            [self.fbTableView scrollToBottom:NO];
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [[SNDBManager currentDataBase] deleteAllFeedBacks];
            
            for (NSInteger i = 1; i < self.feedbacks.count; i++) {
                SNFeedBackModel *model = self.feedbacks[i];
                [[SNDBManager currentDataBase] addFeedBack:model];
                
            }
        });
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self.refreshControl endRefreshing];
    }];
    
}

#pragma mark - createfbTableView
- (void)createfbTableView {
    //create table view
    _fbTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight-kHeaderHeightWithoutBottom - kToolbarHeight) style:UITableViewStylePlain];
    self.fbTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.fbTableView.dataSource = self;
    self.fbTableView.delegate = self;
    self.fbTableView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    self.fbTableView.scrollsToTop = YES;
    [self.view addSubview:self.fbTableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.fbTableView addSubview:self.refreshControl];
    
    [self.fbTableView registerClass:[SNFeedBackTextCell class] forCellReuseIdentifier:NSStringFromClass([SNFeedBackTextModel class])];
    [self.fbTableView registerClass:[SNFeedBackImageCell class] forCellReuseIdentifier:NSStringFromClass([SNFeedBackImageModel class])];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//_sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feedbacks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return self.FirstRowHeight;
    } else {
        
        SNFeedBackModel *model = self.feedbacks[indexPath.row];
        model.row = indexPath.row;
        CGFloat height = [model.class calRowHeightWithModel:self.feedbacks[indexPath.row]];
        return height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNFeedBackBaseCell *cell;
    if (indexPath.row == 0) {
        cell = [[SNFeedBackTextCell alloc] init];
        SNFeedBackTextCell *textCell = (SNFeedBackTextCell *)cell;
        textCell.questionArray = self.questionArray;
        textCell.FirstRowHeight = self.FirstRowHeight;
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self.feedbacks[indexPath.row] class]) forIndexPath:indexPath];
    }
    [tableView insertSubview:self.refreshControl atIndex:0];
    [cell setDataWithModel:self.feedbacks[indexPath.row]];
    if ([cell isMemberOfClass:[SNFeedBackTextCell class]] ) {
        SNFeedBackTextCell *textCell = (SNFeedBackTextCell *)cell;
        textCell.delegate = self;
    }
    return cell;
}

#pragma mark - FeedBackTextCellDelegate
- (void)resendFeedBackWithFbModel:(SNFeedBackModel *)fbModel {
    
    if ([fbModel isMemberOfClass:[SNFeedBackTextModel class]]) {
        SNFeedBackTextModel *textModel = (SNFeedBackTextModel *)fbModel;
        textModel.date = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        // 发送反馈
        NSMutableDictionary *paramM = [NSMutableDictionary dictionary];
        [paramM setObject:textModel.fbText forKey:@"content"];
        
        [[[SNSendFeedBackRequest alloc] initWithDictionary:paramM] send:^(SNBaseRequest *request, id responseObject) {
            if ([responseObject[@"statusCode"] isEqualToString:@"200"]) {
                [self.feedbacks addObject:textModel];
                [self compareDateWithFbArray:self.feedbacks andFromIndex:self.feedbacks.count -2];
                [self.fbTableView reloadData];
                [self.fbTableView scrollToBottom:YES];
                self.fbTableView.scrollsToTop = YES;
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送成功" toUrl:nil mode:SNCenterToastModeSuccess];
                [self createAutoReply];
                [[SNDBManager currentDataBase] addFeedBack:textModel];
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送失败" toUrl:nil mode:SNCenterToastModeError];
        }];
    }
}

- (void)setFeedBackDict:(NSDictionary *)feedBackDict {
    _feedBackDict = feedBackDict;
    NSString *content = [feedBackDict objectForKey:@"content"];
    if (content.length > 0) {
        SNFeedBackTextModel *textModel = [[SNFeedBackTextModel alloc] init];
        textModel.fbText = content;
        textModel.fbType = FeedBackTypeMe;
        textModel.date = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        [self.feedbacks addObject:textModel];
        [[SNDBManager currentDataBase] addFeedBack:textModel];
    }
    NSArray *imageArr = [feedBackDict objectForKey:@"images"];
    if (imageArr.count > 0) {
        [imageArr enumerateObjectsUsingBlock:^(UIImage *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SNFeedBackImageModel *imageModel = [[SNFeedBackImageModel alloc] init];
            imageModel.navImage = obj;
            imageModel.date = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            [self.feedbacks addObject:imageModel];
            [[SNDBManager currentDataBase] addFeedBack:imageModel];
        }];
    }
    
    [self compareDateWithFbArray:self.feedbacks andFromIndex:self.feedbacks.count - 5];
    [self.fbTableView reloadData];
    [self.fbTableView scrollToBottom:YES];
    [self createAutoReply];
    
}

#pragma mark - AutoReply
- (void)createAutoReply {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        SNFeedBackTextModel *textModel = [[SNFeedBackTextModel alloc] init];
        textModel.date = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        textModel.hideDate = YES;
        textModel.fbType = FeedBackTypeReply;
        textModel.fbText = @"感谢您的反馈,我们会尽快给您解答";
        [self.feedbacks addObject:textModel];
        
        [self.fbTableView reloadData];
        [self.fbTableView scrollToBottom:YES];
    });
}

- (NSMutableArray *)feedbacks {
    if (_feedbacks == nil) {
        _feedbacks = [NSMutableArray array];
        SNFeedBackTextModel *fb = [[SNFeedBackTextModel alloc] init];
        fb.fbText = @"您好,欢迎您的到来!\n您可以直接点击问题或提问! \n\n您是否也遇到以下问题?";
        fb.fbType = FeedBackTypeReply;
        NSDate *date = [NSDate date];
        fb.date = [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
        [_feedbacks addObject:fb];
        
    }
    return _feedbacks;
}

- (void)refresh {
    if (self.feedbacks.count > 1) {
        
        SNFeedBackModel *fbModel = self.feedbacks[1];
        if (fbModel.fbID != nil) {
            
            [self loadFeedBackFromServiceWithFbId:fbModel.fbID];
        } else {
            [self.refreshControl endRefreshing];
        }
    } else {
        [self.refreshControl endRefreshing];
    }
    
}

- (void)compareDateWithFbArray:(NSArray *)fbArray andFromIndex:(NSInteger )index {
    if (index > 1) {
        
        for (NSInteger i = index; i < fbArray.count; i++) {
            SNFeedBackModel *model = fbArray[i];
            SNFeedBackModel *lastModel = fbArray[i -1];
            if ((model.date.doubleValue - lastModel.date.doubleValue) < (60*3)) {
                model.hideDate = YES;
            }
        }
    }
}

/**
 服务端获取最新的反馈常见问题

 @param questionHandle 请求成功的回调
 */
- (void)loadQuestionFromServiceWithServiceQuestionHandle:(void(^)(NSArray *serviceQuestionArray))questionHandle {
    
    //// 网络请求最新问题
    [[[SNSerQuestionListRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [[responseObject objectForKey:@"statusCode"] integerValue] == 000) {
            
            NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:3];
            NSArray *array = [responseObject objectForKey:@"data"];
            for (NSDictionary *obj in array) {
                [arrM addObject:@{kQuestionTitle:[obj objectForKey:@"description"],kQuestionId:[obj objectForKey:@"_id"]}];
            }
            if (questionHandle) {
                questionHandle(arrM.copy);
            }
        }
    } failure:nil];
    
}

/// 这里本地修改反馈默认显示的三个问题及ID ///
- (NSArray *)getFirstRowDefaultHotQuestion {
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:3];
    [arrM addObject:@{kQuestionTitle:@"如何关闭夜间模式?",kQuestionId:@"25"}];
    [arrM addObject:@{kQuestionTitle:@"怎么开启语音播放新闻?",kQuestionId:@"32"}];
    [arrM addObject:@{kQuestionTitle:@"如何调整字体大小?",kQuestionId:@"33"}];
    
    return arrM.copy;
}

@end
