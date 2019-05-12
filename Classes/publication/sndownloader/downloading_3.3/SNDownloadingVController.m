//
//  SNDownloadingVController.m
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingVController.h"
#import "SNDownloadingBaseCell.h"
#import "SNDownloadingNewsCell.h"
#import "SNDownloadingSubCell.h"
#import "SNDBManager.h"
#import "SNDownloadManager.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadViewController.h"
#import "SNDownloadingSectionData.h"
//#import "SNDownloadingProgressBall.h"
#import "SNDatabase_SubscribeCenter.h"
//#import "SNDownloadingProgressBall.h"
#import "DACircularProgressView.h"
#import "UIView+Genie.h"
#import "SNDownloadingExViewController.h"

#define kSectionHeaderHeight                    (114/2.0f)
#define kSectionFooterHeight                    (15.0f)
#define kRowHeight                              (100/2.0f)

#define SELF_EMPTYBG_TOP                                                                    (200/2.0f)
#define SELF_EMPTYBG_WIDTH                                                                  (419/2.0f)
#define SELF_EMPTYBG_HEIGHT                                                                 (175/2.0f)

#define OnekeyDownloadMySubsAndNewsBtnBottom                                                (200/2.0f)
#define OnekeyDownloadMySubsAndNewsBtnWidth                                                 (390/2.0f)
#define OnekeyDownloadMySubsAndNewsBtnHeight                                                (84/2.0f)

@interface SNDownloadingVController ()

@end

@implementation SNDownloadingVController
@synthesize progressBar = _progressBar;
@synthesize downloadingExViewController = _downloadingExViewController;

#pragma mark -

- (id)initWithIDelegate:(id)delegateParam {
    if (self = [self init]) {
        _delegate = delegateParam;
        _toBeDownloadedItems= [NSMutableArray array];
        _toBeDownloadedItemsRow= [NSMutableArray array];
        
        /*
        //默认合起来
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kDownloadingSubSectionHeaderIsFolded]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDownloadingSubSectionHeaderIsFolded];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        //默认合起来
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kDownloadingNewsSectionHeaderIsFolded]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDownloadingNewsSectionHeaderIsFolded];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }*/
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    [SNNotificationManager addObserver:self selector:@selector(reAddToDownloadSchedule) name:@"doResumeNow" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //CGRect _sectionHeaderFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kSectionHeaderHeight);
    //创建Sub section header
    /*
    if (!_subSectionHeaderView) {
        _subSectionHeaderView = [[SNDownloadingSectionHeaderView alloc]
                                 initWithFrame:_sectionHeaderFrame icon:@"search_category_sub.png"
                                 title:NSLocalizedString(@"download_setting_subsection_title", nil)
                                 sectionTag:kDownloadingSubSectionDataTag
                                 seperatorLine:NO
                                 delegate:self];
    }*/
    //创建News section header
    /*
    if (!_newsSectionHeaderView) {
        _newsSectionHeaderView = [[SNDownloadingSectionHeaderView alloc]
                                  initWithFrame:_sectionHeaderFrame icon:@"search_category_news.png"
                                  title:NSLocalizedString(@"download_setting_newssection_title", nil)
                                  sectionTag:kDownloadingNewsSectionDataTag
                                  seperatorLine:YES
                                  delegate:self];
    }*/
    
    //初始化tableview
    //CGRect rect = self.view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundView = nil;

    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0);
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    //加载显示数据
    [[SNDownloadScheduler sharedInstance] setDelegate:self];
    [[SNDownloadScheduler sharedInstance] loadToBeDownloadedPubsAndNewsFromMemInThread];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showOrHideEmptyBg];
    
    CGRect rect = self.view.frame;
    _tableView.frame = CGRectMake(0, 0, rect.size.width-11, rect.size.height);

    _tableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingBgColor]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    // //(_subSectionHeaderView);
    // //(_newsSectionHeaderView);
     //(_toBeDownloadedItems);
     //(_toBeDownloadedItemsRow);
    // //(_toBeDownloadedItemsRowDic);
     //(_cellArray);
    // //(_emptyDownloadingBg);
     //(_onekeyDownloadMySubsAndNewsBtn);
     //(_tableView);
    
    [[SNDownloadScheduler sharedInstance] removeDelegate:self];
    [SNNotificationManager removeObserver:self];
}

#pragma mark - Private methods

- (void)enableOrDisableRightBtn {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (_toBeDownloadedItems.count <= 0) {
        if ([_delegate respondsToSelector:@selector(disableRightBtn)]) {
            [_delegate performSelector:@selector(disableRightBtn)];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(enableRightBtn)]) {
            [_delegate performSelector:@selector(enableRightBtn)];
        }
    }
#pragma clang diagnostic pop
}

- (void)showOrHideEmptyBg {
    /*
    if (_toBeDownloadedItems.count <= 0) {
        [self showEmptyDownloadingBg];
    } else {
        [self hideEmptyDownloadingBg];
    }*/
}

- (void)showEmptyDownloadingBg {
    //空界面
//    if (!_emptyDownloadingBg) {
//        _emptyDownloadingBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_empty_downloading.png"]];
//        _emptyDownloadingBg.center = CGPointMake(TTScreenBounds().size.width/2, SELF_EMPTYBG_TOP+_emptyDownloadingBg.height/2);
//        [self.view addSubview:_emptyDownloadingBg];
//    }
//    _emptyDownloadingBg.hidden = NO;
    
    
    //一键离线按钮：离线刊物、滚动新闻频道
    if (!_onekeyDownloadMySubsAndNewsBtn) {
        _onekeyDownloadMySubsAndNewsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_onekeyDownloadMySubsAndNewsBtn setTitle:NSLocalizedString(@"downloader_onekeydownbtn_title", nil) forState:UIControlStateNormal];
        [_onekeyDownloadMySubsAndNewsBtn setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
        [_onekeyDownloadMySubsAndNewsBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_onekeyDownloadMySubsAndNewsBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDownloadingOneKeyDownloadBtnTextColor]] forState:UIControlStateNormal];
        [_onekeyDownloadMySubsAndNewsBtn setBackgroundImage:[UIImage imageNamed:@"userinfo_bigbutton.png"] forState:UIControlStateNormal];
        [_onekeyDownloadMySubsAndNewsBtn setBackgroundImage:[UIImage imageNamed:@"userinfo_bigbutton_hl.png"] forState:UIControlStateHighlighted];
        _onekeyDownloadMySubsAndNewsBtn.frame = CGRectMake((self.view.width-OnekeyDownloadMySubsAndNewsBtnWidth)/2.0f,
                                                           CGRectGetHeight(self.view.frame)-OnekeyDownloadMySubsAndNewsBtnBottom-OnekeyDownloadMySubsAndNewsBtnHeight,
                                                           OnekeyDownloadMySubsAndNewsBtnWidth,
                                                           OnekeyDownloadMySubsAndNewsBtnHeight);
        [_onekeyDownloadMySubsAndNewsBtn addTarget:self action:@selector(oneKeyDownloadMySubsAndNews) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_onekeyDownloadMySubsAndNewsBtn];
    }
    _onekeyDownloadMySubsAndNewsBtn.hidden = NO;
    
    _tableView.bounces = NO;
}

- (void)hideEmptyDownloadingBg {
    //[_emptyDownloadingBg setHidden:YES];
    [_onekeyDownloadMySubsAndNewsBtn setHidden:YES];
    _tableView.bounces = YES;
}

#pragma mark - For download

- (void)oneKeyDownloadMySubsAndNews {
    //[_subSectionHeaderView resetProgress];
    //[_newsSectionHeaderView resetProgress];
    [_progressBar resetNow];
    [_downloadingExViewController updateProcessLine:0.0f];
    
    [[SNDownloadScheduler sharedInstance] setDelegate:self];
    [[SNDownloadScheduler sharedInstance] start];
}

#pragma mark - UITableViewDataSource
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _toBeDownloadedItems.count;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _toBeDownloadedItemsRow.count;
    /*
    if (section < _toBeDownloadedItems.count) {
        SNDownloadingSectionData *_sectionData = (SNDownloadingSectionData *)[_toBeDownloadedItems objectAtIndex:section];
        if ([kDownloadingSubSectionDataTag isEqualToString:_sectionData.tag]) {
            BOOL _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingSubSectionHeaderIsFolded];
            if (_isFolded) {
                return 0;
            } else {
                return _sectionData.arrayData.count;
            }
        }
        else if ([kDownloadingNewsSectionDataTag isEqualToString:_sectionData.tag]) {
            BOOL _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingNewsSectionHeaderIsFolded];
            if (_isFolded) {
                return 0;
            } else {
                return _sectionData.arrayData.count;
            }
        }
    }
    return 0;*/
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *_downloadingSubItemCellIdentifier = @"downloadingSubItemCellIdentifier";
    static NSString *_downloadingNewsItemCellIdentifier = @"downloadingNewsItemCellIdentifier";
    
    if(indexPath.row < _toBeDownloadedItemsRow.count)
    {
        SNDownloadingBaseCell *_cell = nil; 
        id data = [_toBeDownloadedItemsRow objectAtIndex:indexPath.row];
        if([data isKindOfClass:[SCSubscribeObject class]])
        {
            _cell = [tableView dequeueReusableCellWithIdentifier:_downloadingSubItemCellIdentifier];
            if (!_cell) {
                _cell = [[SNDownloadingSubCell alloc]
                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_downloadingSubItemCellIdentifier delegate:self];
                if(_cellArray==nil) _cellArray = [NSMutableArray arrayWithCapacity:0];
                [_cellArray addObject:_cell];
            }
            [self setDataForCell:_cell atIndexPath:indexPath];
            //[_toBeDownloadedItemsRowDic setObject:_cell forKey:data];
            return _cell;
        }
        else if([data isKindOfClass:[NewsChannelItem class]])
        {
            _cell = [tableView dequeueReusableCellWithIdentifier:_downloadingNewsItemCellIdentifier];
            if (!_cell) {
                _cell = [[SNDownloadingNewsCell alloc]
                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_downloadingNewsItemCellIdentifier delegate:self];
                if(_cellArray==nil) _cellArray = [NSMutableArray arrayWithCapacity:0];
                [_cellArray addObject:_cell];
            }
            [self setDataForCell:_cell atIndexPath:indexPath];
            //[_toBeDownloadedItemsRowDic setObject:_cell forKey:data];
            return _cell;
        }
    }
    
    //default
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    return cell;
    
    /*
    static NSString *_downloadingSubItemCellIdentifier = @"downloadingSubItemCellIdentifier";
    static NSString *_downloadingNewsItemCellIdentifier = @"downloadingNewsItemCellIdentifier";
    
    SNDownloadingBaseCell *_cell = nil;    
    SNDownloadingSectionData *_sectionData = (SNDownloadingSectionData *)[_toBeDownloadedItems objectAtIndex:indexPath.section];
    if ([kDownloadingSubSectionDataTag isEqualToString:_sectionData.tag]) {
        _cell = [tableView dequeueReusableCellWithIdentifier:_downloadingSubItemCellIdentifier];
        if (!_cell) {
            _cell = [[[SNDownloadingSubCell alloc]
                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_downloadingSubItemCellIdentifier delegate:self]
                     autorelease];
        }
        [self setDataForCell:_cell atIndexPath:indexPath];
        return _cell;
    }
    else if ([kDownloadingNewsSectionDataTag isEqualToString:_sectionData.tag]) {
        _cell = [tableView dequeueReusableCellWithIdentifier:_downloadingNewsItemCellIdentifier];
        if (!_cell) {
            _cell = [[[SNDownloadingNewsCell alloc]
                      initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_downloadingNewsItemCellIdentifier delegate:self]
                     autorelease];
        }
        [self setDataForCell:_cell atIndexPath:indexPath];
        return _cell;
    }
    else {
        return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"] autorelease];
    }*/
}

#pragma mark - UITableViewDelegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section < _toBeDownloadedItems.count) {
        
        SNDownloadingSectionData *_sectionData = (SNDownloadingSectionData *)[_toBeDownloadedItems objectAtIndex:section];
        if ([kDownloadingSubSectionDataTag isEqualToString:_sectionData.tag]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingSubSectionHeaderIsFolded] ||
                _sectionData.arrayData.count <= 0) {
                return 0;
            } else {
                return kSectionFooterHeight;
            }
        }
        else if ([kDownloadingNewsSectionDataTag isEqualToString:_sectionData.tag]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDownloadingNewsSectionHeaderIsFolded] ||
                _sectionData.arrayData.count <= 0) {
                return 0;
            } else {
                return kSectionFooterHeight;
            }
        }
    }
    return 0;
}*/

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *_footerView = [[UIView alloc] init];
    [_footerView setBackgroundColor:[UIColor clearColor]];
    return [_footerView autorelease];
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {    
    SNDownloadingSectionData *_sectionData = (SNDownloadingSectionData *)[_toBeDownloadedItems objectAtIndex:section];
    //刊物
    if ([kDownloadingSubSectionDataTag isEqualToString:_sectionData.tag]) {
        return _subSectionHeaderView;
    }
    //新闻
    else if ([kDownloadingNewsSectionDataTag isEqualToString:_sectionData.tag]) {
        return _newsSectionHeaderView;
    }
    return [[[UIView alloc] init] autorelease];
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *_tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([_tableViewCell isKindOfClass:[SNDownloadingBaseCell class]])
    {
    }
}

#pragma mark - SNDownloadingSectionHeaderViewDelegate

//- (void)foldAtSectionTag:(NSString *)sectionTag {
//    [self reloadDataWithAnimation:sectionTag];
//}
//
//- (void)unfoldAtSectionTag:(NSString *)sectionTag {
//    [self reloadDataWithAnimation:sectionTag];
//}
//
//- (void)reloadDataWithAnimation:(NSString *)sectionTag {
//    if ([kDownloadingSubSectionDataTag isEqualToString:sectionTag]) {
//        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if ([kDownloadingNewsSectionDataTag isEqualToString:sectionTag]) {
//        if ([_tableView numberOfSections] > 1) {
//            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
//        }
//        else {
//            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//        }
//    }
//    else {
//        [_tableView reloadData];
//    }
//}

#pragma mark -

- (void)setDataForCell:(SNDownloadingBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    /*
    if (indexPath.section < _toBeDownloadedItems.count) {
        SNDownloadingSectionData *_oneSectionData = [_toBeDownloadedItems objectAtIndex:indexPath.section];
        if (indexPath.row < _oneSectionData.arrayData.count) {
            [cell setData:[_oneSectionData.arrayData objectAtIndex:indexPath.row]];
            
            SNDownloadingCellOrder _order = SNDownloadingCellOrder_Unknown;
            if (_oneSectionData.arrayData.count <= 1) {
                _order = SNDownloadingCellOrder_OnlyOne;
            } else {
                if (indexPath.row == 0) {//First one
                    _order = SNDownloadingCellOrder_First;
                } else if (indexPath.row == (_oneSectionData.arrayData.count-1)) {//Last one
                    _order = SNDownloadingCellOrder_Last;
                } else {//Middle ones
                    _order = SNDownloadingCellOrder_Middle;
                }
            }
            [cell setOrder:_order];
        }
    }*/
    
    if (indexPath.row < _toBeDownloadedItemsRow.count)
    {
        [cell setData:[_toBeDownloadedItemsRow objectAtIndex:indexPath.row]];
        
        SNDownloadingCellOrder _order = SNDownloadingCellOrder_Unknown;
        if (_toBeDownloadedItemsRow.count <= 1) {
            _order = SNDownloadingCellOrder_OnlyOne;
        } else {
            if (indexPath.row == 0) {//First one
                _order = SNDownloadingCellOrder_First;
            } else if (indexPath.row == (_toBeDownloadedItemsRow.count-1)) {//Last one
                _order = SNDownloadingCellOrder_Last;
            } else {//Middle ones
                _order = SNDownloadingCellOrder_Middle;
            }
        }
        [cell setOrder:_order];
    }
}

#pragma mark - SNDownloadSchedulerDelegate

//没有设置要下载的刊物或频道时回调此方法
- (void)plsSetDownloadItems {
}

//没有刊物和新闻可下载时回调此方法
- (void)thereIsNoTasksToDownloadInMainThread {
}

/**
 * 刷新正在离线列表数据
 * SNDownloadScheduler在以下情况回调，回调之前数据状态已经做相应的改变，所以通过刷新列表可以看到不同的状态样式，如下解释：
 * 1)点“一键下载”从本地load到刊物和新闻时：为了初始化“正在离线”列表
 * 2)获取到所有刊物最新一期数据时：为了更新“正在离线”列表显示的subName为termName
 * 3)开始下载某刊物时：为了更新正在下载的刊物列表项右侧样式为向下箭头动画
 * 4)下载某刊物成功时：为了刷新“正在离线”列表数据个数，以不显示下载完成的项
 * 5)下载某刊物失败时：为了刷新正在下载的列表项样式，以显示为可重试样式
 * 6)所有刊物下载完成时：为了刷新“正在离线”列表数据个数，以不显示下载完成的项
 * 综上：完成、取消的列表项在“正在离线”列表上不显示；正在下载，下载失败，等待下载的列表项会在“正在离线”列表上显示；
 */
- (void)refreshDownloadingListInMainThread:(NSMutableArray *)toBeDownloadedItems {    
     //(_toBeDownloadedItems);
    _toBeDownloadedItems = toBeDownloadedItems;
    
    _toBeDownloadedItemsRow = [NSMutableArray array];
    
    //if(_toBeDownloadedItemsRowDic==nil)
        //toBeDownloadedItemsRowDic = [[NSMutableDictionary dictionaryWithCapacity:0] retain];
    for(NSInteger i=0; i<[_toBeDownloadedItems count]; i++)
    {
        id object = [_toBeDownloadedItems objectAtIndex:i];
        if([object isKindOfClass:[SNDownloadingSectionData class]])
        {
            SNDownloadingSectionData* data = (SNDownloadingSectionData*)object;
            if ([kDownloadingSubSectionDataTag isEqualToString:data.tag])
                data.arrayData = [[SNDBManager currentDataBase] filterNewsSubscribeFromSubscribeArray:data.arrayData];
            [_toBeDownloadedItemsRow addObjectsFromArray:data.arrayData];
        }
    }
    [_tableView reloadData];
    
    [self showOrHideEmptyBg];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([_delegate respondsToSelector:@selector(updateRightDownloadingBtnItem)]) {
        [_delegate performSelector:@selector(updateRightDownloadingBtnItem)];
    }
#pragma clang diagnostic pop

}

//每下载完一刊物调用一次此方法以更新刊物SectionHeader上的进度
- (void)updateSubDownloadProgressNumber:(NSNumber *)progress {
    //[_subSectionHeaderView updateProgres:[progress floatValue]];
    if(_progressBar!=nil && [_progressBar respondsToSelector:@selector(updateProgress:anmiated:)])
    {
        CGFloat percent = [progress floatValue];
        [_progressBar updateProgress:percent anmiated:YES];
        [_downloadingExViewController updateProcessLine:percent];
    }
}

//每下载完一新闻频道调用一次此方法以更新频道SectionHeader上的进度
/*
- (void)updateNewsDownloadProgressNumber:(NSNumber *)progress {
    [_newsSectionHeaderView updateProgres:[progress floatValue]];
}*/

//每下载完一刊物调用一次此方法以刷新已离线刊物列表
- (void)refreshDownloadedListInMainThread {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([_delegate respondsToSelector:@selector(refreshDownloadedList)]) {
        [_delegate performSelector:@selector(refreshDownloadedList)];
    }
#pragma clang diagnostic pop

}

//下载结束
-(void)didFinishedDownloadAllInMainThread
{
    //做一个延时通知，以便schedule有时间更新自己的状态
    if(_downloadingExViewController!=nil)
       [_downloadingExViewController performSelector:@selector(didFinishedDownloadAllInMainThread) withObject:nil afterDelay:0.1f];
}


//##########################################################################################################################################
//##########################################################################################################################################
//##########################################################################################################################################
//##########################################################################################################################################
//##########################################################################################################################################
//##########################################################################################################################################




//#pragma mark - SNDownloadManagerDelegate
//
//- (void)noTasksToDownload {
//    SNDebugLog(@"INFO:%@--%@, There is no tasks to download.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    [self showEmptyDownloadingBg];
//}
//
//- (void)didFailedToBatchGetLatestTermId:(NSString *)message {
//}
//
//- (void)requestStarted:(SubscribeHomeMySubscribePO *)downloadingItem {
//}
//
//- (void)updateProgress:(NSNumber *)progress downloadingItemIndex:(NSNumber *)index {
//    SNDebugLog(@"INFO:%@--%@, Updating progress----index:%d, progress:%f.",
//               NSStringFromClass(self.class), NSStringFromSelector(_cmd), [index intValue], [progress floatValue]);
//    
////    SNDownloadingBaseCell *_downloadingCell = (SNDownloadingBaseCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0]];
////    [_downloadingCell updateProgress:progress];
//}
//
//- (void)requestFinished:(SubscribeHomeMySubscribePO *)downloadingItem downloadingItemIndex:(NSNumber *)index {
//    SNDebugLog(@"INFO:%@--%@, Finish a request.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
//    
////    SNDownloadingBaseCell *_downloadingCell = (SNDownloadingBaseCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0]];
////    [_downloadingCell updateProgress:[NSNumber numberWithInt:1]];
////    [_downloadingCell requestFinished];
////    [_downloadingCell resetProgessBar];
//    [self reloadDownloadingTableView];
//    
//    if ([_delegate respondsToSelector:@selector(refreshDownloadedList)]) {
//        
//        [_delegate performSelector:@selector(refreshDownloadedList)];
//        
//    }
//}
//
//- (void)requestFailed:(SubscribeHomeMySubscribePO *)downloadingItem error:(NSError *)error {
//    SNDebugLog(@"INFO:%@--%@, Failed to download %@ with comming message %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), downloadingItem.subName, error.localizedDescription);
//    NSNumber *_index = [[error userInfo] objectForKey:SN_String("downloading_item_index")];
//    if (_index) {
////        SNDownloadingBaseCell *_downloadingCell = (SNDownloadingBaseCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_index intValue] inSection:0]];
////        [_downloadingCell requestFailed];
//    }
//}
//
//- (void)changeToDownloadStatus:(NSNumber *)statusParam forItemIndex:(NSNumber *)index {
//    SNDebugLog(SN_String("INFO: %@--%@, change cell index %d download status to %d. "), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [index intValue], [statusParam intValue]);
////    SNDownloadingBaseCell *_downloadingCell = (SNDownloadingBaseCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0]];
//    switch ([statusParam intValue]) {
//        case SNDownloadWait: {
////            [_downloadingCell resetProgessBar];
//            break;
//        }
//        default:
//            break;
//    }
//}

-(id)getCellFromData:(id)aData
{
    for(SNDownloadingBaseCell* _cell in _cellArray)
    {
        if(_cell.data==aData)
            return _cell;
    }
    
    return nil;
}

-(void)doSuckNow:(id)aFinishItem
{
    id cell = [self getCellFromData:aFinishItem];
    if(cell!=nil)
    {
        NSTimeInterval duration = 1.0f;
        CGRect buttonRect = self.downloadingExViewController.downloadedButton.frame;
        CGRect endRect = CGRectMake(buttonRect.origin.x+35, buttonRect.origin.y+20, 35, 0);
        [cell genieInTransitionWithDuration:duration destinationRect:endRect destinationEdge:BCRectEdgeTop completion:^{} superview:self.downloadingExViewController.view];
    }
}

-(void)reAddToDownloadSchedule
{
    [[SNDownloadScheduler sharedInstance] setDelegate:self];
}
@end
