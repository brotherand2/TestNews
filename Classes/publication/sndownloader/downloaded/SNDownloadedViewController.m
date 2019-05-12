//
//  SNDownloadedViewController.m
//  sohunews
//
//  Created by handy wang on 6/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadedViewController.h"
#import "SNDBManager.h"
#import "CacheObjects.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadedTableViewCell.h"
#import "SNSubDownloadManager.h"

#import "SNNewAlertView.h"
#import "SNMySDK.h"

#define SELF_DOWNLOADING_CELL_HEIGHT                                                        (176.0f/2)

#define SELF_EMPTYBG_TOP                                                                    (200/2.0f)
#define SELF_EMPTYBG_WIDTH                                                                  (419/2.0f)
#define SELF_EMPTYBG_HEIGHT                                                                 (175/2.0f)
#define SELF_EMPTYBG_TAG                                                                    (1)

#define SELF_ROW_HEIGHT                                                                     (110.0 / 2)

#define SELF_DELETE_ALERTVIEW_TAG                                                           (2)
#define SELF_kSELECTEDITEMS                                                                 (@"SELF_kSELECTEDITEMS")

@interface SNDownloadedViewController ()

- (void)showLoadingOverlay;

- (void)hideLoadingOverlay;

- (void)doLoadLocalDownloadedDataFromDB;

- (void)didFinishLoadLocalDownloadedDataFromDB;

- (void)showOrHideEmptyBg;

- (void)showEmptyDownloadedBg;

- (void)hideEmptyDownloadedBg;

- (void)doDeleteSelected:(NSArray *)selectedItemsParam;

- (void)finishDeleteSelected;

@end

@implementation SNDownloadedViewController

@synthesize isEditMode = _isEditMode;
@synthesize bottomMenu = _bottomMenu;
@synthesize referFrom = _referFrom;

- (id)initWithIDelegate:(id)delegateParam {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _delegate = delegateParam;
        
        _localDownloadedData = [[NSMutableArray alloc] init];
        
        _selectNum = 0;
    }
    return self;
}

- (void)dealloc {
    
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
    [SNNotificationManager removeObserver:self  name:kThemeDidChangeNotification object:nil];
    _localDownloadedData = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SNNotificationManager addObserver:self selector:@selector(pushNotificationWillCome) name:kNotifyDidReceive object:nil];
    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    
    [self loadLocalDownloadedDataFromDB];    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateTheme
{
    self.tableView.backgroundView = nil;
    NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    self.tableView.backgroundColor = [UIColor colorFromString:backgroundColor];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_localDownloadedData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"downloadedCell";
    SNDownloadedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[SNDownloadedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    @synchronized(_localDownloadedData) {
        NewspaperItem *_tmpPO = [_localDownloadedData objectAtIndex:indexPath.row];
        [cell setNewspaperItem:_tmpPO];
        cell.textLabel.text = _tmpPO.termName;
    }
    cell.tableViewCellDelegate = self;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
	return SELF_ROW_HEIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEditMode) {
        return;
    }
    
    //[_delegate setReferOfDownloader:FKDownloadListViewDownloadedMode];
    
    id curCell = [tableView cellForRowAtIndexPath:indexPath];
	if ([curCell isKindOfClass:[SNDownloadedTableViewCell class]]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
        
		NewspaperItem *item = nil;
        @synchronized(_localDownloadedData) {
            item = [_localDownloadedData objectAtIndex:indexPath.row];
        }
        
		if (item && 0 == [item.readFlag intValue]) {
			item.readFlag = [NSString stringWithFormat:@"%d", 1];
			NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
			[tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
			            
            if (item && item.subId && ![@"" isEqualToString:item.subId]) {
                //更新
                //TODO: need check
                SCSubscribeObject *subscribeObjec = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:item.subId];
                int status = [subscribeObjec statusValueWithFlag:SCSubObjStatusFlagSubStatus];
                if (status == [KHAD_BEEN_OFFLINE intValue]) {
                    NSMutableDictionary *_dic = [[NSMutableDictionary alloc] init];
                    [_dic setObject:kNO_NEW_TERM forKey:@"status"];
                    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:item.subId withValuePairs:_dic];
                }
            }
		}
		if (item) {
            SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:item.subId];
            if (subObj) {
                item.termName = subObj.subName;
            }
            
            NSMutableDictionary *userInfo = nil;
			NSString *linkType = @"LOCAL";
            userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:item forKey:@"subitem"];

            if (userInfo) {
                SNDebugLog(@"INFO: link type is %@", linkType);
                [userInfo setObject:[NSString stringWithFormat:@"%@subId=%@&termId=%@", kProtocolSubHome, item.subId, item.termId]
                             forKey:kOpenProtocolOriginalLink2];
                [userInfo setObject:@"0" forKey:@"navigateFromWangqi"];
                [userInfo setObject:linkType forKey:@"linkType"];
                [userInfo setObject:@(YES) forKey:kISOffReadingPublication];
			}
#pragma mark - huangjing   //离线跳转到我的SDK的profile页
            if (userInfo) {
                SNDebugLog(@"INFO: link type is %@", linkType);
                [SNSLib pushToProfileViewControllerWithDictionary:@{
                                                                    @"type":kProtocolSubHome,
                                                                    @"protocolLink2":[NSString stringWithFormat:@"%@subId=%@&termId=%@", kProtocolSubHome, item.subId, item.termId],
                                                                    @"offLine":@YES,
                                                                    @"fromPush":@"0"
                                                                    }];
                
                [[SNMySDK sharedInstance] updateAppTheme];
            }
#pragma mark - end
		}
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}




#pragma mark - Public methods implementation

- (void)cellDidTap:(id)sender
{
    SNDownloadedTableViewCell *cell = (SNDownloadedTableViewCell *)sender;
    if (cell.newspaperItem.isSelected) {
        _selectNum++;
    } else {
        _selectNum--;
    }
    if (_selectNum >= _localDownloadedData.count) {
        _selectNum = _localDownloadedData.count;
        [_bottomMenu setSelectAllButtonState:NO];
    } else {
        if (_selectNum < 0 ) {
            _selectNum = 0;
        }
        [_bottomMenu setSelectAllButtonState:YES];
    }
    
}

- (void)reloadDownloadedTableView {
    SNDebugLog(@"INFO:%@--%@, Refresh downloading tableview.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    [self.tableView reloadData];
    [self showOrHideEmptyBg];
    
    if ([_delegate respondsToSelector:@selector(enableOrDisableRightBtn)]) {
        [_delegate performSelector:@selector(enableOrDisableRightBtn)];
    }
}

- (void)setIsEditMode:(BOOL)isEditModeParam {
    _isEditMode = isEditModeParam;
    if (_isEditMode) {
        //begin edit
        for (NewspaperItem *_po in _localDownloadedData) {
            _po.isEditMode = YES;
            _po.isSelected = NO;
        }
        
        //Iterate visible cells and begin edit
        for (SNDownloadedTableViewCell *_cell in self.tableView.visibleCells) {
            [_cell beginEditMode];
        }
    } else {
        //end edit
        for (NewspaperItem *_po in _localDownloadedData) {
            _po.isEditMode = NO;
            _po.isSelected = NO;
        }
        
        //Iterate visible cells and end edit
        for (SNDownloadedTableViewCell *_cell in self.tableView.visibleCells) {
            [_cell endEditMode];
        }
    }
}

- (void)selectAll {
    for (NewspaperItem *_po in _localDownloadedData) {
        _po.isSelected = YES;
    }
    
    //Iterate visible cells and select it
    for (SNDownloadedTableViewCell *_cell in self.tableView.visibleCells) {
        [_cell selectIt];
    }
    _selectNum = _localDownloadedData.count;
}

- (void)deselectAll {
    for (NewspaperItem *_po in _localDownloadedData) {
        _po.isSelected = NO;
    }
    
    //Iterate visible cells and select it
    for (SNDownloadedTableViewCell *_cell in self.tableView.visibleCells) {
        [_cell deselectIt];
    }
    _selectNum = 0;
}

- (void)deleteSelected {
    NSMutableArray *_selectedItems = [[NSMutableArray alloc] init];
    for (NewspaperItem *_item in _localDownloadedData) {
        if (_item.isSelected) {
            [_selectedItems addObject:_item];
        }
    }
    
    if (_selectedItems && _selectedItems.count <= 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"pls select at least one", @"") toUrl:nil mode:SNCenterToastModeOnlyText];
    } else {

        SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Confirm delete selected items", @"") cancelButtonTitle:NSLocalizedString(@"del subscribe", @"") otherButtonTitle:NSLocalizedString(@"Confirm", @"")];
        [alert show];// 解决删除离线刊物无弹窗
        [alert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
            [SNNotificationCenter showLoadingAndBlockOtherActions:NSLocalizedString(@"Please wait",@"")];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self doDeleteSelected:_selectedItems];
            });

        }];
        
    }
    _selectedItems = nil;
}

- (void)enableOrDisableRightBtn {
    if (_localDownloadedData.count <= 0) {
        if ([_delegate respondsToSelector:@selector(disableRightBtn)]) {
            [_delegate performSelector:@selector(disableRightBtn)];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(enableRightBtn)]) {
            [_delegate performSelector:@selector(enableRightBtn)];
        }
    }
}

//This ensures that the release method of my view controller class is always executed on the main thread in multithread environment.
//- (oneway void)release
//{
//    if (![NSThread isMainThread]) {
//        [self performSelectorOnMainThread:@selector(release) withObject:nil waitUntilDone:NO];
//    } else {
//        [super release];
//    }
//}

#pragma mark -
#pragma mark SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == SELF_DELETE_ALERTVIEW_TAG) {
        if (buttonIndex == 1) {
            [SNNotificationCenter showLoadingAndBlockOtherActions:NSLocalizedString(@"Please wait",@"")];
            
            if (actionSheet.userInfo && actionSheet.userInfo.count > 0) {
                NSMutableArray *_selectedItems = [actionSheet.userInfo objectForKey:SELF_kSELECTEDITEMS];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self doDeleteSelected:_selectedItems];
                });
            }
        }
    }
}

#pragma mark - Private methods implementation

- (void)showLoadingOverlay {
    
    if (_localDownloadedData.count > 0) {
    
        return;
    
    }
    
    SNDebugLog(@"INFO: %@--%@, Show loading overlay......", NSStringFromClass(self.class), NSStringFromSelector(_cmd));

    if (!_loadingOverlay) {
    
        _loadingOverlay = [[SNLoadingOverlay alloc] initWithFrame:self.view.bounds];
        
        _loadingOverlay.hidden = YES;
        
        [self.view addSubview:_loadingOverlay];
    
    }
    
    _loadingOverlay.hidden = NO;

}

- (void)hideLoadingOverlay {
    
    _loadingOverlay.hidden = YES;
    
    SNDebugLog(@"INFO: %@--%@, Hide loading overlay......", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
}

- (void)loadLocalDownloadedDataFromDB {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doLoadLocalDownloadedDataFromDB];
    });
}

- (void)doLoadLocalDownloadedDataFromDB {
    @autoreleasepool {
        @synchronized(_localDownloadedData) {
            [_localDownloadedData removeAllObjects];
            [_localDownloadedData addObjectsFromArray:[NSMutableArray arrayWithArray:[[SNDBManager currentDataBase] getNewspaperDownloadedList]]];
            
            /*NSArray* toBeDownloadedSubItems = [[SNDBManager currentDataBase] getSubscribeCenterSelectedUndownloadedMySubList];
             NSArray* newsItems = [SNSubDownloadManager generaNewsObjArrayFromSubObjArray:toBeDownloadedSubItems];
             for(NewsChannelItem* newsItem in newsItems)
             if(newsItem!=nil && newsItem.downloadStatus==SNDownloadSuccess) [_localDownloadedData addObject:newsItem];*/
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didFinishLoadLocalDownloadedDataFromDB];
        });
    }
}

- (void)didFinishLoadLocalDownloadedDataFromDB {
    
    [self reloadDownloadedTableView];   
    
    [self hideLoadingOverlay];
}

- (void)showOrHideEmptyBg {
    if (_localDownloadedData.count <= 0) {
        [self showEmptyDownloadedBg];
        SNDebugLog(@"INFO: ++++++++++++++++++++ showed empty downloaded bg.........");
    } else {
        [self hideEmptyDownloadedBg];
    }
}

- (void)showEmptyDownloadedBg {
    
    UIImageView *_emptyDownloadingBg = (UIImageView *)[self.view viewWithTag:SELF_EMPTYBG_TAG];
    if (!_emptyDownloadingBg) {
        _emptyDownloadingBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_empty_downloading.png"]];
        _emptyDownloadingBg.center = CGPointMake(self.view.center.x, SELF_EMPTYBG_TOP+_emptyDownloadingBg.height/2);
        _emptyDownloadingBg.tag = SELF_EMPTYBG_TAG;
        [self.view addSubview:_emptyDownloadingBg];
        _emptyDownloadingBg = nil;
    }
    _emptyDownloadingBg.hidden = NO;    
    self.tableView.bounces = NO;
}

- (void)hideEmptyDownloadedBg {
    
    [(UIImageView *)[self.view viewWithTag:SELF_EMPTYBG_TAG] setHidden:YES];
    self.tableView.bounces = YES;
}


- (void)doDeleteSelected:(NSMutableArray *)selectedItemsParam {
    @autoreleasepool {
        
#if USE_NEW_SUBCENTER
#else
        NSMutableArray *_selectedIDs = [[NSMutableArray alloc] init];
#endif
        
        @synchronized(selectedItemsParam) {
            //删除已下载数据以及更新我的订阅里对应数据的downloaded状态为kNOT_DOWNLOADED
            for (NewspaperItem *_downloadedItem in selectedItemsParam) {
#if USE_NEW_SUBCENTER
                SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_downloadedItem.subId];
                
                [[SNDBManager currentDataBase] deleteNewspaperByTermId:_downloadedItem.termId deleteFromTable:YES];
                
                subObj.isDownloaded = kNOT_DOWNLOADED;
                [subObj setStatusValue:[kNO_NEW_TERM intValue] forFlag:SCSubObjStatusFlagSubStatus];
                
                if (subObj.subId) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                    if (subObj.status) {
                        [dict setObject:subObj.status forKey:TB_SUB_CENTER_ALL_SUB_STATUS];
                    }
                    if (subObj.isDownloaded) {
                        [dict setObject:subObj.isDownloaded forKey:TB_SUB_CENTER_ALL_SUB_IS_DOWNLOADED];
                    }
                    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:subObj.subId withValuePairs:dict];
                }
#else
                SubscribeHomeMySubscribePO *_mySubPO = [[SNDBManager currentDataBase] getSubHomeMySubscribeBySubId:_downloadedItem.subId];
                
                if (_downloadedItem.subId && ![@"" isEqualToString:_downloadedItem.subId] && ![kHAVE_NEW_TERM isEqualToString:_mySubPO.status]) {
                    [_selectedIDs addObject:_downloadedItem.subId];
                }
                
                [[SNDBManager currentDataBase] deleteNewspaperByTermId:_downloadedItem.termId deleteFromTable:YES];
                
                //更新离线数据在我的订阅里的download状态为未下载，status状态为0；
                NSMutableDictionary *_dic = [[NSMutableDictionary alloc] init];
                [_dic setObject:kNOT_DOWNLOADED forKey:@"downloaded"];
                [_dic setObject:kNO_NEW_TERM forKey:@"status"];
                [[SNDBManager currentDataBase] updateSubHomeMySubscribePOBySubId:_downloadedItem.subId withValuePairs:_dic];
                 //(_dic);
#endif
            }
            
            //去掉我的订阅LauncherView中对应item的已下载样式；
#if USE_NEW_SUBCENTER
            // 使用kSubscribeCenterMySubDidChangedNotify代替多次发kSubscribeObjectStatusChangedNotification
            [SNNotificationManager postNotificationName:kSubscribeCenterMySubDidChangedNotify object:nil userInfo:nil];
#else
            if (selectedItemsParam.count > 0 && [[SNUtility getApplicationDelegate].subHomeController respondsToSelector:@selector(resetMySubLauncherItemDownloadedStyle:)]) {
                [[SNUtility getApplicationDelegate].subHomeController performSelectorOnMainThread:@selector(resetMySubLauncherItemDownloadedStyle:)
                                                                                       withObject:_selectedIDs waitUntilDone:NO
                 ];
            }
            [_selectedIDs release];
            _selectedIDs = nil;
#endif
            
            @synchronized(_localDownloadedData) {
                NSMutableArray *_tmpLocalDownloadData = [_localDownloadedData mutableCopy];
                for (NewspaperItem *_downloadedItem_A in selectedItemsParam) {
                    for (NewspaperItem *_downloadedItem_B in _tmpLocalDownloadData) {
                        if ([_downloadedItem_A.termId isEqualToString:_downloadedItem_B.termId]) {
                            [_localDownloadedData removeObject:_downloadedItem_B];
                        }
                    }
                }
                 //(_tmpLocalDownloadData);
                [selectedItemsParam removeAllObjects];
            }
            
        }
        
        _selectNum = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishDeleteSelected];
        });
    }
}

- (void)finishDeleteSelected {
    [self reloadDownloadedTableView];
    
    [SNNotificationCenter hideLoadingAndBlock];	
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"Finish clear up",@"") toUrl:nil mode:SNCenterToastModeSuccess];
    
    if ([_delegate respondsToSelector:@selector(doneAction)]) {
        [_delegate performSelector:@selector(doneAction)];
    }
}

- (void)pushNotificationWillCome {
    
    if (_confirmAlertView) {
    
        [_confirmAlertView dismissWithClickedButtonIndex:0 animated:NO];
    
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
