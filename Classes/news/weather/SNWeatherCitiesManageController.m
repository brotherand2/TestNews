//
//  SNWeatherCitiesManageController.m
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherCitiesManageController.h"
#import "SNWeatherCenter.h"
#import "UIColor+ColorUtils.h"
#import "SNWeatherCitiesManageCell.h"
#import "SNWeatherTopBar.h"
#import "SNToolbar.h"
#import "SNHeadSelectView.h"


@interface SNWeatherCitiesManageController () {
    UITableView *_tableView;
    NSMutableArray *_cities;
    
    SNToolbar *_toolBar;
    SNHeadSelectView *_topBar;
}
@property(nonatomic, strong)NSMutableArray *cities;

- (void)darkerAllCellsForNight;

@end

@implementation SNWeatherCitiesManageController
@synthesize cities = _cities;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        self.hidesBottomBarWhenPushed = YES;
    }
	
    return self;
}

- (SNCCPVPage)currentPage {
    return city_manager;
}

- (void)dealloc {
     //(_tableView);
     //(_cities);
     //(_toolBar);
     //(_topBar);
}

- (void)customerTableBg {

    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];

}

- (void)loadView {
    [super loadView];
    
    _topBar = [[SNHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderTotalHeight)];
    _topBar.sections = [NSArray arrayWithObject:@"城市设置"];
    [self.view addSubview:_topBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeadSelectViewBottom, self.view.width, kAppScreenHeight - kHeadSelectViewBottom) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(kHeadBottomHeight, 0, 0, 0);
    [self.view insertSubview:_tableView belowSubview:_topBar];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        _tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, 0.f, 0.f);
        _tableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
    }
        
    CGRect toolBarFrame = CGRectMake(0, kAppScreenHeight - kToolbarHeight, self.view.width, kToolbarHeight);
    _toolBar = [[SNToolbar alloc] initWithFrame:toolBarFrame];
    _toolBar.backgroundColor = [UIColor clearColor];
    [_toolBar setBackgroundImage:[UIImage themeImageNamed:@"postTab0.png"]];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40.5, 40.5)];
    [leftBtn setImage:[UIImage themeImageNamed:@"weather_back.png"] forState:UIControlStateNormal];
//    [leftBtn setImage:[UIImage themeImageNamed:@"weather_back_p.png"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    _toolBar.leftButton = leftBtn;
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40.5, 40.5)];
    [rightBtn setImage:[UIImage themeImageNamed:@"tb_add.png"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage themeImageNamed:@"tb_add_p.png"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    _toolBar.rightButton = rightBtn;
    
    [self.view addSubview:_toolBar];
    
    [self customerTableBg];
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
    NSArray *cityArr = [[SNWeatherCenter defaultCenter] subedCitiesArray];
    self.cities = [NSMutableArray array];
    if (cityArr && cityArr.count > 0) {
        [self.cities addObjectsFromArray:cityArr];
    }
    [_tableView reloadData];
    [_tableView setEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)viewWillDisappear:(BOOL)animated {
//    [_tableView endUpdates];
    [super viewWillDisappear:animated];
    [_tableView setEditing:NO];
    [[SNWeatherCenter defaultCenter] setSubedCitiesArray:_cities];
    [SNNotificationManager postNotificationName:kWeatherCitiesDidChangeNotify object:nil];
}

- (void)back:(id)sender {
    [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)add:(id)sender {
    TTURLAction *urlAction = [[TTURLAction actionWithURLPath:@"tt://weatherCityAdd"] applyAnimated:YES];    
    [[TTNavigator navigator] openURLAction:urlAction];
}

#pragma mark - table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"cityCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[SNWeatherCitiesManageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    NSDictionary *dic = [_cities objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dic objectForKey:kCity];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *) fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    id object=[self.cities objectAtIndex:[fromIndexPath row]];
    [self.cities removeObjectAtIndex:[fromIndexPath row]];
    [self.cities insertObject:object atIndex:[toIndexPath row]];
    // 如果排名第一的变了 重设一下默认城市
    if ([fromIndexPath row] == 0 || [toIndexPath row] == 0) {
        NSDictionary *dic = [_cities objectAtIndex:0];
        [[SNWeatherCenter defaultCenter] resetDefaultCity:dic];
    }
    // 及时缓存城市顺序
    [[SNWeatherCenter defaultCenter] setSubedCitiesArray:_cities];
    
    [self darkerAllCellsForNight];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.cities.count == 1) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请您至少保留一个城市" toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else {
            [self.cities removeObjectAtIndex:[indexPath row]];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            // 如果排名第一的变了 重设一下默认城市
            if ([indexPath row] == 0) {
                NSDictionary *dic = [_cities objectAtIndex:0];
                [[SNWeatherCenter defaultCenter] resetDefaultCity:dic];
            }
        }
        [self darkerAllCellsForNight];
    }
}

#pragma mark - table view delegate
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - private methods
- (void)darkerAllCellsForNight {
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        for (UITableViewCell *cell in _tableView.visibleCells) {
            cell.alpha = 0.6;
        }
    }
}

@end
