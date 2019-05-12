//
//  SNDownloadSettingViewController.m
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadSettingViewController.h"
#import "SNDownloadSettingTableViewCell.h"
#import "SNDownloadSettingSubCell.h"
#import "SNDownloadSettingNewsCell.h"
#import "SNDBManager.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadSettingSectionData.h"
#import "SNDownloadManager.h"
#import "SNSubDownloadManager.h"
#import "SNDownloadScheduler.h"


#define kSectionHeaderHeight                    (114/2.0f)
#define kSectionFooterHeight                    (15.0f)
#define kRowHeight                              (100/2.0f)

@interface SNDownloadSettingViewController ()
-(NSString*)generateStringFromArray;
@end

@implementation SNDownloadSettingViewController

#pragma mark -

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
        _referfrom = [query objectForKey:@"referfrom"];
        _toBeDownloadedItems= [NSMutableArray array];

        /*
        //默认合起来
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kDownloadSettingSubSectionHeaderIsFolded]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDownloadSettingSubSectionHeaderIsFolded];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        //默认合起来
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kDownloadSettingNewsSectionHeaderIsFolded]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDownloadSettingNewsSectionHeaderIsFolded];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }*/
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return more_offline_setting;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //已经来过离线设置页面，并且做过设置
    //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"modifyDownloadSettingBefore"];
    
    //如果从离线页进入
    if(_referfrom!=nil)
    {
        NSString* now = [self generateStringFromArray];
        BOOL isDownloading = [SNDownloadScheduler sharedInstance].isDownloading;
        if(![now isEqualToString:_selectedWhenEnter] && isDownloading)
        {
            NSString* message = @"设置已修改，下次离线时生效!";
            [[SNCenterToast shareInstance] showCenterToastWithTitle:message toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化tableview
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.contentInset = UIEdgeInsetsMake(kDownloadSettingTableViewInsetTop, 0, kDownloadSettingTableViewInsetBottom, 0);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kDownloadSettingTableViewInsetTop, 0, kDownloadSettingTableViewInsetBottom, 0);
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    //无头模式
    [self addHeaderView];
    [self addToolbar];
    [self.headerView setSections:[NSArray arrayWithObjects:NSLocalizedString(@"download_setting_title",@""), nil]];
    
    //加载显示数据
    [self loadToBeDownloadItemsInThreadFromServer:NO];
    
    //Section header
    if (!_subSectionHeaderView) {
        CGRect _sectionHeaderFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kSectionHeaderHeight);
        _subSectionHeaderView = [[SNDownloadSettingSectionHeaderView alloc]
                                 initWithFrame:_sectionHeaderFrame icon:@"search_category_sub.png"
                                 title:NSLocalizedString(@"download_setting_subsection_title", nil)
                                 sectionTag:kDownloadSettingSubSectionDataTag
                                 seperatorLine:NO
                                 delegate:self];
    }
    _tableView.tableHeaderView = _subSectionHeaderView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //刷新一下头
    [self updateSubSectionHeader];
    
    /*
     标记程序安装后用户已经点开过一次DownloadSetting界面。
     这是为了保证程序安装后第一次打开离线管理直接进离线设置，以后进离线管理还是进已离线列表和正在离线列表;
     */
    [[NSUserDefaults standardUserDefaults] setObject:kIfDownloadSettingHadShown forKey:kIfDownloadSettingHadShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
     //(_subSectionHeaderView);
    // //(_newsSectionHeaderView);
    [[_channelModel delegates] removeObject:self];
     //(_channelModel);
     //(_toBeDownloadedItems);
}

- (void)dealloc {
     //(_subSectionHeaderView);
    // //(_newsSectionHeaderView);
    [[_channelModel delegates] removeObject:self];
     //(_channelModel);
     //(_toBeDownloadedItems);
     //(_toBeDownloadedItemsRow);
     //(_selectedWhenEnter);
}

#pragma mark - Private methods

- (void)loadToBeDownloadItemsInThreadFromServer:(BOOL)needLoadFromServer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *_tempToBeDownloadedItems = [NSMutableArray array];
        NSMutableArray *_tempToBeDownloadedItemsRow = [NSMutableArray array];

        //Load to be downloaded subs;
        SNDownloadSettingSectionData *_oneSectionData = [[SNDownloadSettingSectionData alloc] init];
        NSArray *_selectedMysubs = [[SNDBManager currentDataBase] getSubArrayCanOffline];
        NSMutableArray* validateSelectedMysubs = [NSMutableArray arrayWithCapacity:0];
        
        //过滤频道中不可以离线的
        for(NSInteger i=[_selectedMysubs count]-1; i>=0; i--)
        {
            id object = [_selectedMysubs objectAtIndex:i];
            if([object isKindOfClass:[SCSubscribeObject class]])
            {
                SCSubscribeObject* item = (SCSubscribeObject*)object;
                if(![SNSubDownloadManager validateDownloadPaper:item] && ![SNSubDownloadManager validateDownloadChannel:item])
                    SNDebugLog(@"无法离线的link对象 %@", item.link);
                else
                    [validateSelectedMysubs insertObject:object atIndex:0];
            }
        }
        
        [_tempToBeDownloadedItemsRow addObjectsFromArray:validateSelectedMysubs];
        if (!!validateSelectedMysubs && (validateSelectedMysubs.count > 0)) {
            [_oneSectionData.arrayData addObjectsFromArray:validateSelectedMysubs];
            [_oneSectionData setTag:kDownloadSettingSubSectionDataTag];
            [_tempToBeDownloadedItems addObject:_oneSectionData];
        }
         //(_oneSectionData);
        
        //Load to be downloaded news from local;
        _oneSectionData = [[SNDownloadSettingSectionData alloc] init];
        NSArray *_selectedSubedChannels = [[SNDBManager currentDataBase] getSubedNewsChannelList];
        [_toBeDownloadedItemsRow addObjectsFromArray:_selectedSubedChannels];
        if (!!_selectedSubedChannels && (_selectedSubedChannels.count > 0)) {
            [_oneSectionData.arrayData addObjectsFromArray:_selectedSubedChannels];
            [_oneSectionData setTag:kDownloadSettingNewsSectionDataTag];
            [_tempToBeDownloadedItems addObject:_oneSectionData];
        }
         //(_oneSectionData);
        
        //Load tobe downloaded news from server
        dispatch_async(dispatch_get_main_queue(), ^{
             //(_toBeDownloadedItems);
            _toBeDownloadedItems = _tempToBeDownloadedItems;
             //(_toBeDownloadedItemsRow);
            _toBeDownloadedItemsRow = _tempToBeDownloadedItemsRow;
            [_tableView reloadData];
            
            //加载完数据 刷新一下头
            [self performSelectorOnMainThread:@selector(updateSubSectionHeader) withObject:nil waitUntilDone:NO];
            
            //标记一下刚进入时的选择状态
            _selectedWhenEnter = [self generateStringFromArray];

            if (needLoadFromServer) {
                _channelModel = [[SNChannelModel alloc] init];
                [[_channelModel delegates] addObject:self];
                [_channelModel load:TTURLRequestCachePolicyNetwork more:NO];
            }
        });
    });
}

#pragma mark - TTModelDelegate

- (void)modelDidFinishLoad:(id<TTModel>)model {
    SNDebugLog(@"===INFO: %@,%@, Main thread:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread isMainThread]);
    [[_channelModel delegates] removeObject:self];
     //(_channelModel);
    [self loadToBeDownloadItemsInThreadFromServer:NO];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
    SNDebugLog(@"===INFO: %@,%@, Main thread:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread isMainThread]);
    [[_channelModel delegates] removeObject:self];
     //(_channelModel);
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
    SNDebugLog(@"===INFO: %@,%@, Main thread:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread isMainThread]);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return _toBeDownloadedItems.count;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _toBeDownloadedItemsRow.count;
    
    /*
    if (section < _toBeDownloadedItems.count) {
         SNDownloadSettingSectionData *_oneSectionData = [_toBeDownloadedItems objectAtIndex:section];
        if ([kDownloadSettingSubSectionDataTag isEqualToString:_oneSectionData.tag]) {
            BOOL _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingSubSectionHeaderIsFolded];
            if (_isFolded) {
                return 0;
            } else {
                return _oneSectionData.arrayData.count;
            }
        }
        else if ([kDownloadSettingNewsSectionDataTag isEqualToString:_oneSectionData.tag]) {
            BOOL _isFolded = [[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingNewsSectionHeaderIsFolded];
            if (_isFolded) {
                return 0;
            } else {
                return _oneSectionData.arrayData.count;
            }
        }
    }
    return 0;*/
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *_toBeDownloadedSubItemCellIdentifier = @"toBeDownloadedSubItemCellIdentifier";
    static NSString *_toBeDownloadedNewsItemCellIdentifier = @"toBeDownloadedNewsItemCellIdentifier";
    
    if(indexPath.row < _toBeDownloadedItemsRow.count)
    {
        id data = [_toBeDownloadedItemsRow objectAtIndex:indexPath.row];
        if([data isKindOfClass:[SCSubscribeObject class]])
        {
            SNDownloadSettingTableViewCell *_cell = nil;
            _cell = [tableView dequeueReusableCellWithIdentifier:_toBeDownloadedSubItemCellIdentifier];
            if (!_cell) {
                _cell = [[SNDownloadSettingSubCell alloc]
                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_toBeDownloadedSubItemCellIdentifier delegate:self];
            }
            [self setDataForCell:_cell atIndexPath:indexPath];
            return _cell;
        }
        else if([data isKindOfClass:[NewsChannelItem class]])
        {
            SNDownloadSettingTableViewCell *_cell = nil;
            _cell = [tableView dequeueReusableCellWithIdentifier:_toBeDownloadedNewsItemCellIdentifier];
            if (!_cell) {
                _cell = [[SNDownloadSettingNewsCell alloc]
                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_toBeDownloadedNewsItemCellIdentifier delegate:self];
            }
            [self setDataForCell:_cell atIndexPath:indexPath];
            return _cell;
        }
    }
    
    //default
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    
    /*
    if (indexPath.section < _toBeDownloadedItems.count) {
        static NSString *_toBeDownloadedSubItemCellIdentifier = @"toBeDownloadedSubItemCellIdentifier";
        static NSString *_toBeDownloadedNewsItemCellIdentifier = @"toBeDownloadedNewsItemCellIdentifier";
        
        SNDownloadSettingTableViewCell *_cell = nil;
        SNDownloadSettingSectionData *_oneSectionData = [_toBeDownloadedItems objectAtIndex:indexPath.section];
        if ([kDownloadSettingSubSectionDataTag isEqualToString:_oneSectionData.tag]) {
            _cell = [tableView dequeueReusableCellWithIdentifier:_toBeDownloadedSubItemCellIdentifier];
            if (!_cell) {
                _cell = [[[SNDownloadSettingSubCell alloc]
                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_toBeDownloadedSubItemCellIdentifier delegate:self]
                         autorelease];
            }
            [self setDataForCell:_cell atIndexPath:indexPath];
            return _cell;
        }
        else if ([kDownloadSettingNewsSectionDataTag isEqualToString:_oneSectionData.tag]) {
            _cell = [tableView dequeueReusableCellWithIdentifier:_toBeDownloadedNewsItemCellIdentifier];
            if (!_cell) {
                _cell = [[[SNDownloadSettingNewsCell alloc]
                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_toBeDownloadedNewsItemCellIdentifier delegate:self]
                         autorelease];
            }
            [self setDataForCell:_cell atIndexPath:indexPath];
            return _cell;
        }
    }
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"] autorelease];*/
}

#pragma mark - UITableViewDelegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section < _toBeDownloadedItems.count) {
        SNDownloadSettingSectionData *_oneSectionData = [_toBeDownloadedItems objectAtIndex:section];
        if ([kDownloadSettingSubSectionDataTag isEqualToString:_oneSectionData.tag]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingSubSectionHeaderIsFolded] ||
                _oneSectionData.arrayData.count <= 0) {
                return 0;
            } else {
                return kSectionFooterHeight;
            }
        }
        else if ([kDownloadSettingNewsSectionDataTag isEqualToString:_oneSectionData.tag]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:kDownloadSettingNewsSectionHeaderIsFolded] ||
                _oneSectionData.arrayData.count <= 0) {
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
    if (section < _toBeDownloadedItems.count) {
        SNDownloadSettingSectionData *_oneSectionData = [_toBeDownloadedItems objectAtIndex:section];
        CGRect _sectionHeaderFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kSectionHeaderHeight);
        //刊物
        if ([kDownloadSettingSubSectionDataTag isEqualToString:_oneSectionData.tag]) {
            if (!_subSectionHeaderView) {
                _subSectionHeaderView = [[SNDownloadSettingSectionHeaderView alloc]
                                         initWithFrame:_sectionHeaderFrame icon:@"search_category_sub.png"
                                         title:NSLocalizedString(@"download_setting_subsection_title", nil)
                                         sectionTag:kDownloadSettingSubSectionDataTag
                                         seperatorLine:NO
                                         delegate:self];
            }
            [self updateSubSectionHeader];
            return _subSectionHeaderView;
        }
        //新闻
        else if ([kDownloadSettingNewsSectionDataTag isEqualToString:_oneSectionData.tag]) {
            if (!_newsSectionHeaderView) {
                _newsSectionHeaderView = [[SNDownloadSettingSectionHeaderView alloc]
                                          initWithFrame:_sectionHeaderFrame icon:@"search_category_news.png"
                                          title:NSLocalizedString(@"download_setting_newssection_title", nil)
                                          sectionTag:kDownloadSettingNewsSectionDataTag
                                          seperatorLine:YES
                                          delegate:self];
            }
            [self updateNewsSectionHeader];
            return _newsSectionHeaderView;
        }
    }
    return [[[UIView alloc] init] autorelease];
}*/

- (void)updateSubSectionHeader {
    for (SNDownloadSettingSectionData *_sectionData in _toBeDownloadedItems) {
        if ([_sectionData.tag isEqualToString:kDownloadSettingSubSectionDataTag]) {
            NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"isSelected!='1'"];
            NSArray *_subItems = _sectionData.arrayData;
            NSArray *_unselectedSubItems = [_subItems filteredArrayUsingPredicate:_predicate];
            [_subSectionHeaderView selectCheckBox:(_subItems.count>0 && _unselectedSubItems.count<=0)];
            [_subSectionHeaderView setSelectedCount:(_subItems.count-_unselectedSubItems.count) allCount:_subItems.count];
            break;
        }
    }
}

/*
- (void)updateNewsSectionHeader {
    for (SNDownloadSettingSectionData *_sectionData in _toBeDownloadedItems) {
        if ([_sectionData.tag isEqualToString:kDownloadSettingNewsSectionDataTag]) {
            NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"isSelected!='1'"];
            NSArray *_newsItems = _sectionData.arrayData;
            NSArray *_unselectedNewsItems = [_newsItems filteredArrayUsingPredicate:_predicate];
            [_newsSectionHeaderView selectCheckBox:(_newsItems.count>0 && _unselectedNewsItems.count<=0)];
            [_newsSectionHeaderView setSelectedCount:(_newsItems.count-_unselectedNewsItems.count) allCount:_newsItems.count];
            break;
        }
    }
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *_tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([_tableViewCell isKindOfClass:[SNDownloadSettingTableViewCell class]]) {
        SNDownloadSettingTableViewCell *_cell = (SNDownloadSettingTableViewCell *)_tableViewCell;
        [_cell reverseSelectedState];

        [self updateSectionHeaderTriggeredByCell:_cell];
    }
}

#pragma mark - SNDownloadSettingTableViewCellDelegate
- (void)updateSectionHeaderTriggeredByCell:(SNDownloadSettingTableViewCell *)cell {
    if ([cell isKindOfClass:[SNDownloadSettingSubCell class]]) {
        [self updateSubSectionHeader];
    }
//    else if ([cell isKindOfClass:[SNDownloadSettingNewsCell class]]) {
//        [self updateNewsSectionHeader];
//    }
}

#pragma mark - SNDownloadSettingSectionHeaderViewDelegate
- (void)selectAllAtSectionTag:(NSString *)sectionTag {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (SNDownloadSettingSectionData *_oneSectionData in _toBeDownloadedItems) {
            if ([_oneSectionData.tag isEqualToString:sectionTag]) {
                dispatch_apply([_oneSectionData.arrayData count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index){
                    id _obj = [_oneSectionData.arrayData objectAtIndex:index];
                    if ([_obj isKindOfClass:[SCSubscribeObject class]]) {
                        SCSubscribeObject *_sub = (SCSubscribeObject *)_obj;
                        [_sub setIsSelected:kDownloadSettingItemSelected];
                        NSDictionary *_valuePair = [NSDictionary dictionaryWithObject:kDownloadSettingItemSelected forKey:TB_SUB_CENTER_ALL_SUB_ISSELECTED];
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:_sub.subId withValuePairs:_valuePair];
                        
                        //如果是订阅的频道,则既要更新订阅数据库，又要更新频道数据库
                        if(_sub!=nil && _sub.link!=nil)
                        {
                            NSString* channelId = [SNSubDownloadManager channelFromProtocol:_sub.link type:nil];
                            if(channelId!=nil && [channelId length]>0)
                            {
                                NewsChannelItem* _newChannelItem = [[SNDBManager currentDataBase] getChannelById:_sub.link];
                                [[SNDBManager currentDataBase] updateNewsChannelIsSelected:kDownloadSettingItemSelected channelID:_newChannelItem.channelId];
                            }
                        }
                    }
                    /*else if ([_obj isKindOfClass:[NewsChannelItem class]]) {
                        NewsChannelItem *_newsChannelItem = (NewsChannelItem *)_obj;
                        [_newsChannelItem setIsSelected:kDownloadSettingItemSelected];
                        [[SNDBManager currentDataBase] updateNewsChannelIsSelected:kDownloadSettingItemSelected channelID:_newsChannelItem.channelId];
                    }*/
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    [self updateSubSectionHeader];
                });
                break;
            }
        }
    });
}

- (void)unselectAllAtSectionTag:(NSString *)sectionTag {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (SNDownloadSettingSectionData *_oneSectionData in _toBeDownloadedItems) {
            if ([_oneSectionData.tag isEqualToString:sectionTag]) {
                dispatch_apply([_oneSectionData.arrayData count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index){
                    id _obj = [_oneSectionData.arrayData objectAtIndex:index];
                    if ([_obj isKindOfClass:[SCSubscribeObject class]]) {
                        SCSubscribeObject *_sub = (SCSubscribeObject *)_obj;
                        [_sub setIsSelected:kDownloadSettingItemUnselected];
                        NSDictionary *_valuePair = [NSDictionary dictionaryWithObject:kDownloadSettingItemUnselected forKey:TB_SUB_CENTER_ALL_SUB_ISSELECTED];
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:_sub.subId withValuePairs:_valuePair];
                        
                        //如果是订阅的频道,则既要更新订阅数据库，又要更新频道数据库
                        if(_sub!=nil && _sub.link!=nil)
                        {
                            NSString* channelId = [SNSubDownloadManager channelFromProtocol:_sub.link type:nil];
                            if(channelId!=nil && [channelId length]>0)
                            {
                                NewsChannelItem* _newChannelItem = [[SNDBManager currentDataBase] getChannelById:_sub.link];
                                [[SNDBManager currentDataBase] updateNewsChannelIsSelected:kDownloadSettingItemUnselected channelID:_newChannelItem.channelId];
                            }
                        }
                    }
                    /*else if ([_obj isKindOfClass:[NewsChannelItem class]]) {
                        NewsChannelItem *_newsChannelItem = (NewsChannelItem *)_obj;
                        [_newsChannelItem setIsSelected:kDownloadSettingItemUnselected];
                        [[SNDBManager currentDataBase] updateNewsChannelIsSelected:kDownloadSettingItemUnselected channelID:_newsChannelItem.channelId];
                    }*/
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    [self updateSubSectionHeader];
                });
                break;
            }
        }
    });
}

/*
- (void)foldAtSectionTag:(NSString *)sectionTag {
    [self reloadDataWithAnimation:sectionTag];
}

- (void)unfoldAtSectionTag:(NSString *)sectionTag {
    [self reloadDataWithAnimation:sectionTag];
}

- (void)reloadDataWithAnimation:(NSString *)sectionTag {
    if ([kDownloadSettingSubSectionDataTag isEqualToString:sectionTag]) {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if ([kDownloadSettingNewsSectionDataTag isEqualToString:sectionTag]) {
        if ([_tableView numberOfSections] > 1) {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else {
        [_tableView reloadData];
    }
}*/

#pragma mark -

- (void)setDataForCell:(SNDownloadSettingTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < _toBeDownloadedItems.count) {
        SNDownloadSettingSectionData *_oneSectionData = [_toBeDownloadedItems objectAtIndex:indexPath.section];
        if (indexPath.row < _oneSectionData.arrayData.count) {
            [cell setData:[_oneSectionData.arrayData objectAtIndex:indexPath.row]];
            
            SNDownloadSettingCellOrder _order = SNDownloadSettingCellOrder_Unknown;
            if (_oneSectionData.arrayData.count <= 1) {
                _order = SNDownloadSettingCellOrder_OnlyOne;
            } else {
                if (indexPath.row == 0) {//First one
                    _order = SNDownloadSettingCellOrder_First;
                } else if (indexPath.row == (_oneSectionData.arrayData.count-1)) {//Last one
                    _order = SNDownloadSettingCellOrder_Last;
                } else {//Middle ones
                    _order = SNDownloadSettingCellOrder_Middle;
                }
            }
            [cell setOrder:_order];
        }
    }
}

-(NSString*)generateStringFromArray
{
    NSMutableString* str = [NSMutableString stringWithCapacity:0];
    
    if(_toBeDownloadedItemsRow!=nil)
    {
        for(NSInteger i=0; i<[_toBeDownloadedItemsRow count]; i++)
        {
            id object = [_toBeDownloadedItemsRow objectAtIndex:i];
            if([object isKindOfClass:[NewsChannelItem class]])
            {
                NewsChannelItem* item = (NewsChannelItem*)object;
                if([item.isSelected isEqualToString:@"1"])
                    [str appendString:item.channelId];
            }
            else if([object isKindOfClass:[SCSubscribeObject class]])
            {
                SCSubscribeObject* item = (SCSubscribeObject*)object;
                if([item.isSelected isEqualToString:@"1"])
                    [str appendString:item.subId];
            }
        }
    }
    return str;
}
@end
