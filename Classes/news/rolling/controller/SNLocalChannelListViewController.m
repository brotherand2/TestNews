//
//  SNLocalChanelListViewController.m
//  sohunews
//
//  Created by lhp on 3/26/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNLocalChannelListViewController.h"
#import "SNChannel.h"
#import "SNUserLocationManager.h"
#import "SNLocalChannelCell.h"
#import "SNChannelListCell.h"
#import "SNLiveHeaderView.h"
#import "SNCitySelectorController.h"
#import "SNWaitingActivityView.h"
#import "UIDevice-Hardware.h"
#import "SNChannelManageContants.h"
#import "SNCustomTextField.h"
#import "SNDBManager.h"
#import "SNRollingNewsPublicManager.h"

#import "SNMySDK.h"

@interface SNLocalChannelListViewController () {
    SNWaitingActivityView *loadingActivity;
    CGPoint _contentOffset;
}

@end

#define kSearchViewHeight (100 / 2)
#define kHeaderViewHeight (56 / 2)
#define kChannelCellHeight (80 / 2)
#define kEmptyViewTag 200

@interface SNLocalChannelListViewController()
@property (nonatomic) BOOL notifySDK;
@end

@implementation SNLocalChannelListViewController
@synthesize titleString;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.titleString = [query objectForKey:kCity];
        _notifySDK = [query objectForKey:@"notifySDK"];
        self.channelId = query[@"channelId"];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(reloadTableView:)
                                  name:kRefeshLocalChannelListNotification
                                object:nil];

    [SNNotificationManager addObserver:self
                              selector:@selector(reloadTableView:)
                                  name:kRollingChannelUpdateLocalNotification
                                object:nil];

    [SNNotificationManager addObserver:self
                              selector:@selector(reloadTableView:)
                                  name:kChannelUpdateLocalNotChangeNotification
                                object:nil];
    
    self.headerView.hidden = YES;
    searchMode = NO;
    
    localChannelService = [[SNLocalChannelService alloc] init];
    localChannelService.delegate = self;
    [localChannelService sendGetChannelRequest:self.channelId];
    
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
    }
    
    _loadingView.status = SNEmbededActivityIndicatorStatusStartLoading;
    self.tableView.hidden = YES;
    
    [self addToolbar];
}

- (void)reloadTableView:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)addHeaderView {
    _searchView = [[SNNormalSearchView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 64) delegate:self];
    if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX) {
        UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 24)];
        statusView.backgroundColor = _searchView.backgroundColor;
        [self.view addSubview:statusView];
        _searchView.frame = CGRectMake(0, 24, kAppScreenWidth, 64);
    }
    _searchView.accessibilityLabel = @"请输入城市名称";
    [self.view addSubview:_searchView];
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(_searchView.frame), 0.f, 0.f, 0.f);
    self.tableView.frame = CGRectMake(0, 0, kAppScreenWidth,kAppScreenHeight - [SNToolbar toolbarHeight]);
    self.tableView.bounces = NO;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = SNUICOLOR(kThemeBlue1Color);
}

- (void)closeLocalChannel {
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)showEmpty:(BOOL)show {
    if (show) {
        if (!_emptyImageView) {
            _emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icokb_kongbaiye_v5.png"]];
            _emptyImageView.center = _tableView.center;
            _emptyImageView.top = kEmptyImageTopDistance;
            [_tableView addSubview:_emptyImageView];
            _tableView.scrollEnabled = NO;
            
            _emptyTextLabel = [[UILabel alloc] init];
            _emptyTextLabel.backgroundColor = [UIColor clearColor];
            _emptyTextLabel.text = kTemporaryCityNone;
            _emptyTextLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
            [_emptyTextLabel sizeToFit];
            _emptyTextLabel.textColor = SNUICOLOR(kThemeText4Color);
            _emptyTextLabel.center = _emptyImageView.center;
            _emptyTextLabel.top = _emptyImageView.bottom + kEmptyImageBottomDistance;
            [_tableView addSubview:_emptyTextLabel];
        } else {
            [_tableView addSubview:_emptyImageView];
            [_tableView addSubview:_emptyTextLabel];
        }
    } else {
        _tableView.scrollEnabled = YES;
        if (_emptyImageView) {
            [_emptyImageView removeFromSuperview];
            [_emptyTextLabel removeFromSuperview];
        }
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showEmpty:NO];
    searchMode = YES;
    [self.tableView reloadData];
    if ([textField.text length] > 0) {
        [_searchView showSearchButton:YES];
    } else {
        [_searchView showSearchButton:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self showEmpty:NO];
    if (![_searchView isSearching]) {
        searchMode = NO;
        [self.tableView reloadData];
    } else {
        if ([localChannelService.searchedChannels count] == 0) {
            [self showEmpty:YES];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0 || [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kPleaseInputSearchCity toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return NO;
    }
    
    [_searchView showSearchButton:NO];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(SNCustomTextField *)textField {
    if (textField.text.length != 0) {
        localChannelService.keyWord = [_searchView getSearchText];
        [_searchView showSearchButton:YES];
    } else {
        [_searchView showSearchButton:NO];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!searchMode) {
        [_searchView closeKeyBoard];
        _contentOffset = self.tableView.contentOffset;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _contentOffset = self.tableView.contentOffset;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (searchMode || section == 0) {
        return nil;
    }
    
    CGFloat sectionHeight = kHeaderViewHeight;
    if (section == 1) {
        sectionHeight = kHeaderViewHeight + 5.0;
    }
    
    SNLiveHeaderView *headerView = [[SNLiveHeaderView alloc]
                                     initWithFrame:CGRectMake(0,
                                                              0,
                                                              tableView.width,
                                                              sectionHeight)];
    headerView.titleLabel.text = [[localChannelService titleArray] objectAtIndex:section];
    headerView.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    headerView.titleLabel.textColor = SNUICOLOR(kThemeText4Color);
    headerView.bar.backgroundColor = SNUICOLOR(kBackgroundColor);
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (searchMode || section == 0) {
        return 0;
    }
    return kHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kChannelCellHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (searchMode || section == 0) {
        return @"";
    }
    return [[localChannelService titleArray] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return searchMode?nil:[localChannelService titleSectionArray];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger keyIndex = [[localChannelService titleSectionArray] indexOfObject:title];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissTitleView) object:nil];
    [self showTitleView:[[localChannelService titleSectionArray] objectAtIndex:keyIndex] index:keyIndex];
    
    return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return searchMode ? 1 : [localChannelService titleArray].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searchMode) {
        NSInteger searchCount = [localChannelService.searchedChannels count];
        if (searchCount == 0 && [_searchView getSearchText].length > 0) {
            return 0;
        } else {
            [self showEmpty:NO];
            return searchCount;
        }
    } else {
        if (section == 0) {
            if ([self isHousechannel]) {
                return 1;
            } else {
                return 2;
            }
        } else if (section == 1) {//注意历史显示频道，至少为1
            return [SNUtility getHistoryShowChannel:[self isHousechannel]] ? [[SNUtility getHistoryShowChannel:[self isHousechannel]] count] : 1;
        } else {
            NSArray *channelArray = [localChannelService.localChannels objectAtIndex:section - 2];
            return [channelArray count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    if (searchMode) {
        cellIdentifier = @"searchLocalChannel";
    } else {
        if (indexPath.section == 0) {
            cellIdentifier = @"localChannel";
        } else if (indexPath.section == 1) {
            cellIdentifier = @"historyChannel";
        } else {
            cellIdentifier = @"channelCity";
        }
    }
    
    if ([cellIdentifier isEqualToString:@"channelCity"]) {
        NSArray *channelArray = [localChannelService.localChannels objectAtIndex:indexPath.section - 2];
        SNChannel *channel = [channelArray objectAtIndex:indexPath.row];
        SNChannelListCell *channelCell = (SNChannelListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!channelCell) {
            channelCell = [[SNChannelListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [channelCell localChannelWithCity:channel.channelName];
        return channelCell;
    } else if([cellIdentifier isEqualToString:@"searchLocalChannel"]) {
        SNChannel *channel = [localChannelService.searchedChannels objectAtIndex:indexPath.row];
        SNChannelListCell *channelCell = (SNChannelListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!channelCell) {
            channelCell = [[SNChannelListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [channelCell localChannelWithCity:channel.channelName keyWord:[_searchView getSearchText]];
        return channelCell;
    } else if ([cellIdentifier isEqualToString:@"localChannel"]) {//本地
        SNLocalChannelCell *localCell = (SNLocalChannelCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!localCell) {
            localCell = [[SNLocalChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (indexPath.row == 0) {
            NSString *localString = nil;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (![userDefaults objectForKey:kLocationCityKey]) {
                localString = [SNUserLocationManager sharedInstance].currentChannelName;
                [userDefaults setObject:localString forKey:kLocationCityKey];
                [userDefaults synchronize];
            } else {
                localString = [userDefaults objectForKey:kLocationCityKey];
            }
            if (localString.length > 0) {
                NSString *cityString = nil;
                if ([localString isEqualToString:kCurrentLocationFail]) {
                    cityString = localString;
                } else {
                    cityString = [NSString stringWithFormat:@"%@%@", kCurrentLocationCity, localString];
                }
                SNChannel *localChannel = [[SNChannel alloc] init];
                localChannel.channelName = localString;
                localChannel.channelId = [SNUserLocationManager sharedInstance].currentChannelId;
                localChannel.gbcode = [SNUserLocationManager sharedInstance].currentChannelGBCode;
                [SNUtility saveLocalChannel:localChannel isHouseChannel:[self isHousechannel]];
                [localCell removeRefreshButton];
                [localCell localChannelWithLocalCity: cityString];
            } else {
                [localCell localChannelWithLocalCity:kCurrentLocationFail];
            }
            localCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else {
            BOOL switchStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:kIntelligetnLocationSwitchKey] boolValue];
            [localCell removeRefreshButton];
            if (kAppScreenWidth == 320.0) {
                if (switchStatus) {
                    [localCell localIntelligentSearchWithString:kLightIntelligentSwitchOpen];
                } else {
                    [localCell localIntelligentSearchWithString:kLightIntelligentSwitchOpen];
                }
            } else {
                if (switchStatus) {
                    [localCell localIntelligentSearchWithString:kIntelligentSwitchOpen];
                } else {
                    [localCell localIntelligentSearchWithString:kIntelligentSwitchClose];
                }
            }
            localCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [localCell drawSeperateLine];
        return localCell;
    } else {
        //历史显示频道
        SNLocalChannelCell *localCell = (SNLocalChannelCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!localCell) {
            localCell = [[SNLocalChannelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (![SNUtility getHistoryShowChannel:[self isHousechannel]]) {
            [localCell localChannelWithCity:[SNUserLocationManager sharedInstance].currentChannelName];
            SNChannel *saveChannel = [[SNChannel alloc] init];
            saveChannel.channelName = [SNUserLocationManager sharedInstance].currentChannelName;
            saveChannel.channelId = [SNUserLocationManager sharedInstance].currentChannelId;
            saveChannel.gbcode = [SNUserLocationManager sharedInstance].currentChannelGBCode;
            if (saveChannel.channelName.length == 0) {
                if (![self isHousechannel]) {
                    [SNUtility saveHistoryShowWithChannel:[SNUtility getThirdChannel] isHouseChannel:[self isHousechannel]];
                } else {
                    [SNUtility saveHistoryShowWithChannel:[self getLocalHouseChannel] isHouseChannel:[self isHousechannel]];
                    [localCell localChannelWithCity:[self getLocalHouseChannel].channelName];
                }
            } else {
                if (![self isHousechannel]) {
                    [SNUtility saveHistoryShowWithChannel:saveChannel isHouseChannel:[self isHousechannel]];
                } else {
                    [SNUtility saveHistoryShowWithChannel:[self getLocalHouseChannel] isHouseChannel:[self isHousechannel]];
                    [localCell localChannelWithCity:[self getLocalHouseChannel].channelName];
                }
            }
        } else {
            NSInteger keyIndex = [[SNUtility getHistoryShowChannel:[self isHousechannel]] count] - indexPath.row - 1;
            SNChannel *savedChannel = [[SNUtility getHistoryShowChannel:[self isHousechannel]] objectAtIndex:keyIndex];
            [localCell localChannelWithCity:savedChannel.channelName];
        }
        return localCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SNChannel *channel = nil;
    
    //切换频道点击, 设置频道已经切换
    [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = YES;
    
    if (searchMode) {
        channel = [localChannelService.searchedChannels objectAtIndex:indexPath.row];
    } else {
        if (indexPath.section == 1) {
            NSArray *arrayHistory = [SNUtility getHistoryShowChannel:[self isHousechannel]];
            SNChannel *savedChannel = [arrayHistory objectAtIndex:([arrayHistory count] - indexPath.row - 1)];
            
            if (savedChannel.gbcode.length == 0 || [self isHousechannel]) {
                savedChannel = [self getCityChannel:savedChannel.channelName];
            }
            
            [SNUserLocationManager sharedInstance].isRefreshLocation = NO;
            [SNUserLocationManager sharedInstance].isRefreshChannelLocation = NO;
            [[SNUserLocationManager sharedInstance] updateLocalChannelWithId:savedChannel.channelId cityName:savedChannel.channelName gbcode:savedChannel.gbcode channelId:self.channelId];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self closeLocalChannel];
            });
            
            //切换频道重置，删除旧请求参数
            [[SNRollingNewsPublicManager sharedInstance] deleteRequestParamsWithChannelId:kLocalChannelUnifyID];
            return;
        } else if (indexPath.section > 1) {
            NSArray *channelArray = [localChannelService.localChannels objectAtIndex:indexPath.section - 2];
            channel = [channelArray objectAtIndex:indexPath.row];
            [SNUtility saveHistoryShowWithChannel:channel isHouseChannel:[self isHousechannel]];
            
            //切换频道重置，删除旧请求参数
            [[SNRollingNewsPublicManager sharedInstance] deleteRequestParamsWithChannelId:kLocalChannelUnifyID];
        } else if (indexPath.section == 0 && indexPath.row == 0) {
            if ([SNUserLocationManager sharedInstance].localResult != SNLocalChannelResultNone) {
                SNChannel *savedChannel = [SNUtility getLocalChannel:[self isHousechannel]];
                NSString *cityString = savedChannel.channelName;
                if (savedChannel.channelName.length == 0) {
                    cityString = [SNUserLocationManager sharedInstance].localChannelName;
                }
                savedChannel = [self getCityChannel:cityString];
                [SNUserLocationManager sharedInstance].isRefreshLocation = NO;
                [SNUserLocationManager sharedInstance].isRefreshChannelLocation = NO;
                [[SNUserLocationManager sharedInstance] updateLocalChannelWithId:kLocalChannelUnifyID cityName:savedChannel.channelName gbcode:savedChannel.gbcode channelId:self.channelId];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self closeLocalChannel];
                });
                [SNUtility saveHistoryShowWithChannel:savedChannel isHouseChannel:[self isHousechannel]];
                return;
            }
        }
    }
    
    if (channel) {
        if (self.notifySDK) {
            [[SNMySDK sharedInstance] updateLocation:channel];
        } else {
            if ([self isHousechannel]) {
                [[SNUserLocationManager sharedInstance] updateHouseProLocalChannelWithId:channel.channelId cityName:channel.channelName gbcode:channel.gbcode channelId:self.channelId];
            } else {
                [SNUserLocationManager sharedInstance].isRefreshLocation = NO;
                [SNUserLocationManager sharedInstance].isRefreshChannelLocation = NO;
                [[SNUserLocationManager sharedInstance] updateLocalChannelWithId:channel.channelId cityName:channel.channelName gbcode:channel.gbcode channelId:self.channelId];
            }
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self closeLocalChannel];
        });
    } else {
        [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel = NO;
    }
}

- (void)addToolbar {
    SNToolbar *toolbarView = [[SNToolbar alloc] initWithFrame:CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight])];
    // 返回按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 43)];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self
                   action:@selector(closeLocalChannel)
         forControlEvents:UIControlEventTouchUpInside];
    [leftButton setAccessibilityLabel:@"返回"];
    [toolbarView setLeftButton:leftButton];
    
    [self.view addSubview:toolbarView];
}

- (void)showTitleView:(NSString *)title index:(NSInteger)index {
    if (!title) {
        return;
    }
    if (!_indexImageView) {
         _indexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kShowIndexBackgroundWidth, kShowIndexBackgroundHeight)];
         _indexImageView.backgroundColor = [UIColor clearColor];
         UIImage *bgImage = [UIImage imageNamed:@"bgnormalsetting_layer_v5.png"];
         _indexImageView.image = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        
        [[TTNavigator navigator].window addSubview:_indexImageView];
        
        _indexTitleLable = [[UILabel alloc] init];
        _indexTitleLable.backgroundColor = [UIColor clearColor];
        _indexTitleLable.font = [UIFont systemFontOfSize:kThemeFontSizeF];
        _indexTitleLable.textColor = SNUICOLOR(kThemeText4Color);
        [_indexImageView addSubview:_indexTitleLable];
    }
    _indexTitleLable.text = title;
    [_indexTitleLable sizeToFit];
    _indexImageView.right = kAppScreenWidth - kShowIndexBackgroundHeight + 10;
    _indexImageView.top = kShowIndexBackgroundTop + (index - 1) * 14;
    _indexTitleLable.center = CGPointMake(_indexImageView.frame.size.width / 2, _indexImageView.frame.size.height / 2);
    
    //2016-12-22 wangchuanwen update begin
    //reason:每次显示动画完成后都会删除，且alpha置为0，所以先要在此还原
    _indexImageView.alpha = 1.0;
    [[TTNavigator navigator].window addSubview:_indexImageView];
    [_indexImageView addSubview:_indexTitleLable];
    //2016-12-22 wangchuanwen update end
    
    [self performSelector:@selector(dismissTitleView) withObject:nil afterDelay:kShowIndexTime];
}

- (void)dismissTitleView {
    [UIView animateWithDuration:0.3 animations:^(void) {
        _indexImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [_indexImageView removeFromSuperview];
        [_indexTitleLable removeFromSuperview];
    }];
}

- (void)cancelSearch {
    [_searchView closeKeyBoard];
    [_searchView resetTextView];
    searchMode = NO;
    [self.tableView reloadData];
    [self showEmpty:NO];
    self.tableView.contentOffset = _contentOffset;
}

- (void)doSearch {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if ([_searchView getSearchText].length == 0 ||
        [[_searchView getSearchText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:kPleaseInputSearchCity toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    
    [_searchView closeKeyBoard];
    [_searchView showSearchButton:NO];
    [self showEmpty:NO];
    if (![_searchView isSearching]) {
        searchMode = NO;
        [self.tableView reloadData];
    } else {
        if ([localChannelService.searchedChannels count] == 0) {
            [self showEmpty:YES];
        }
    }
}

- (BOOL)isHousechannel {
    return [SNUserLocationManager isHouseProLocalTypeWithChannelId:self.channelId];
}

- (SNChannel *)getLocalHouseChannel {
    SNChannel *localHouseChannel = [[SNChannel alloc] init];
    NSMutableArray *originChannelArray = localChannelService.originChannelArray;
    NSString *cityName = self.titleString;
    if ([SNUserLocationManager sharedInstance].localResult != SNLocalChannelResultNone && cityName.length > 0) {
        
        if ([originChannelArray count] > 0) {
            for (NSDictionary *dict in originChannelArray) {
                if ([cityName isEqualToString:[dict objectForKey:@"name"]]) {
                    localHouseChannel.channelName = [dict objectForKey:@"name"];
                    localHouseChannel.channelId = [dict objectForKey:@"id"];
                    localHouseChannel.gbcode = [dict objectForKey:@"gbcode"];
                    break;
                }
            }
        }
    } else {
        if ([originChannelArray count] > 0) {
            for (NSDictionary *dict in originChannelArray) {
                if ([[dict objectForKey:@"name"] isEqualToString:@"北京"]) {
                    localHouseChannel.channelName = [dict objectForKey:@"name"];
                    localHouseChannel.channelId = [dict objectForKey:@"id"];
                    localHouseChannel.gbcode = [dict objectForKey:@"gbcode"];
                    [SNUtility saveLocalChannel:localHouseChannel isHouseChannel:[self isHousechannel]];
                    break;
                }
            }
        }
    }
    return localHouseChannel;
}

- (SNChannel *)getCityChannel:(NSString *)cityName {
    SNChannel *channel = [[SNChannel alloc] init];
    NSMutableArray *originChannelArray = localChannelService.originChannelArray;
    for (NSDictionary *dict in originChannelArray) {
        if ([cityName isEqualToString:[dict objectForKey:@"name"]]) {
            channel.channelName = [dict objectForKey:@"name"];
            channel.channelId = [dict objectForKey:@"id"];
            channel.gbcode = [dict objectForKey:@"gbcode"];
            break;
        }
    }
 
    return channel;
}

#pragma mark -
#pragma mark SNLocalChannelServicerDelegate
- (void)requestDidFinishLoad {
    _loadingView.status = SNEmbededActivityIndicatorStatusStopLoading;
    self.tableView.hidden = NO;
    [self.tableView reloadData];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
