 //
//  SNCgWangQiController.m
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNHistoryController.h"
#import "SNDBManager.h"
#import "SNHistoryDataSource.h"
#import "SNTabBarController.h"
#import "SNHistoryDelegate.h"
#import "SNHistoryModel.h"
#import "SNAlert.h"
#import "SNPaperItem.h"
#import "CacheObjects.h"
#import "SNTableErrorView.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"

#define kErrorViewTag     (100000)
#define kEmptyViewTag     (100001)
#define kAlertTitle       (@"清理")

@implementation SNHistoryController
@synthesize customEmptyView = _customEmptyView;
@synthesize delegateHistory = _delegateHistory;
@synthesize historyMode = _historyMode;
@synthesize paperItem = _paperItem;
@synthesize linkType = _linkType;
@synthesize isErrorView = _isErrorView;
@synthesize pubIDsForWangQiAction = _pubIDsForWangQiAction;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        _historyMode = MANAGEMENT_MODE_WANGQI;
        self.paperItem = [query objectForKey:@"paperitem"];
		self.linkType = [query objectForKey:@"linkType"];
        _pubIDsForWangQiAction = [[query objectForKey:kPubIDsForWangQiAction] copy];
    }
	
    return self;
}

- (SNCCPVPage)currentPage {
    return paper_history;
}

- (void)createModel
{
    [self createDelegate];
    SNHistoryDataSource *dataSource = [[SNHistoryDataSource alloc] init];
    dataSource.modelHistory.controller = self;
    [_delegateHistory setModel:dataSource.modelHistory];
    self.dataSource = dataSource;
     dataSource = nil;
}

- (id<TTTableViewDelegate>)createDelegate 
{
    if (!_delegateHistory)
    {
        SNHistoryDelegate *delegateHis = [[SNHistoryDelegate alloc] initWithController:self];
        if (MANAGEMENT_MODE_LOCAL == _historyMode) {
            //[delegateHis removeRefreshElmentOfHeaderView];
        }
        else{
           [self resetTableDelegate:delegateHis]; 
        }
        self.delegateHistory = delegateHis;
         delegateHis = nil; 
    }
	return (id)_delegateHistory;
}

-(void)customerTableBg
{
    self.tableView.backgroundView = nil;
    NSString *bg = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    self.tableView.backgroundColor = [UIColor colorFromString:bg];
    self.view.backgroundColor = [UIColor colorFromString:bg];
}

-(void)loadView
{
	[super loadView];
    
    self.isErrorView = YES;
    [self addHeaderView];
    self.tableView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight - kHeadSelectViewBottom - kToolbarViewTop);
    
    if (MANAGEMENT_MODE_LOCAL == _historyMode) {
        self.linkType = @"HISTORYLIST";
        self.headerView.sections = [NSArray arrayWithObject:NSLocalizedString(@"localPaper", @"")];

        NSArray *downloadPapers = [[SNDBManager currentDataBase] getNewspaperDownloadedList];
        if (downloadPapers.count == 0) {
            [self showEmptyNewsBg];
        }

    }
    else
    {
        self.linkType = @"SUBLIST";
         self.headerView.sections = [NSArray arrayWithObject:NSLocalizedString(@"paper wangqi", @"")];
    }
    
    [self customerTableBg];
    
    
    [self addToolbar];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        UIView *bottomView  = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kAppScreenWidth, kToolbarViewHeight)];
        bottomView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = bottomView;
    }
}

- (void)showEmptyNewsBg
{
    self.tableView.bounces = NO; 
    NSString *name = @"empty.png";
    UIImage *imgEmpty = [UIImage  imageNamed:name];
    UIImageView *imgViewEmpty = [[UIImageView alloc] initWithImage:imgEmpty];
    imgViewEmpty.frame = CGRectMake((320-imgEmpty.size.width)/2,100,imgEmpty.size.width,imgEmpty.size.height);
    imgViewEmpty.tag = 100;
    [self.view addSubview:imgViewEmpty];
    imgViewEmpty = nil;
}

- (void)doDownNews:(id)sender{
    [self.tabBarController setSelectedIndex:0];
    [self.flipboardNavigationController  popViewControllerAnimated:NO];
}

#pragma mark -
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight - kHeadSelectViewBottom - kToolbarViewTop);
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    NSArray *downloadPapers = [[SNDBManager currentDataBase] getNewspaperDownloadedList];
    if (downloadPapers.count > 0) {
        UIImageView *imageViewEmty = (UIImageView*)[self.view viewWithTag:100];
        if (imageViewEmty) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.tableView.bounces = YES;
            [imageViewEmty removeFromSuperview];
        }
        if (MANAGEMENT_MODE_LOCAL == _historyMode) {
            [((SNHistoryDataSource *)self.dataSource).modelHistory.wangqiArray removeAllObjects];
            for (NewspaperItem *newPaper  in downloadPapers) {
                [((SNHistoryDataSource *)self.dataSource).modelHistory.wangqiArray addObject:newPaper];
            }
        }
    }
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)showEmpty:(BOOL)show 
{
  if (MANAGEMENT_MODE_LOCAL == _historyMode) 
    {
         _tableView.dataSource = nil;
         [_tableView reloadData]; 
    }
    else if (MANAGEMENT_MODE_WANGQI == _historyMode)
    {
        if (show) {
            if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                NSString* title = [_dataSource titleForEmpty];
                NSString* subtitle = [_dataSource subtitleForEmpty];
                UIImage* image = [_dataSource imageForEmpty];
                if (title.length || subtitle.length || image) {
                    SNTableErrorView *lastErrorView = (SNTableErrorView *)[self.tableView viewWithTag:kEmptyViewTag];
                    if (lastErrorView) {
                        [lastErrorView removeFromSuperview];
                    }
                    
                    SNTableErrorView *errorView = [[SNTableErrorView alloc] initWithTitle:title
                                                                                 subtitle:subtitle
                                                                                    image:image];
                    
                        errorView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];

                    errorView.frame = TTScreenBounds();
                    errorView.tag = kEmptyViewTag;
                    [self.tableView addSubview:errorView];
                    if (_isErrorView) {
                        _isErrorView = !_isErrorView;
                    }
                }
                _tableView.dataSource = nil;
                [_tableView reloadData];
            } 
            else {
                [self showError:YES];
            }
        } 
        else {
            SNTableErrorView *emptyView = (SNTableErrorView *)[self.tableView viewWithTag:kEmptyViewTag]; 
            if (emptyView && _isErrorView) {
                [emptyView removeFromSuperview];
            }
            [self showError:NO];
        }
    }
}

- (void)showError:(BOOL)show 
{
    if (MANAGEMENT_MODE_WANGQI == _historyMode)
    {
        [super showError:show];
    }
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)updateTheme:(NSNotification *)notifiction {
    self.tableView.backgroundView = nil;
    NSString *backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor];
    self.tableView.backgroundColor = [UIColor colorFromString:backgroundColor];
    self.view.backgroundColor = [UIColor colorFromString:backgroundColor];
    [_headerView updateTheme];
    [_tableView reloadData];
    
    UIImage *bg = [UIImage themeImageNamed:@"postTab0.png"];
    [_toolbarView setBackgroundImage:bg];
    
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    
     //(_pubIDsForWangQiAction);
    
}
@end
