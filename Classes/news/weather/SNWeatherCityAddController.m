//
//  SNWeatherCityAddController.m
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherCityAddController.h"
#import "SNWeatherCenter.h"
#import "SNWeatherCityAddCell.h"
#import "UIColor+ColorUtils.h"
#import "SNWeatherTopBar.h"
#import "SNToolbar.h"
#import "SNHeadSelectView.h"


#define kWeatherSubedIndex                  (@"★")

@interface SNWeatherCityAddController () {
    UITableView *_tableView;
    NSArray *_cityArray;
    NSMutableDictionary *_citySectionedDic;
    NSMutableArray *_cityIndexArray;
    
    NSMutableDictionary *_cacheSubInfoDic;
    
    SNToolbar *_toolBar;
    SNHeadSelectView *_topBar;
}

@property(nonatomic, strong)NSArray *cityArray;
@property(nonatomic, strong)NSMutableDictionary *citySectionedDic;
@property(nonatomic, strong)NSMutableArray *cityIndexArray;
@property(nonatomic, strong)NSMutableDictionary *cacheSubInfoDic;

- (void)initCitySectionsArray;
- (void)customerTableBg;
- (BOOL)isCitySubed:(NSDictionary *)cityInfo;

@end

@implementation SNWeatherCityAddController
@synthesize cityArray = _cityArray;
@synthesize citySectionedDic = _citySectionedDic;
@synthesize cityIndexArray = _cityIndexArray;
@synthesize cacheSubInfoDic = _cacheSubInfoDic;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
        
        NSArray *cityArr = [[SNWeatherCenter defaultCenter].cityInfo objectForKey:@"cities"];
        self.cityArray = cityArr;
        self.citySectionedDic = [NSMutableDictionary dictionaryWithCapacity:26];
        self.cityIndexArray = [NSMutableArray arrayWithCapacity:26];
        [self initCitySectionsArray];
        
        [SNNotificationManager addObserver:self selector:@selector(handleWeatherCitiesDidChangeNotification:) name:kWeatherCitiesDidChangeNotify object:nil];
    }
	
    return self;
}

- (SNCCPVPage)currentPage {
    return city_setting;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
     //(_tableView);
     //(_cityArray);
     //(_citySectionedDic);
     //(_cityIndexArray);
     //(_toolBar);
     //(_topBar);
     //(_cacheSubInfoDic);
}

- (void)loadView {
    [super loadView];
    _topBar = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderTotalHeight)];
    NSString *title = @"添加城市";
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    _topBar.sections = [NSArray arrayWithObject:title];
    [self.view addSubview:_topBar];
    [_topBar setBottomLineForHeaderView:CGRectMake(7, _topBar.height-2, titleSize.width+6, 2)];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeadSelectViewBottom, self.view.width, kAppScreenHeight - kHeadSelectViewBottom - kToolbarViewTop) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, kToolbarHeightWithoutShadow, 0.f);
        _tableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
    }
    
    [self.view insertSubview:_tableView belowSubview:_topBar];
    [self customerTableBg];
    
    CGRect toolBarFrame = CGRectMake(0, kAppScreenHeight - kToolbarHeight, self.view.width, kToolbarHeight);
    _toolBar = [[SNToolbar alloc] initWithFrame:toolBarFrame];
    _toolBar.backgroundColor = [UIColor clearColor];
    [_toolBar setBackgroundImage:[UIImage themeImageNamed:@"postTab0.png"]];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40.5, 40.5)];
    [leftBtn setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    _toolBar.leftButton = leftBtn;
    
    [self.view addSubview:_toolBar];
}

- (void)back:(id)sender {
    [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
     //(_tableView);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cacheSubInfoDic = [NSMutableDictionary dictionary];
    for (NSDictionary *cityInfo in [[SNWeatherCenter defaultCenter] subedCitiesArray]) {
        NSString *gbcode = [cityInfo objectForKey:@"gbcode"];
        [_cacheSubInfoDic setObject:cityInfo forKey:gbcode];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

#pragma mark - actions
- (void)handleWeatherCitiesDidChangeNotification:(id)sender {
    self.cacheSubInfoDic = [NSMutableDictionary dictionary];
    for (NSDictionary *cityInfo in [[SNWeatherCenter defaultCenter] subedCitiesArray]) {
        NSString *gbcode = [cityInfo objectForKey:@"gbcode"];
        [_cacheSubInfoDic setObject:cityInfo forKey:gbcode];
    }
}

#pragma mark - private methods
- (void)initCitySectionsArray {
    if (_cityArray.count > 0) {
        for (NSDictionary *cityInfo in _cityArray) {
            NSString *indexKey = [cityInfo objectForKey:@"index"];
            NSMutableArray *section = [_citySectionedDic objectForKey:indexKey];
            if (nil == section) {
                section = [NSMutableArray array];
                [_citySectionedDic setObject:section forKey:indexKey];
                [_cityIndexArray addObject:indexKey];
            }
            
            [section addObject:cityInfo];
        }
    }
}

- (NSDictionary *)cityInfoDicByIndexpath:(NSIndexPath *)indexPath {
    NSString *indexKey = [_cityIndexArray objectAtIndex:[indexPath section]];
    NSArray *cityArr = [_citySectionedDic objectForKey:indexKey];
    return [cityArr objectAtIndex:[indexPath row]];
}

- (BOOL)isCitySubed:(NSDictionary *)cityInfo {
    NSString *gbcode = [cityInfo objectForKey:@"gbcode"];
    return [_cacheSubInfoDic objectForKey:gbcode] != nil;
}

- (void)customerTableBg {

    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cityIndexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *indexKey = [_cityIndexArray objectAtIndex:section];
    return [[_citySectionedDic objectForKey:indexKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNWeatherCityAddCell *cell = nil;
    static NSString *cellIdentifier = @"cityCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[SNWeatherCityAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.editBtn.hidden = YES;
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    NSDictionary *cityInfoDic = [self cityInfoDicByIndexpath:indexPath];
    cell.textLabel.text = [cityInfoDic objectForKey:@"city"];
    cell.cityInfoDic = cityInfoDic;
    return cell;
}

//索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.cityIndexArray;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_cacheSubInfoDic.count >= kWeatherCityMaxNum) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:@"您最多只能添加%d个城市", kWeatherCityMaxNum] toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    NSDictionary *selectiCityInfo  = [self cityInfoDicByIndexpath:indexPath];
    if ([self isCitySubed:selectiCityInfo]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:@"您已添加%@", [selectiCityInfo objectForKey:@"city"]] toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    NSString *gbcode = [selectiCityInfo objectForKey:@"gbcode"];
    [[SNWeatherCenter defaultCenter] appendSubCityByGbcode:gbcode];
    [_cacheSubInfoDic setObject:selectiCityInfo forKey:gbcode];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"添加成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.view.width - 30, 50)];
    header.text = [_cityIndexArray objectAtIndex:section];
    header.backgroundColor = [UIColor clearColor];

    header.textColor= [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagNormalTextColor]];
    [headView addSubview:header];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

#pragma mark - SNWeatherCityAddCell delegate

- (void)delAction:(SNWeatherCityAddCell *)cell {
    NSDictionary *cityInfo = cell.cityInfoDic;
    NSString *gbcode = [cityInfo objectForKey:@"gbcode"];
    [[SNWeatherCenter defaultCenter] removeSubCityByGbcode:gbcode];
    [_cacheSubInfoDic removeObjectForKey:gbcode];
}

- (void)addAction:(SNWeatherCityAddCell *)cell {
    if (_cacheSubInfoDic.count >= kWeatherCityMaxNum) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:@"您最多只能添加%d个城市", kWeatherCityMaxNum] toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    NSDictionary *cityInfo = cell.cityInfoDic;
    NSString *gbcode = [cityInfo objectForKey:@"gbcode"];
    [[SNWeatherCenter defaultCenter] appendSubCityByGbcode:gbcode];
    [_cacheSubInfoDic setObject:cityInfo forKey:gbcode];
}

@end
