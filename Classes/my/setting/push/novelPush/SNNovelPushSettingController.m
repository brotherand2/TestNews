//
//  SNNovelPushSettingController.m
//  sohunews
//
//  Created by H on 2016/11/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNovelPushSettingController.h"
#import "SNPushSettingTableCell.h"
#import "SNNovelPushSettingDelegate.h"
#import "SNNovelPushSettingDataSource.h"
#import "SNPushSettingModel.h"

@interface SNNovelPushSettingController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, retain) SNHeadSelectView   *headerView;
@property(nonatomic, retain) SNToolbar          *toolbarView;

@end

@implementation SNNovelPushSettingController

- (void)loadView {
    [super loadView];
    
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.tableView.backgroundColor = color;
    self.view.backgroundColor = color;
    [self customerTableBg];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenHeight, kAppScreenHeight-kHeadSelectViewBottom-kToolbarViewTop);
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
    [self.tableView setSeparatorColor:grayColor];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0, kToolbarHeightWithoutShadow, 0);
    self.tableView.contentOffset = CGPointMake(0, -kHeaderHeightWithoutBottom);
    
    [self addHeaderView];
    [self addToolbar];
    
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Push Novel setting",@"")]];
    CGSize titleSize = [NSLocalizedString(@"Push Novel setting",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.contentInset = UIEdgeInsetsMake(10 + kHeaderHeightWithoutBottom, 0, kToolbarHeightWithoutShadow, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(10 + kHeadSelectViewBottom, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -20 - kHeaderHeightWithoutBottom);
    self.tableView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight - kHeadSelectViewBottom - kToolbarViewTop);
}

-(void)customerTableBg {
    self.tableView.backgroundView = nil;
    UIColor *color = SNUICOLOR(kBackgroundColor);
    self.tableView.backgroundColor = color;
    self.view.backgroundColor = color;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SNNotificationManager addObserver:self selector:@selector(switchChange) name:NovelPushSwtichNotification object:nil];
}
- (void)addHeaderView {
    _headerView = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kHeaderTotalHeight)];
    [self.view addSubview:_headerView];
}

- (void)addToolbar {
    _toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.accessibilityLabel = @"返回";
    [_toolbarView setLeftButton:leftButton];
    [self.view addSubview:_toolbarView];
}

- (void)onBack:(id)sender {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)createModel{
    [SNPushSettingModel instance].novelSettingController = self;
    SNNovelPushSettingDataSource *dataSource = [[SNNovelPushSettingDataSource alloc] init];
    self.dataSource = dataSource;
    dataSource.pushViewController=self;
}

- (id)createDelegate {
    SNNovelPushSettingDelegate *delegate = [[SNNovelPushSettingDelegate alloc] initWithController:self];
    return delegate;
}

-(void)switchChange
{
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.headerView = nil;
    self.toolbarView = nil;
    [SNNotificationManager removeObserver:self name:NovelPushSwtichNotification object:nil];
}
- (void)updateTheme {
    [_headerView updateTheme];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [_toolbarView.leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *novelSwitch = [userDefault objectForKey:kReaderPushSet];
        if (![novelSwitch isEqualToString:@"1"]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请先打开小说推送总开关" toUrl:nil mode:SNCenterToastModeError];
        }
    }
}
@end
