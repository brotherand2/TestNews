//
//  SNDownloadingViewController.m
//  sohunews
//
//  Created by handy wang on 6/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadingViewController.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadManager.h"
#import "SNDownloadingTableViewCell.h"
#import "SNDownloadViewController.h"

#define SELF_DOWNLOADING_CELL_HEIGHT                                                        (176.0f/2)

#define SELF_EMPTYBG_TOP                                                                    (200/2.0f)
#define SELF_EMPTYBG_WIDTH                                                                  (419/2.0f)
#define SELF_EMPTYBG_HEIGHT                                                                 (175/2.0f)

@interface SNDownloadingViewController ()

- (void)showOrHideEmptyBg;

- (void)showEmptyDownloadingBg;

- (void)hideEmptyDownloadingBg;

@end

@implementation SNDownloadingViewController

- (id)initWithIDelegate:(id)delegateParam {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        _delegate = delegateParam;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showOrHideEmptyBg];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
     //(_emptyDownloadingBg);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
     //(_emptyDownloadingBg);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[SNDownloadManager sharedInstance] downloadingItemsForRender].count;
    SNDebugLog(@"INFO: Downloading tasks count is %d", count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *_reuseIdentifier = @"FKDownloadingTableViewCell";
    SNDownloadingTableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    if (!_cell) {
        _cell = [[SNDownloadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_reuseIdentifier];
    }
    SubscribeHomeMySubscribePO *_po = [[SNDownloadManager sharedInstance].downloadingItemsForRender objectAtIndex:indexPath.row];
//    SNDebugLog(SN_String("INFO: %@--%@, _obj is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _po);
    [_cell setDownloadingItem:_po];
    return _cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SELF_DOWNLOADING_CELL_HEIGHT;
}

#pragma mark - Public methods implementation

- (void)enableOrDisableRightBtn {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[SNDownloadManager sharedInstance] downloadingItemsForRender].count <= 0) {
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

#pragma mark - SNDownloadManagerDelegate

- (void)reloadDownloadingTableView {
    SNDebugLog(@"INFO:%@--%@, Refresh downloading tableview.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    [self.tableView reloadData];
    [self showOrHideEmptyBg];
    
    if ([_delegate respondsToSelector:@selector(enableOrDisableRightBtn)]) {
        [_delegate performSelector:@selector(enableOrDisableRightBtn)];
    }
}

- (void)noTasksToDownload {
    SNDebugLog(@"INFO:%@--%@, There is no tasks to download.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    [self showEmptyDownloadingBg];
}

- (void)didFailedToBatchGetLatestTermId:(NSString *)message {
}

- (void)requestStarted:(SubscribeHomeMySubscribePO *)downloadingItem {
}

- (void)updateProgress:(NSNumber *)progress downloadingItemIndex:(NSNumber *)index {
    SNDebugLog(@"INFO:%@--%@, Updating progress----index:%d, progress:%f.", 
               NSStringFromClass(self.class), NSStringFromSelector(_cmd), [index intValue], [progress floatValue]);
    
    SNDownloadingTableViewCell *_downloadingCell = (SNDownloadingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0]];
    [_downloadingCell updateProgress:progress];
}

- (void)requestFinished:(SubscribeHomeMySubscribePO *)downloadingItem downloadingItemIndex:(NSNumber *)index {
    SNDebugLog(@"INFO:%@--%@, Finish a request.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
    
    SNDownloadingTableViewCell *_downloadingCell = (SNDownloadingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0]];
    [_downloadingCell updateProgress:[NSNumber numberWithInt:1]];
    [_downloadingCell requestFinished];
    [_downloadingCell resetProgessBar];
    [self reloadDownloadingTableView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([_delegate respondsToSelector:@selector(refreshDownloadedList)]) {
        
        [_delegate performSelector:@selector(refreshDownloadedList)];
        
    }
#pragma clang diagnostic pop

}

- (void)requestFailed:(SubscribeHomeMySubscribePO *)downloadingItem error:(NSError *)error {
    SNDebugLog(@"INFO:%@--%@, Failed to download %@ with comming message %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), downloadingItem.subName, error.localizedDescription);
    NSNumber *_index = [[error userInfo] objectForKey:@"downloading_item_index"];
    if (_index) {
        SNDownloadingTableViewCell *_downloadingCell = (SNDownloadingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_index intValue] inSection:0]];
        [_downloadingCell requestFailed];
    }
}

- (void)changeToDownloadStatus:(NSNumber *)statusParam forItemIndex:(NSNumber *)index {
    SNDebugLog(@"INFO: %@--%@, change cell index %d download status to %d. ", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [index intValue], [statusParam intValue]);
    SNDownloadingTableViewCell *_downloadingCell = (SNDownloadingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0]];
    switch ([statusParam intValue]) {
        case SNDownloadWait: {
            [_downloadingCell resetProgessBar];
            break;
        }            
        default:
            break;
    }
}

#pragma mark - Private methods implementation

- (void)showOrHideEmptyBg {
    if ([[SNDownloadManager sharedInstance] downloadingItemsForRender].count <= 0) {
        [self showEmptyDownloadingBg];
    } else {
        [self hideEmptyDownloadingBg];
    }
}

- (void)showEmptyDownloadingBg {
    //空界面
    if (!_emptyDownloadingBg) {
        _emptyDownloadingBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_empty_downloading.png"]];
        _emptyDownloadingBg.center = CGPointMake(TTScreenBounds().size.width/2, SELF_EMPTYBG_TOP+_emptyDownloadingBg.height/2);
        [self.view addSubview:_emptyDownloadingBg];
    }
    _emptyDownloadingBg.hidden = NO;
    
    self.tableView.bounces = NO;
}

- (void)hideEmptyDownloadingBg {
    [_emptyDownloadingBg setHidden:YES];
    self.tableView.bounces = YES;
}
@end
