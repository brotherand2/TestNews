//
//  SNCorpusNewsViewController.m
//  sohunews
//
//  Created by Scarlett on 15/8/28.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNCorpusNewsViewController.h"
#import "SNCorpusPhotoAndTitleCell.h"
#import "SNCorpusPhotosCell.h"
#import "SNCorpusTitleCell.h"
#import "SNTwinsMoreView.h"
#import "NSCellLayout.h"
#import "SNCorpusAlertObject.h"
#import "SNCloudSaveService.h"
#import "SNUserManager.h"
#import "SNDBManager.h"
#import "SNNewsReport.h"
#import "SNCorpusJokeCell.h"
#import "SNCorpusRollingBigVideoCell.h"
#import "SNCorpusRollingMiddleVideoCell.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNNewAlertView.h"
#import "SNCorpusListRequest.h"
#import "SNCorpusBatchMoveRequest.h"
#import "SNCorpusNewsRequest.h"
#import "SNDeleteCorpusNewsRequest.h"
#import "SNCorpusList.h"
#import "SNFavoriteViewController.h"
#import "SNNewsLogin.h"

#define kNormalDistance 33/2.0
#define kEditTabBarHeight ((kAppScreenWidth > 375.0) ? 168.0/3 : 100.0/2)
#define kEditTabBariPhoneXOffset ([SNDevice sharedInstance].isPhoneX ? 18.0 : 0)
#define kEditAllButtonLeftDiatance ((kAppScreenWidth > 375.0) ? 30.0/3 : 25.0/2)
#define kEmptyImageTopDistance ((kAppScreenWidth > 375.0) ? 273.0/3 : 168.0/2)
#define kEmptyImageBottomDistance ((kAppScreenWidth > 375.0) ? 53.0/3 : 42.0/2)
#define kEmptyLabelBottomDistance ((kAppScreenWidth > 375.0) ? 28.0/3 : 18.0/2)
#define kEmptyAddButtonTopDistance ((kAppScreenWidth > 375.0) ? 179.0/3 : 110.0/2)
#define kLoginBetweenDistance 12/2.0
#define kEmptyTextFontSize ((kAppScreenWidth > 375.0) ? kThemeFontSizeE : kThemeFontSizeD)
#define kEmptyAddTextFontSize ((kAppScreenWidth > 375.0) ? kThemeFontSizeC : kThemeFontSizeB)
#define kLoginButtonFont ((kAppScreenWidth == 320.0) ? kThemeFontSizeC : kThemeFontSizeD)
#define kImageHeight ((kAppScreenWidth > 375.0) ? 219.0/3 : 126.0/2)

#define kPhotoTitleCellHeight CONTENT_LEFT+kImageHeight + 5

@interface SNCorpusNewsViewController () <UITableViewDelegate, UITableViewDataSource, SNTripletsLoadingViewDelegate, SNClickItemOnHalfViewDelegate>

@property (nonatomic, copy)NSString *newsIDS;
@property (nonatomic, copy)NSString *linkString;
@property (nonatomic, copy)NSString *moveToCorpusName;
@property (nonatomic, copy)NSString *moveToCorpusID;
@property (nonatomic, strong)NSMutableArray *favoritesArray;
@property (nonatomic, strong)NSMutableArray *appendDataArray;
@property (nonatomic, strong)NSArray *imageUrlArray;
@property (nonatomic, weak)SNTwinsMoreView *twinsMoreView;
@property (nonatomic, strong)NSMutableArray *tempStatusArray;
@property (nonatomic, strong)SNCloudSaveService *userInfoModel;
@property (nonatomic, assign) BOOL isFromFavoriteManager;
@property (nonatomic, assign)BOOL isOpenFromEmptyCorpus;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, copy)NSString *emptyCorpusName;
@property (nonatomic, copy)NSString *emptyCorpusID;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, weak) UILabel *loginLabel;

@property (nonatomic, strong) UIView *editTabBarView;
@property (nonatomic, strong) UIView *tableFootView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *chooseAllButton;
@property (nonatomic, strong) UIButton *addToButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *manageButton;
@property (nonatomic, assign) BOOL isLoadMoreNews;
@property (nonatomic, strong) SNCorpusAlertObject *corpuseAlertObject;
@property (nonatomic, strong) NSIndexPath *currentPlayIndex;

@property (nonatomic, assign) CGRect viewCustomFrame;

@end


static NSMutableDictionary *kSaveList;

@implementation SNCorpusNewsViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        if ([query objectForKey:kEditeFavorite]) {
            
            _isEditMode = [[query objectForKey:kEditeFavorite] boolValue];
        }
        
        if ([query objectForKey:kFromFavoriteManager]) {
            
            _isFromFavoriteManager = [[query objectForKey:kFromFavoriteManager] boolValue];
        }
        
        self.isOpenFromEmptyCorpus = [query objectForKey:kOpenCorpusFromEmpty];
        self.emptyCorpusName = [query objectForKey:kEmptyCorpusName];
        self.emptyCorpusID = [query objectForKey:kEmptyCorpusID];
        self.corpusName = [query objectForKey:kCorpusFolderName];
        
        if ([self.corpusName isEqualToString:kCorpusMyFavourite] || [self.corpusName isEqualToString:kCorpusMyShare]) {
            self.corpusID = @"0";
        } else {
            self.corpusID = [query objectForKey:kCorpusID];
        }
    }
    return self;
}

- (instancetype)initWithCustomFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.viewCustomFrame = frame;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    if (self.viewCustomFrame.size.height > 0) {
        self.view.frame = self.viewCustomFrame;
    }
    _pageNum = 1;
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
    self.view.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    [self initTableView];
    self.loadingView.status = SNTripletsLoadingStatusStopped;
    self.loadingView.hidden = YES;
    _backView.hidden = NO;
    self.animationImageView.status = SNImageLoadingStatusLoading;
    [self setEditButtonStatus:NO];
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObjects:self.corpusName, nil]];
    CGSize titleSize = [self.corpusName sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    if (_isEditMode) {
        self.headerView.hidden = NO;
        [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
        [self initManageButton];
//        [self addToolbar];
        [self initEditTabBarView];
        [self getCorpusNewsList];
    } else if (_isFromFavoriteManager ){
        [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
        self.headerView.hidden = NO;
        [self addToolbar];
        [self initManageButton];
    
    } else if (_isOpenFromEmptyCorpus) {
        self.headerView.hidden = NO;
        [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
        [self initManageButton];
//        [self addToolbar];
        [self initEditTabBarView];
        [self getCorpusNewsList];
    }
    else {
        self.headerView.hidden = YES;
        [self initLoginPart];
    }
    
    //    [self initEmptyView];
    _appendDataArray = [[NSMutableArray alloc] init];
    _tempStatusArray = [[NSMutableArray alloc] init];
    _imageUrlArray = [[NSArray alloc] init];
    
    
    [SNNotificationManager addObserver:self selector:@selector(moveCorpusItemNotification:) name:kMoveCorpusItemNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(videoAutoPlay:) name:kVideoAutoPlay object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(statusBarFrameWillChange:)
                                  name:UIApplicationWillChangeStatusBarFrameNotification
                                object:nil];
    if ([SNUserDefaults objectForKey:kIsCancelCollectTag]) {
        [SNUserDefaults removeObjectForKey:kIsCancelCollectTag];
    }
    if ([SNUserDefaults objectForKey:kSelectedIteRowNum]) {
        [SNUserDefaults removeObjectForKey:kSelectedIteRowNum];
    }
}


- (void)statusBarFrameWillChange:(NSNotification*)notification {
    [UIView animateWithDuration:0.25 animations:^{
        _corpusNewsTableView.height = kAppScreenHeight - kHeaderTotalHeight - [SNToolbar toolbarHeight];
        self.editTabBarView.bottom = kAppScreenHeight;
        if (self.toolbarView) {
            [self resetToolBarOrigin];
        }
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    if ([[SNUserDefaults objectForKey:kIsCancelCollectTag] boolValue] && ![self.corpusName isEqualToString:kCorpusMyShare]) {//分享列表进正文，取消收藏，不在列表删除
        if ([self.favoritesArray count] > 0) {
            NSInteger index = [[SNUserDefaults objectForKey:kSelectedIteRowNum] integerValue];
            [self.favoritesArray removeObjectAtIndex:index];
            if ([self.favoritesArray count] == 0) {
                [_corpusNewsTableView reloadData];
                [self initEmptyView];
                [_manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
                _manageButton.userInteractionEnabled = NO;
                [self setTwinsMoreViewAnimating:NO];
                _statusLabel.text = nil;
                _statusLabel.hidden = YES;
            }
            else {
                [_corpusNewsTableView reloadData];
                [self autoPlayVideoWithNetWifi];
            }
        }
    }
    else if ([[SNUserDefaults objectForKey:kAddNewsToEmptyCorpusKey] boolValue]) {
        if (_emptyView) {
            [_emptyView removeFromSuperview];
        }
        if (!_isEditMode && !_isOpenFromEmptyCorpus &&!_isFromFavoriteManager) {
            if (self.corpusID || self.corpusName) {
                [self getCorpusNewsList];
            }
        }
        [SNUserDefaults removeObjectForKey:kAddNewsToEmptyCorpusKey];
    }
    if (_isFromFavoriteManager) {
        [self getCorpusNewsList];
    }

    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    if ([self.favoritesArray count] > 0 && !_isEditMode) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self.favoritesArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop){
            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [mutableDict setValue:[NSNumber numberWithBool:NO] forKey:kIsSelectedItem];
            [tempArray addObject:mutableDict];
        }];
        [self.favoritesArray removeAllObjects];
        self.favoritesArray = tempArray;
    }
    
    [self settingVideoStatus];
    
    if (_animationImageView) {
        _animationImageView.status = SNImageLoadingStatusStopped;
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark init
- (void)initTableView {
    if (!_corpusNewsTableView) {
        CGFloat corpusNewsTableViewY = 0.0;
        if (_isEditMode || _isFromFavoriteManager || _isOpenFromEmptyCorpus) {
            corpusNewsTableViewY += kHeaderTotalHeight;
        }

        UITableView *corpusNewsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, corpusNewsTableViewY, kAppScreenWidth, kAppScreenHeight - kHeaderTotalHeight - [SNToolbar toolbarHeight]) style:UITableViewStylePlain];
        if (self.viewCustomFrame.size.height > 0) {
            corpusNewsTableView.frame = self.viewCustomFrame;
        }
        _corpusNewsTableView = corpusNewsTableView;
        
        if (@available(iOS 11.0, *)) {
            _corpusNewsTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _corpusNewsTableView.estimatedRowHeight = 0;
            _corpusNewsTableView.estimatedSectionFooterHeight = 0;
            _corpusNewsTableView.estimatedSectionHeaderHeight = 0;
        } else {
            // Fallback on earlier versions
        }
        
        _corpusNewsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _corpusNewsTableView.separatorColor = [UIColor clearColor];
        _corpusNewsTableView.backgroundColor = [UIColor clearColor];
        _corpusNewsTableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
        _corpusNewsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
        _corpusNewsTableView.scrollsToTop = YES;
        _corpusNewsTableView.delegate = self;
        _corpusNewsTableView.dataSource = self;
        self.twinsMoreView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_corpusNewsTableView];
    }
}

- (void)initLoginPart {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:kLoginButtonFont];
        [_loginButton setTitle:kCorpusLogin forState:UIControlStateNormal];
        [_loginButton sizeToFit];
        [_loginButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
        _loginButton.left = kNormalDistance;
        _loginButton.top = kNormalDistance;

        [_loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_loginButton];
    }
    if (!_loginLabel) {
        UILabel *loginLabel = [[UILabel alloc] init];
        _loginLabel = loginLabel;
        _loginLabel.backgroundColor = [UIColor clearColor];
        _loginLabel.font = [UIFont systemFontOfSize:kLoginButtonFont];
        _loginLabel.text = kCorpusSynchronous;
        [_loginLabel sizeToFit];
        _loginLabel.textColor = SNUICOLOR(kThemeText3Color);
        _loginLabel.center = _loginButton.center;
        _loginLabel.left = _loginButton.right + kLoginBetweenDistance;
        [self.view addSubview:_loginLabel];
    }
}

- (void)loginAction:(id)sender {
//    [SNGuideRegisterManager login:kLoginFromMyCorpus];
    //wangshun 埋点
    [SNNewsLogin loginWithParams:@{@"loginFrom":@"100035"} Success:nil];
    
    [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
}

- (void)initManageButton {
    _manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_manageButton setTitle:kCorpusManage forState:UIControlStateNormal];
    if (_isEditMode) {
        [_manageButton setTitle:kCorpusCancel forState:UIControlStateNormal];
    }
    _manageButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [_manageButton sizeToFit];
    _manageButton.size = CGSizeMake(_manageButton.size.width + 20, _manageButton.size.height);
    _manageButton.right = kAppScreenWidth - kNormalDistance + 20;
    _manageButton.top = (kHeaderHeight - _manageButton.height)/2 + kSystemBarHeight;
    [_manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    [_manageButton addTarget:self action:@selector(manageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _manageButton.userInteractionEnabled = NO;
    [self.headerView addSubview:_manageButton];
    
}

- (void)initEditTabBarView {
    if (!_editTabBarView) {
        _editTabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight, kAppScreenWidth, kEditTabBarHeight)];
        _editTabBarView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        [self.view addSubview:_editTabBarView];
        
        UIImage *chooseAllImge = [UIImage imageNamed:@"ico_weiquanxuan_v5.png"];
        UIImage *choosedAllImage = [UIImage imageNamed:@"ico_quanxuan_v5.png"];
        _chooseAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseAllButton.selected = NO;
        [_chooseAllButton setTitle:kChooseListAll forState:UIControlStateNormal];
        [_chooseAllButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
        _chooseAllButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        [_chooseAllButton setImage:chooseAllImge forState:UIControlStateNormal];
        [_chooseAllButton setImage:choosedAllImage forState:UIControlStateSelected];
        CGSize size = [kCancelListAll getTextSizeWithFontSize:kThemeFontSizeD];
        _chooseAllButton.bounds = CGRectMake(0, 0, choosedAllImage.size.width+kEditAllButtonLeftDiatance+size.width, size.height);
        _chooseAllButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, -10);
        _chooseAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, _chooseAllButton.imageView.bounds.size.width-8, 0, -_chooseAllButton.imageView.bounds.size.width+8);
        _chooseAllButton.left = kEditAllButtonLeftDiatance - 15;
        _chooseAllButton.centerY = _editTabBarView.height/2;
        [_chooseAllButton addTarget:self action:@selector(chooseAllAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editTabBarView addSubview:_chooseAllButton];
        
        if (!_isOpenFromEmptyCorpus) {
            _addToButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_addToButton setTitle:kAddToCorpus forState:UIControlStateNormal];
            _addToButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
            [_addToButton sizeToFit];
            _addToButton.center = CGPointMake(_editTabBarView.width/2, _editTabBarView.height/2);
            [_addToButton addTarget:self action:@selector(addToAction:) forControlEvents:UIControlEventTouchUpInside];

            [_editTabBarView addSubview:_addToButton];
            
            _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_deleteButton setTitle:kDeleteCorpus forState:UIControlStateNormal];
            _deleteButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
            [_deleteButton sizeToFit];
            _deleteButton.centerY = _editTabBarView.height/2;
            _deleteButton.right = kAppScreenWidth - kEditAllButtonLeftDiatance;
            [_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [_editTabBarView addSubview:_deleteButton];
        }
        _editTabBarView.height += kEditTabBariPhoneXOffset;
        [self setEditButtonEditMode:NO];
    }
}

- (void)initEmptyView {
    [self setEditButtonStatus:NO];
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderTotalHeight, kAppScreenWidth, kAppScreenHeight - kHeaderTotalHeight - kToolbarHeight)];
        _emptyView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_emptyView];
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = SNUICOLOR(kThemeText4Color);
        
        UILabel *textAddLabel = [[UILabel alloc] init];
        textAddLabel.backgroundColor = [UIColor clearColor];
        textAddLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        textAddLabel.textColor = SNUICOLOR(kThemeText4Color);
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage imageNamed:@"ico_kongbaixj_v5.png"] forState:UIControlStateNormal];
        [addButton sizeToFit];
        [addButton addTarget:self action:@selector(openMyCorpus:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageView = nil;
        
        if ([self.corpusName isEqualToString:kCorpusMyShare] || [self.corpusName isEqualToString:kCorpusMyFavourite] || [self.corpusName isEqualToString:kCorpusMyInclude]) {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_kongbaifx_v5.png"]];
            if ([self.corpusName isEqualToString:kCorpusMyShare]) {
                textLabel.text = kCorpusShareEmpty;
            } else if ([self.corpusName isEqualToString:kCorpusMyInclude]) {
                textLabel.text = kCorpusGrabEmpty;
            } else {
                textLabel.text = kMyCorpusEmpty;
            }
            
            textLabel.font = [UIFont systemFontOfSize:kEmptyTextFontSize];
            imageView.center = CGPointMake(kAppScreenWidth/2, _emptyView.height/2 - kSystemBarHeight);
            imageView.top = kEmptyImageTopDistance;
            if (kAppScreenHeight == 480.0 || kAppScreenHeight < 480.0) {
                imageView.top = kEmptyImageTopDistance - 50.0;
            }
            if (_isFromFavoriteManager) {
                imageView.top += kHeaderTotalHeight;
            }
            
            [textLabel sizeToFit];
            textLabel.center = imageView.center;
            textLabel.centerY = imageView.bottom + kEmptyImageBottomDistance;
        }
        else {
            imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_kongbaisc_v5.png"]];
            textLabel.text = kCorpusFavouriteEmpty;
            textLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
            
            imageView.center = CGPointMake(kAppScreenWidth/2, _emptyView.height/2 - kSystemBarHeight);
            imageView.top = kEmptyImageTopDistance;
            if (kAppScreenHeight == 480.0 || kAppScreenHeight < 480.0) {
                imageView.top = kEmptyImageTopDistance - 120.0;
            }
            if (kAppScreenHeight == 568.0) {
                imageView.top = kEmptyImageTopDistance - 80.0;
            }
            if (_isFromFavoriteManager) {
                imageView.top += kHeaderTotalHeight;
            }
            [textLabel sizeToFit];
            textLabel.center = imageView.center;
            textLabel.top = imageView.bottom + kEmptyLabelBottomDistance;
            
            textAddLabel.text = kCorpusFavouriteAddEmpty;
            textAddLabel.font = [UIFont systemFontOfSize:kEmptyAddTextFontSize];
            [textAddLabel sizeToFit];
            textAddLabel.center = imageView.center;
            textAddLabel.top = textLabel.bottom + kEmptyLabelBottomDistance;
            
            addButton.center = imageView.center;
            addButton.top = textAddLabel.bottom + kEmptyAddButtonTopDistance;
            
            [_emptyView addSubview:addButton];
        }

        [_emptyView addSubview:imageView];
        [_emptyView addSubview:textLabel];
        [_emptyView addSubview:textAddLabel];
        
    }
}

- (void)setCorpusName:(NSString *)corpusName {
    _corpusName = corpusName;
    [self settingVideoStatus];
    self.currentPlayIndex = nil;
    if (_isEditMode || _isFromFavoriteManager || _isOpenFromEmptyCorpus) {
        return;
    }
    if (![SNUserManager isLogin] && [self.corpusName isEqualToString:kCorpusMyFavourite]) {
        _loginLabel.hidden = NO;
        _loginButton.hidden = NO;
        _corpusNewsTableView.top = _loginLabel.bottom + 5;
        if (self.viewCustomFrame.size.height > 0) {
            _corpusNewsTableView.height = self.viewCustomFrame.size.height - _loginLabel.bottom - 5;
        } else {
            _corpusNewsTableView.height = kAppScreenHeight - kHeaderTotalHeight - [SNToolbar toolbarHeight] -_loginLabel.bottom - 5;
        }
        [self.view layoutIfNeeded];
    } else {
        _loginLabel.hidden = YES;
        _loginButton.hidden = YES;
        _corpusNewsTableView.top = 0;
        if (self.viewCustomFrame.size.height > 0) {
            _corpusNewsTableView.height = self.viewCustomFrame.size.height;
        } else {
            _corpusNewsTableView.height = kAppScreenHeight - kHeaderTotalHeight - [SNToolbar toolbarHeight];
        }
        [self.view layoutIfNeeded];
    }
    _statusLabel.text = nil;
    _statusLabel.hidden = YES;
    [self.favoritesArray removeAllObjects];
    [self.corpusNewsTableView reloadData];

}
#pragma mark - getCorpusNews

- (void)getCorpusNewsList {
    _statusLabel.text = nil;
    _statusLabel.hidden = YES;
    if (_emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }
    if (_loadingView) {
        
        self.loadingView.status = SNTripletsLoadingStatusStopped;
        self.loadingView.hidden = YES;
    }
    if (_pageNum == 1 && !_isEditMode && !_isFromFavoriteManager && !_isOpenFromEmptyCorpus) {
        
        NSMutableArray *array = nil;
        if ([[self.saveList allKeys] containsObject:self.corpusName]) {
            array = [self.saveList valueForKey:self.corpusName];
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (self.saveList.allValues.count > 5) {
                [SNCorpusNewsViewController clearData];
            }
        });
        if (array) {
            self.favoritesArray = array.mutableCopy;
            if (self.favoritesArray.count > 0 ) {
                
                [self.corpusNewsTableView reloadData];
                [self autoPlayVideoWithNetWifi];

                if (self.favoritesArray.count < kCorpusListCount / 2) {
                    [self setTwinsMoreViewAnimating:NO];
                    _statusLabel.text = kLoadFinished;
                    _statusLabel.hidden = NO;
                    
                } else {
                    _statusLabel.text = nil;
                    _statusLabel.hidden = YES;

                }
            } else {
                _statusLabel.text = nil;
                _statusLabel.hidden = YES;
                [self initEmptyView];
            }
            _backView.hidden = YES;
            self.animationImageView.status = SNImageLoadingStatusStopped;
            return;
        }
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:2];
    
    if ([self.corpusName isEqualToString:kCorpusMyInclude]) {
        [param setValue:@"20" forKey:@"limit"];
    } else {
        if (self.corpusID) [param setObject:self.corpusID forKey:kCorpusID];
    }
    [param setObject:@(_pageNum) forKey:@"page"];
        
    [[[SNCorpusNewsRequest alloc] initWithDictionary:param andCorpusName:self.corpusName] send:^(SNBaseRequest *request, id responseObject) {
        if (nil == responseObject) {
            if (_pageNum == 1) {
                
                _backView.hidden = YES;
                self.animationImageView.status = SNImageLoadingStatusStopped;
                self.loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
                self.loadingView.hidden = NO;
            } else {
                [self setTwinsMoreViewAnimating:NO];
                _statusLabel.text = kLoadFinished;
                _statusLabel.hidden = NO;
            }
            
            return;
        }
        if ([self.corpusName isEqualToString:kCorpusMyInclude] && [[responseObject objectForKey:@"isSuccess"] isEqualToString:@"S"]) {
            [self handleNewsGrabData:responseObject];
        } else {
            NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
            
            if (status == 200) {
                NSDictionary *data = [responseObject objectForKey:@"data"];
                if (_pageNum == 1) {
                    NSMutableArray *array = [NSMutableArray arrayWithArray:[data objectForKey:@"favorites"]];
                    
                    self.favoritesArray = array;
                    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                    if ([self.favoritesArray count] != 0) {
                        [self.favoritesArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop){
                            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                            [mutableDict setValue:[NSNumber numberWithBool:NO] forKey:kIsSelectedItem];
                            
                            [tempArray addObject:mutableDict];
                        }];
                        [self.favoritesArray removeAllObjects];
                        self.favoritesArray = tempArray;
                        
                        [_manageButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
                        _manageButton.userInteractionEnabled = YES;
                        [_corpusNewsTableView reloadData];
                        if (!self.notAutoPlay) {
                            [self autoPlayVideoWithNetWifi];
                        }
                        self.notAutoPlay = NO;
                        
                        if (self.favoritesArray.count < kCorpusListCount / 2) {
                            [self setTwinsMoreViewAnimating:NO];
                            _statusLabel.text = kLoadFinished;
                            _statusLabel.hidden = NO;
                            
                        }
                    }
                    else {
                        [_corpusNewsTableView reloadData];
                        [self initEmptyView];
                        [self setTwinsMoreViewAnimating:NO];
                        _statusLabel.text = nil;
                        _statusLabel.hidden = YES;
                        [_manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
                        _manageButton.userInteractionEnabled = NO;
                    }
                    
                    [self.saveList setObject:self.favoritesArray.copy forKey:self.corpusName];
                }
                else {
                    [self.appendDataArray removeAllObjects];
                    self.appendDataArray = [NSMutableArray arrayWithArray:[data objectForKey:@"favorites"]];
                    if ([self.appendDataArray count] == 0) {
                        if ([self.favoritesArray count] == 0) {
                            [_corpusNewsTableView reloadData];
                            [self initEmptyView];
                            [self setTwinsMoreViewAnimating:NO];
                            _statusLabel.text = nil;
                            _statusLabel.hidden = YES;
                            [_manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
                            _manageButton.userInteractionEnabled = NO;
                        }
                        else {
                            [self setTwinsMoreViewAnimating:NO];
                            _statusLabel.text = kLoadFinished;
                            _statusLabel.hidden = NO;
                            [_manageButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
                            _manageButton.userInteractionEnabled = YES;
                        }
                    }
                    else {
                        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                        [self.appendDataArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop){
                            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                            if (_chooseAllButton.selected) {
                                [mutableDict setValue:[NSNumber numberWithBool:YES] forKey:kIsSelectedItem];
                            }
                            else {
                                [mutableDict setValue:[NSNumber numberWithBool:NO] forKey:kIsSelectedItem];
                            }
                            [tempArray addObject:mutableDict];
                            //                        [self.appendDataArray replaceObjectAtIndex:idx withObject:mutableDict];
                        }];
                        [self.appendDataArray removeAllObjects];
                        self.appendDataArray = tempArray;
                        
                        
                        [self appendTableWith:self.appendDataArray];
                        [_manageButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
                        _manageButton.userInteractionEnabled = YES;
                    }
                }
            } else if (status == 500) {
                self.favoritesArray = nil;
                
                [self initEmptyView];
                _statusLabel.text = nil;
                _statusLabel.hidden = YES;
            }
            if (self.favoritesArray.count > 0 && _isEditMode) {
                [self showEditView];
            }
            if ( _isOpenFromEmptyCorpus) {
                if (self.favoritesArray.count > 0 && !_isLoadMoreNews) {
                    
                    [self manageButtonAction:_manageButton];
                }
                if (_pageNum == 1) {
                    
                    [_manageButton setTitle:kCorpusCancel forState:UIControlStateNormal];
                    _manageButton.userInteractionEnabled = YES;
                }
            }
        }
        _backView.hidden = YES;
        self.animationImageView.status = SNImageLoadingStatusStopped;
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (_pageNum == 1) {
            self.loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
            self.loadingView.hidden = NO;
        } else {
            self.loadingView.status = SNTripletsLoadingStatusStopped;
            self.loadingView.hidden = YES;
            [self setTwinsMoreViewAnimating:NO];
            _statusLabel.text = kPullLoadMore;
            _statusLabel.hidden = NO;
            _pageNum--;
        }
        _backView.hidden = YES;
        self.animationImageView.status = SNImageLoadingStatusStopped;
    }];
}

#pragma mark Button Click

- (void)openMyCorpus:(id)sender {
    [SNNewsReport reportADotGif:@"act=cc&fun=50&page=6&topage="];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kCorpusMyFavourite, kCorpusFolderName, self.corpusName, kEmptyCorpusName, self.corpusID, kEmptyCorpusID, [NSNumber numberWithBool:YES], kOpenCorpusFromEmpty, nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://corpusList"] applyAnimated:YES] applyQuery:dict];
    [[TTNavigator navigator] openURLAction:_urlAction];
//    [self.emptyView removeFromSuperview];
//    self.emptyView = nil;
}

- (void)manageButtonAction:(id)sender {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:kCorpusManage]) {//管理
        [_manageButton setTitle:kCorpusDown forState:UIControlStateNormal];
        _isEditMode = YES;
        
        [_corpusNewsTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNTableViewCell *cell = (SNTableViewCell *)obj;
            [cell setEditMode];
        }];
        
        [self showEditView];
        
        //统计
        if ([self.corpusName isEqualToString:kCorpusMyFavourite]) {//我的收藏
            [SNNewsReport reportADotGif:@"_act=cc&page=0&topage=&fun=50"];
        }
        else if ([self.corpusName isEqualToString:kCorpusMyShare]) {//我的分享
            [SNNewsReport reportADotGif:@"_act=cc&page=1&topage=&fun=50"];
        }
        else {//自建收藏夹
            [SNNewsReport reportADotGif:@"_act=cc&page=2&topage=&fun=50"];
        }
    }
    else if ([button.titleLabel.text isEqualToString:kCorpusDown]) {//完成
        
        _isEditMode = NO;
        
        [_corpusNewsTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNTableViewCell *cell = (SNTableViewCell *)obj;
            [cell setNormalMode];
            cell.selectButton.selected = NO;
        }];
        
        [self hiddenEditView];
        [self setEditButtonEditMode:NO];
        
        if (_isOpenFromEmptyCorpus) {
            [self.saveList removeObjectForKey:self.emptyCorpusName];
            [self addToAction:_addToButton];
        } else {
            [_manageButton setTitle:kCorpusManage forState:UIControlStateNormal];
        }
        if ([self.favoritesArray count] > 0 && !_isEditMode) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            [self.favoritesArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop){
                NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [mutableDict setValue:[NSNumber numberWithBool:NO] forKey:kIsSelectedItem];
                //                [self.favoritesArray replaceObjectAtIndex:idx withObject:mutableDict];
                [tempArray addObject:mutableDict];
            }];
            [self.favoritesArray removeAllObjects];
            self.favoritesArray = tempArray;

        }

    } else if ([button.titleLabel.text isEqualToString:kCorpusCancel]) {
        if (_isOpenFromEmptyCorpus || _isEditMode) {
            [self.flipboardNavigationController popViewControllerAnimated:YES];
        }
    }
    
}

- (void)chooseAllAction:(id)sender {
    _chooseAllButton.selected = !_chooseAllButton.selected;
    if (_chooseAllButton.selected) {
        [_corpusNewsTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNTableViewCell *cell = (SNTableViewCell *)obj;
            [cell setEditMode];
            cell.selectButton.selected = YES;
        }];
        
        [_chooseAllButton setTitle:kCancelListAll forState:UIControlStateNormal];
        _chooseAllButton.left = kEditAllButtonLeftDiatance;
        [self setEditButtonEditMode:YES];
        
        [self.favoritesArray enumerateObjectsUsingBlock:^(NSMutableDictionary *dict, NSUInteger idx, BOOL *stop){
            [dict setValue:[NSNumber numberWithBool:YES] forKey:kIsSelectedItem];
        }];
    }
    else {
        [_manageButton setTitle:kCorpusCancel forState:UIControlStateNormal];
        [_corpusNewsTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNTableViewCell *cell = (SNTableViewCell *)obj;
            [cell setEditMode];
            cell.selectButton.selected = NO;
        }];
        
        [_chooseAllButton setTitle:kChooseListAll forState:UIControlStateNormal];
        _chooseAllButton.left = kEditAllButtonLeftDiatance - 15;
        [self setEditButtonEditMode:NO];
        
        [self.favoritesArray enumerateObjectsUsingBlock:^(NSMutableDictionary *dict, NSUInteger idx, BOOL *stop){
            [dict setValue:[NSNumber numberWithBool:NO] forKey:kIsSelectedItem];
        }];
    }
}

- (void)addToAction:(id)sender {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    if (self.isOpenFromEmptyCorpus) {//添加到
        [self moveCorpusItem:[NSDictionary dictionaryWithObjectsAndKeys:self.emptyCorpusName ,kCorpusFolderName, self.emptyCorpusID, kCorpusID,  nil]];
        [SNUserDefaults setObject:[NSNumber numberWithBool:YES] forKey:kAddNewsToEmptyCorpusKey];
        return;
    }
    
    [SNCorpusList getCorpusListWithHandler:^(NSArray *corpusArray) {
        if ([corpusArray count] > 0)  {
            self.corpuseAlertObject = [[SNCorpusAlertObject alloc] init];
            self.corpuseAlertObject.entry = @"3";
            self.corpuseAlertObject.corpusListArray = corpusArray;
            self.corpuseAlertObject.delegate = self;
            [self.corpuseAlertObject showCorpusAlertMenu:YES];
        }
    }];
}

- (void)deleteAction:(id)sender {

    SNNewAlertView *delAlert = [[SNNewAlertView alloc] initWithTitle:nil message:kConfirmDeleteNews cancelButtonTitle:@"取消" otherButtonTitle:@"删除"];
    [delAlert show];
    [delAlert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
        [self deleteConfirm];
    }];
}

- (void)deleteConfirm {
    [self setUrlString];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];

    if ([self.corpusName isEqualToString:kCorpusMyFavourite]) {//删除我的收藏下的新闻
        [params setValue:[self.linkString URLDecodedString] forKey:@"contents"];
    }
    else if ([self.corpusName isEqualToString:kCorpusMyShare]) {//删除我的分享下的新闻
        [params setValue:self.corpusID forKey:kCorpusID];
        [params setValue:self.newsIDS forKey:@"fids"];
    }
    else { //删除自定义收藏夹下的新闻
        [params setValue:self.corpusID forKey:kCorpusID];
        [params setValue:self.newsIDS forKey:@"ids"];
    }
    
    [[[SNDeleteCorpusNewsRequest alloc] initWithDictionary:params.copy andCorpusName:self.corpusName] send:^(SNBaseRequest *request, id responseObject) {
        NSString *status = responseObject[@"status"];
        if (status.integerValue == 200) {
            [self deleteLocalFavourite];
            [self.saveList removeObjectForKey:self.corpusName];
            [self refreshTable];
            [SNNotificationManager postNotificationName:kReloadCorpus object:self userInfo:nil];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kDeleteSucceed toUrl:nil mode:SNCenterToastModeSuccess];
            
            if (!_isFromFavoriteManager) {
                [self onBack:self.toolbarView.leftButton];
            } else {
                [self manageButtonAction:_manageButton];
            }
        } else {
           [[SNCenterToast shareInstance] showCenterToastWithTitle:@"删除失败" toUrl:nil mode:SNCenterToastModeError];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"删除失败" toUrl:nil mode:SNCenterToastModeError];
    }];
}

- (void)setUrlString {
    _linkString = nil;
    _newsIDS = nil;
    NSMutableDictionary *newsItemDict = nil;
    NSString *idsString = nil;
    NSString *linkString = nil;
    BOOL isItemSelected = NO;
    for (int i = 0; i < [self.favoritesArray count]; i++) {
        newsItemDict = [self.favoritesArray objectAtIndex:i];
        isItemSelected = [[newsItemDict objectForKey:kIsSelectedItem] boolValue];
        if (isItemSelected) {
            if ([self.corpusName isEqualToString:kCorpusMyFavourite]) {
                linkString = [newsItemDict objectForKey:kLink];
                if (self.linkString) {
                    self.linkString = [self.linkString stringByAppendingString:[NSString stringWithFormat:@",%@",[linkString URLEncodedString]]];
                }
                else {
                    self.linkString = [linkString URLEncodedString];
                }
            }
            else {
                idsString = [newsItemDict stringValueForKey:@"fid" defaultValue:nil];
                if (self.newsIDS) {
                    self.newsIDS = [self.newsIDS stringByAppendingString:[NSString stringWithFormat:@",%@",idsString]];
                }
                else {
                    self.newsIDS = idsString;
                }
            }
        }
    }
 
}

- (void)setEditButtonEditMode:(BOOL)isEditMode {
    if (isEditMode) {
        
        [SNCorpusList getCorpusListWithHandler:^(NSArray *corpusArray) {

            if ([corpusArray count] == 0) {
                _addToButton.userInteractionEnabled = NO;
                [_addToButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
                if (_isOpenFromEmptyCorpus) {
                    [_manageButton setTitle:kCorpusCancel forState:UIControlStateNormal];
                }
            }
            else {
                _addToButton.userInteractionEnabled = YES;
                [_addToButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
                if (_isOpenFromEmptyCorpus) {
                    [_manageButton setTitle:kCorpusDown forState:UIControlStateNormal];
                }
            }

        }];
        
        _deleteButton.userInteractionEnabled = YES;
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    }
    else {
        [_chooseAllButton setTitle:kChooseListAll forState:UIControlStateNormal];
        _chooseAllButton.left = kEditAllButtonLeftDiatance - 15;
        _addToButton.userInteractionEnabled = NO;
        [_addToButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
        _deleteButton.userInteractionEnabled = NO;
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    }
}

- (void)showEditView {
    if (nil == _editTabBarView) {
        [self initEditTabBarView];
    }
    [UIView animateWithDuration:0.2 animations:^(void){
        _editTabBarView.top = kAppScreenHeight - kEditTabBarHeight - kEditTabBariPhoneXOffset;
    }];
}

- (void)hiddenEditView {
    _chooseAllButton.selected = NO;
    [UIView animateWithDuration:0.2 animations:^(void){
        _editTabBarView.top = kAppScreenHeight;
    }];
}

#pragma mark UITableView delagate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    NSDictionary *newsItemDict = [self.favoritesArray objectAtIndex:row];
    if ([self.corpusName isEqualToString:kCorpusMyInclude]) {
        return [self calculateNewsGrabCellHeight:newsItemDict];
    }
    NSString *newsType = [newsItemDict stringValueForKey:kNewsType defaultValue:nil];
    NSString *newsTitle = [newsItemDict stringValueForKey:kTitle defaultValue:nil];
    NSString *templateType = [newsItemDict stringValueForKey:kTemplateType defaultValue:@""];
    
    id imageUrlobjc = [newsItemDict objectForKey:kSNCorpusImageUrl];
    if ([imageUrlobjc isKindOfClass:[NSArray class]]) {
        self.imageUrlArray = [newsItemDict objectForKey:kSNCorpusImageUrl];
    }
    if ([newsType isEqualToString:@"3"] && [self.imageUrlArray count] > 1) {//服务端下发图片数大于1的，则用组图样式显示
        newsType = @"4";
    }
    
    if (([self.imageUrlArray isKindOfClass:[NSArray class]] && [self.imageUrlArray count] == 0) || [newsType isEqualToString:kNewsTypePaper] || [newsType isEqualToString:kNewsTypeVoteNews]) {//纯文本新闻,期刊，投票
        return [SNCorpusTitleCell getCellHeight:newsTitle];
    } else if ([newsType isEqualToString:kNewsTypeRollingFunnyText]) {
        return [SNCorpusJokeCell getCellHeightWithDic:newsItemDict];
    } else if (([self.imageUrlArray count] == 1 || [newsType isEqualToString:kNewsTypePhotoAndText] || [newsType isEqualToString:kNewsTypeVideo] || [newsType isEqualToString:kSNVoteWeiwenType]) && ![newsType isEqualToString:kNewsTypeRollingVideo]) {//图文新闻/视频新闻/微博
        return [SNCorpusPhotoAndTitleCell getCellHeight:newsTitle isEditMode:_isEditMode];
    } else if ([self.imageUrlArray count] == 3 || [newsType isEqualToString:kNewsTypeGroupPhoto]) {//组图
        return [SNCorpusPhotosCell getCellHeight:newsTitle];
    } else if ([templateType isEqualToString:kNewsTypeRollingBigVideo]) {//视频大图模式
        return [SNCorpusRollingBigVideoCell getCellHeight:newsTitle];
    } else if ([templateType isEqualToString:kNewsTypeRollingMiddleVideo]) {//视频中图模式
        return [SNCorpusRollingMiddleVideoCell getCellHeight];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self setEditButtonStatus:self.favoritesArray.count > 0];
    if (self.favoritesArray.count > 0) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
    return [self.favoritesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    static NSString * cellIdentifier = nil;
    NSDictionary *newsItemDict = [NSDictionary dictionary];
    if (self.favoritesArray.count > row) {
        newsItemDict = [self.favoritesArray objectAtIndex:row];
    }
    if ([self.corpusName isEqualToString:kCorpusMyInclude]) {
        return [self newsGrabCellForRow:newsItemDict cellIdentifier:cellIdentifier tableView:tableView];
    }
    
    NSString *idsString = [newsItemDict stringValueForKey:@"fid" defaultValue:nil];
    NSString *linkString = [[newsItemDict objectForKey:kLink] URLEncodedString];
    NSString *newsType = [newsItemDict stringValueForKey:kNewsType defaultValue:nil];
    NSString *templateType = [newsItemDict stringValueForKey:kTemplateType defaultValue:@""];
    
    BOOL hasTV = [[newsItemDict stringValueForKey:kHasTV defaultValue:nil] boolValue];
    BOOL isItemSelected = [[newsItemDict stringValueForKey:kIsSelectedItem defaultValue:nil] boolValue];
    id imageUrlobjc = [newsItemDict objectForKey:kSNCorpusImageUrl];
    if ([imageUrlobjc isKindOfClass:[NSArray class]]) {
        self.imageUrlArray = [newsItemDict objectForKey:kSNCorpusImageUrl];
    }
    if ([newsType isEqualToString:@"3"] && [self.imageUrlArray count] > 1) {//服务端下发图片数大于1的，则用组图样式显示
        newsType = @"4";
    }
    NSString *title = [newsItemDict stringValueForKey:kSNTitle defaultValue:nil];
    
    NSString *time = [newsItemDict stringValueForKey:kSNCorpusCollectTime defaultValue:nil];
    NSString *tvPlayTime = [newsItemDict stringValueForKey:@"tvPlayTime" defaultValue:@""];
    if (([self.imageUrlArray isKindOfClass:[NSArray class]] && [self.imageUrlArray count] == 0) || [newsType isEqualToString:kNewsTypePaper] || [newsType isEqualToString:kNewsTypeVoteNews]) {//纯文本新闻,期刊，投票
        cellIdentifier = @"cellTextIdentifier";
        SNCorpusTitleCell *cell = (SNCorpusTitleCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusTitleCell *)[[SNCorpusTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell setCellInfoWithTitle:title time:time ids:idsString isEditMode:_isEditMode link:linkString isItemSelected:isItemSelected  hideStateView:![self.corpusName isEqualToString:kCorpusMyInclude] status:nil remark:nil];
        
        return cell;
    }
    
    else if([newsType isEqualToString:kNewsTypeRollingFunnyText]){
        cellIdentifier = @"cellCorpusJokeIdentifier";
        SNCorpusJokeCell *cell = (SNCorpusJokeCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusJokeCell *)[[SNCorpusJokeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier withDic:newsItemDict];
            cell.tableView = tableView;
            cell.indexPath = indexPath;
        }
        [cell setCellInfoWithInfoDic:newsItemDict time:time ids:idsString isEditMode:_isEditMode link:linkString isItemSelected:isItemSelected];
        
        return cell;
    }
    else if (([self.imageUrlArray count] == 1 || [newsType isEqualToString:kNewsTypePhotoAndText] || [newsType isEqualToString:kNewsTypeVideo] || [newsType isEqualToString:kSNVoteWeiwenType]) && ![newsType isEqualToString:kNewsTypeRollingVideo]) {//图文新闻/视频新闻/微博
        cellIdentifier = @"cellPhotoTextIdentifier";
        SNCorpusPhotoAndTitleCell *cell = (SNCorpusPhotoAndTitleCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusPhotoAndTitleCell *)[[SNCorpusPhotoAndTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSString *url = nil;
        if ([self.imageUrlArray count] > 0) {
            url = [self.imageUrlArray objectAtIndex:0];
            if ([url isEqual:[NSNull null]]) {
                url = nil;
            }
        }
        
        [cell setCellInfoWithUrl:url newsType:newsType title:title time:time ids:idsString isEditMode:_isEditMode link:linkString hasTV:hasTV isItemSelected:isItemSelected hideStateView:![self.corpusName isEqualToString:kCorpusMyInclude] status:nil remark:nil];
        
        return cell;
    }
    else if ([self.imageUrlArray count] == 3 || [newsType isEqualToString:kNewsTypeGroupPhoto]) {//组图
        cellIdentifier = @"cellPhotosIdentifier";
        SNCorpusPhotosCell *cell = (SNCorpusPhotosCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusPhotosCell *)[[SNCorpusPhotosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell setCellInfoWithUrlArray:self.imageUrlArray newsType:newsType title:title time:time ids:idsString isEditMode:_isEditMode link:linkString isItemSelected:isItemSelected hideStateView:![self.corpusName isEqualToString:kCorpusMyInclude] status:nil remark:nil];
        
        return cell;
    }
    else if ([templateType isEqualToString:kNewsTypeRollingBigVideo]) {//视频大图模式
        cellIdentifier = @"cellRollingBigVideoIdentifier";
        SNCorpusRollingBigVideoCell *cell = (SNCorpusRollingBigVideoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusRollingBigVideoCell *)[[SNCorpusRollingBigVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSString *url = nil;
        if ([self.imageUrlArray count] > 0) {
            url = [self.imageUrlArray objectAtIndex:0];
            if ([url isEqual:[NSNull null]]) {
                url = nil;
            }
        }
        [cell setCellInfoWithUrl:url newsType:newsType title:title time:time ids:idsString isEditMode:_isEditMode link:linkString videoID:[newsItemDict stringValueForKey:@"vid" defaultValue:@""] site:[newsItemDict stringValueForKey:@"site" defaultValue:@""] tvPlayTime:tvPlayTime isItemSelected:isItemSelected];
        
        return cell;
    }
    else if ([templateType isEqualToString:kNewsTypeRollingMiddleVideo]) {//视频中图模式
        cellIdentifier = @"cellRollingMiddleVideoIdentifier";
        SNCorpusRollingMiddleVideoCell *cell = (SNCorpusRollingMiddleVideoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusRollingMiddleVideoCell *)[[SNCorpusRollingMiddleVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSString *url = nil;
        if ([self.imageUrlArray count] > 0) {
            url = [self.imageUrlArray objectAtIndex:0];
            if ([url isEqual:[NSNull null]]) {
                url = nil;
            }
        }
        [cell setCellInfoWithUrl:url newsType:newsType title:title time:time ids:idsString isEditMode:_isEditMode link:linkString videoID:[newsItemDict stringValueForKey:@"vid" defaultValue:@""] site:[newsItemDict stringValueForKey:@"site" defaultValue:@""] tvPlayTime:tvPlayTime isItemSelected:isItemSelected];
        
        return cell;
    } else {
        
        return [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SNTableViewCell *cell = (SNTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[SNCorpusRollingBigVideoCell class]] || [cell isKindOfClass:[SNCorpusRollingMiddleVideoCell class]]) {
        [SNNotificationManager postNotificationName:kCorpusVideoPlay object:nil];
    }
    [SNUtility shouldUseSpreadAnimation:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isEditMode) {
        SNTableViewCell *cell = (SNTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dict = nil;
        if (self.favoritesArray.count > indexPath.row) {
            dict = [self.favoritesArray objectAtIndexWithRangeCheck:indexPath.row];
        } else {
            return;
        }
        BOOL selected = ![[dict objectForKey:kIsSelectedItem] boolValue];
        cell.selectButton.selected = selected;
        [dict setObject:[NSNumber numberWithBool:selected] forKey:kIsSelectedItem];
        BOOL isSelectOneItem = NO;
        BOOL isSelectAllItem = YES;
        for (int i = 0; i < [self.favoritesArray count]; i++) {
            NSMutableDictionary *mDict = [self.favoritesArray objectAtIndexWithRangeCheck:i];
            if ([[mDict objectForKey:kIsSelectedItem] boolValue]) {
                _deleteButton.userInteractionEnabled = YES;
                [_deleteButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
                isSelectOneItem = YES;
                [self setEditButtonEditMode:YES];
            }
            else {
                [_chooseAllButton setTitle:kChooseListAll forState:UIControlStateNormal];
                _chooseAllButton.left = kEditAllButtonLeftDiatance - 15;
                _chooseAllButton.selected = NO;
            }
        }
        
        for (int i = 0; i < [self.favoritesArray count]; i++) {
            NSMutableDictionary *mDict = [self.favoritesArray objectAtIndexWithRangeCheck:i];
            if (![[mDict objectForKey:kIsSelectedItem] boolValue]) {
                isSelectAllItem = NO;
            }
        }
        
        if (![_chooseAllButton.titleLabel.text isEqualToString:kChooseListAll] || isSelectAllItem) {
            [_chooseAllButton setTitle:kCancelListAll forState:UIControlStateNormal];
            _chooseAllButton.left = kEditAllButtonLeftDiatance;
            _chooseAllButton.selected = YES;
        }
        
        if (!isSelectOneItem) {
            [_manageButton setTitle:kCorpusCancel forState:UIControlStateNormal];
            _addToButton.userInteractionEnabled = NO;
            [_addToButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
            _deleteButton.userInteractionEnabled = NO;
            [_deleteButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
        }
        
        return;
    }
    
    //进正文页
    if (self.favoritesArray.count > 0) {
        
        NSDictionary *infoDict = [self.favoritesArray objectAtIndexWithRangeCheck:[indexPath row]];
        NSString *linkString = [infoDict objectForKey:kLink];
        NSString *newsType = [infoDict stringValueForKey:kNewsType defaultValue:nil];
        if (newsType && [newsType isEqualToString:@"61"]) {
            return;
        }
        self.linkString = [linkString URLEncodedString];
        
        [SNUtility openProtocolUrl:linkString];
        
        [SNUserDefaults setObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row] forKey:kSelectedIteRowNum];
        
        if ([SNUserDefaults objectForKey:kIsCancelCollectTag]) {
            [SNUserDefaults removeObjectForKey:kIsCancelCollectTag];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.favoritesArray count] - 1 && self.favoritesArray.count > kCorpusListCount / 2) {
        if ([_statusLabel.text isEqualToString:kLoadFinished]) {
            return;
        }
        [self loadMoreNews];
    }
}

- (void)autoPlayVideoWithNetWifi {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self settingCellVideoWithVisibleIndexpaths:self.corpusNewsTableView.indexPathsForVisibleRows];
    });
}

- (void)settingCellVideoWithVisibleIndexpaths:(NSArray *)visibleIndexpaths {
    NetworkStatus networkStatus = [[SNUtility getApplicationDelegate] currentNetworkStatus];
    if (_isEditMode || !([SNUtility channelVideoSwitchStatus] && (networkStatus == ReachableViaWiFi))) return;
    if ([visibleIndexpaths containsObject:self.currentPlayIndex] && [self autoPlayCellVisibleInScreen:self.currentPlayIndex]) {
        return;
    } else {
        self.currentPlayIndex = nil;
        [self settingVideoStatus];
    }
    for (NSIndexPath *indexPath in visibleIndexpaths) {
        UITableViewCell *cell = [self.corpusNewsTableView cellForRowAtIndexPath:indexPath];
        if (![self autoPlayCellVisibleInScreen:indexPath]) continue;

        if ([cell isKindOfClass:[SNCorpusRollingBigVideoCell class]]) {
            SNCorpusRollingBigVideoCell *bigCell = (SNCorpusRollingBigVideoCell *)cell;
            SHMedia *media = [[SNAutoPlaySharedVideoPlayer sharedInstance] getMoviePlayer].currentPlayMedia;
            if ( [media.vid isEqualToString:bigCell.videoID]) {
                [bigCell stopPlayVideo];
            }
            if (![media.vid isEqualToString:bigCell.videoID]) {
                [bigCell stopPlayVideo];
            }
            self.currentPlayIndex = indexPath;
            [bigCell autoPlayVideo];
            break;
        }
        else if ([cell isKindOfClass:[SNCorpusRollingMiddleVideoCell class]]) {

            SNCorpusRollingMiddleVideoCell *middleCell = (SNCorpusRollingMiddleVideoCell *)cell;
            SHMedia *media = [[SNAutoPlaySharedVideoPlayer sharedInstance] getMoviePlayer].currentPlayMedia;
            if (  [media.vid isEqualToString:middleCell.videoID]) {
                [middleCell stopPlayVideo];
            }
            if (![media.vid isEqualToString:middleCell.videoID] ) {
                [middleCell stopPlayVideo];
            }
            self.currentPlayIndex = indexPath;
            [middleCell autoPlayVideo];
            break;
        }
    }
}

- (BOOL)autoPlayCellVisibleInScreen:(NSIndexPath *)indexPath {
    CGRect rectInTableView = [self.corpusNewsTableView rectForRowAtIndexPath:indexPath];
    CGRect currentRect = [self.corpusNewsTableView convertRect:rectInTableView toView:self.view];
    CGFloat currentCellHeight = currentRect.size.height;
    int playerMinBottom = currentRect.origin.y + currentCellHeight;
//    NSLog(@"getCellRectInSuperView___%d",playerMinBottom); 
    if (playerMinBottom > currentCellHeight*3/5 && playerMinBottom < (self.corpusNewsTableView.frame.size.height + currentCellHeight*3/5 - kHeaderTotalHeight)) {
        return YES;
    }
    return NO;
}

- (void)settingVideoStatus {
    [SNAutoPlaySharedVideoPlayer forceStopVideo];
}

- (void)refreshTable {
    NSArray *dataArray = nil;
    if ([self.corpusName isEqualToString:kCorpusMyFavourite]) {
        dataArray = [self.linkString componentsSeparatedByString:NSLocalizedString(@",", nil)];
        if ([dataArray count] > 0) {
            for (NSString *link in dataArray) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.favoritesArray];
                int i = 0;
                while (i < [self.favoritesArray count]) {
                    NSMutableDictionary *mutaDict = [self.favoritesArray objectAtIndex:i];
                    if ([[[mutaDict objectForKey:kLink] URLEncodedString] isEqualToString:link]) {
                        [tempArray removeObjectAtIndex:i];
                    }
                    i++;
                }
                
                self.favoritesArray = [NSMutableArray arrayWithArray:tempArray];
            }
        }
    }
    else {
        dataArray = [self.newsIDS componentsSeparatedByString:NSLocalizedString(@",", nil)];
        if ([dataArray count] > 0) {
            for (NSString *fid in dataArray) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.favoritesArray];
                int i = 0;
                while (i < [self.favoritesArray count]) {
                    NSMutableDictionary *mutaDict = [self.favoritesArray objectAtIndex:i];
                    NSString *fidStr = [mutaDict stringValueForKey:@"fid" defaultValue:nil];
                    if ([fidStr isEqualToString:fid]) {
                        [tempArray removeObjectAtIndex:i];
                    }
                    i++;
                }
                
                self.favoritesArray = [NSMutableArray arrayWithArray:tempArray];
            }
        }
    }
    
    if ([self.favoritesArray count] == 0) {
        if (_pageNum > 1) {//页码大于1时,重新请求数据时应重置为1
            _pageNum = 1;
        }
        [self getCorpusNewsList];
    }
    else {
        [_corpusNewsTableView reloadData];
        [self autoPlayVideoWithNetWifi];

    }
}

- (void)loadMoreNews {
    _isLoadMoreNews = YES;

    [self setTwinsMoreViewAnimating:YES];
    _statusLabel.text = nil;
    _statusLabel.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _pageNum++;
        [self getCorpusNewsList];
    });
}

- (void)appendTableWith:(NSMutableArray *)dataArray {
    for (int i = 0; i < [dataArray count]; i++) {
        [self.favoritesArray addObject:[dataArray objectAtIndex:i]];
    }

    if (self.favoritesArray.count > 0) {
        [_corpusNewsTableView reloadData];
        [self setTwinsMoreViewAnimating:NO];
    }
}

#pragma mark UIScrollView delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height)) {
        //loading more
        if ([_statusLabel.text isEqualToString:kLoadFinished]) {
            return;
        }
        [self loadMoreNews];
    }
    if ([_statusLabel.text isEqualToString:kLoadFinished] || ([_statusLabel.text isEqualToString:kPullLoadMore] && ![[SNUtility getApplicationDelegate] isNetworkReachable])) {
        [self autoPlayVideoWithNetWifi];
        return;
    }
    [self autoPlayVideoWithNetWifi];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self autoPlayVideoWithNetWifi];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self autoPlayVideoWithNetWifi];
}


#pragma mark - SNTripletsLoadingViewDelegate

-(void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    //    self.loadingView.status = SNTripletsLoadingStatusLoading;
    self.loadingView.hidden = YES;
    _backView.hidden = NO;
    self.animationImageView.status = SNImageLoadingStatusLoading;
    [self setEditButtonStatus:NO];
    [self getCorpusNewsList];
}


#pragma mark - SNClickItemOnHalfViewDelegate
- (void)clikItemOnHalfFloatView:(NSDictionary *)dict {
    [self moveCorpusItem:dict];
}

- (void)moveCorpusItem:(NSDictionary *)dict {
    _newsIDS = nil;
    self.moveToCorpusID = [dict objectForKey:kCorpusID];
    self.moveToCorpusName = [dict objectForKey:kCorpusFolderName];
    NSMutableDictionary *newsItemDict = nil;
    NSString *idsString = nil;
    BOOL isItemSelected = NO;
    for (int i = 0; i < [self.favoritesArray count]; i++) {
        newsItemDict = [self.favoritesArray objectAtIndex:i];
        isItemSelected = [[newsItemDict objectForKey:kIsSelectedItem] boolValue];
        if (isItemSelected) {
            idsString = [newsItemDict stringValueForKey:@"fid" defaultValue:nil];
            if (self.newsIDS) {
                self.newsIDS = [self.newsIDS stringByAppendingString:[NSString stringWithFormat:@",%@",idsString]];
            }
            else {
                self.newsIDS = idsString;
            }
        }
    }

    if (self.newsIDS.length <= 0) return;
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];

    [params setValue:self.moveToCorpusID forKey:@"corpusId"];

    [params setValue:self.newsIDS forKey:@"ids"];
    if (![self.corpusID isEqualToString:@"0"]) {
        [params setValue:self.corpusID forKey:@"old"];
    }

    [[[SNCorpusBatchMoveRequest alloc] initWithDictionary:params.copy] send:^(SNBaseRequest *request, id responseObject) {
        NSString *status = responseObject[@"status"];
        if (status.integerValue == 200) {
            if (!self.isOpenFromEmptyCorpus) {
                [SNUtility showToastWithID:self.moveToCorpusID folderName:self.moveToCorpusName];
            }
            [self.saveList removeObjectForKey:self.moveToCorpusName];
            
            [SNNotificationManager postNotificationName:kReloadCorpus object:self userInfo:nil];
            
            if (!_isFromFavoriteManager) {
                
                [self onBack:self.toolbarView.leftButton];
            } else {
                [self manageButtonAction:_manageButton];
            }
        }

    } failure:nil];
}

+ (void)clearData {
    kSaveList = nil;
}

- (NSMutableDictionary *)saveList {
    if (!kSaveList) {
        kSaveList = [NSMutableDictionary dictionary];
    }
    return kSaveList;
}


//删除本地数据
- (void)deleteLocalFavourite {
    NSArray *dataArray = nil;
    SNCloudSave *cloudSaveFavourite = [[SNCloudSave alloc] init];
    if ([self.corpusName isEqualToString:kCorpusMyFavourite]) {
        dataArray = [self.linkString componentsSeparatedByString:NSLocalizedString(@",", nil)];
        if ([dataArray count] > 0) {
            for (__strong NSString *link in dataArray) {
                NSArray *array = [[link URLDecodedString] componentsSeparatedByString:@"&"];
                NSMutableString *mulLink = [link URLDecodedString].mutableCopy;
                if ([array count] > 0) {
                    mulLink = [array objectAtIndex:0];
                }
                cloudSaveFavourite._link = mulLink;
                [[SNDBManager currentDataBase] deleteMyCloudSave:cloudSaveFavourite];
            }
        }
    }
}


#pragma mark - NSNotification
- (void)moveCorpusItemNotification:(NSNotification *)notification {
    [self moveCorpusItem:notification.userInfo];
}

- (void)videoAutoPlay:(NSNotification *)noti {
    if ([noti.object isEqualToString:self.corpusName]) {
        self.currentPlayIndex = nil;
        [self autoPlayVideoWithNetWifi];
    }
}


- (SNTwinsMoreView *)twinsMoreView {
    if (!_twinsMoreView) {
        CGRect twinsMoreViewRect = CGRectMake(0, 0, kAppScreenWidth, 52.0);
        
        _tableFootView = [[UIView alloc] initWithFrame:twinsMoreViewRect];
        _tableFootView.backgroundColor = [UIColor clearColor];
        _corpusNewsTableView.tableFooterView = _tableFootView;
        
        SNTwinsMoreView *twinsMoreView = [[SNTwinsMoreView alloc] initWithFrame:twinsMoreViewRect];
        _twinsMoreView = twinsMoreView;
        _twinsMoreView.hidden = NO;
        [_tableFootView addSubview:_twinsMoreView];
        
        _statusLabel = [[UILabel alloc] initWithFrame:twinsMoreViewRect];
        _statusLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = SNUICOLOR(kThemeText3Color);
        _statusLabel.hidden = YES;
        [_tableFootView addSubview:_statusLabel];
    }
    return _twinsMoreView;
}

- (void)updateTheme:(NSNotification *)notifiction {
    [super updateTheme:notifiction];
    self.view.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    _tableFootView.backgroundColor = SNUICOLOR(kBackgroundColor);
    _statusLabel.textColor = SNUICOLOR(kThemeText3Color);
    
    [_manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    
    _editTabBarView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    UIImage *chooseAllImge = [UIImage imageNamed:@"ico_weiquanxuan_v5.png"];
    UIImage *choosedAllImage = [UIImage imageNamed:@"ico_quanxuan_v5.png"];
    [_chooseAllButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    [_chooseAllButton setImage:chooseAllImge forState:UIControlStateNormal];
    [_chooseAllButton setImage:choosedAllImage forState:UIControlStateSelected];
    [_loginButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    _loginLabel.textColor = SNUICOLOR(kThemeText3Color);
}

- (SNTripletsLoadingView *)loadingView {
    if (!_loadingView) {
        SNTripletsLoadingView *loadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, -kHeaderTotalHeight, kAppScreenWidth, kAppScreenHeight)];
        _loadingView = loadingView;
        _loadingView.delegate = self;
        [self.view addSubview:_loadingView];
    }
    return _loadingView;
}

- (SNLoadingImageAnimationView *)animationImageView {
    if (_isEditMode) {
        return nil;
    }
    if (!_backView) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, -kHeaderTotalHeight, kAppScreenWidth, kAppScreenHeight)];
        _backView = backView;
        _backView.userInteractionEnabled = NO;
        _backView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_backView];
    }
    if (!_animationImageView) {
        SNLoadingImageAnimationView *animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView = animationImageView;
        _animationImageView.targetView = _backView;
    }
    
    return _animationImageView;
}

- (void)setTwinsMoreViewAnimating:(BOOL)animating {
    if (animating) {
        self.twinsMoreView.status = SNTwinsMoreStatusLoading;
    }
    else {
        self.twinsMoreView.status = SNTwinsMoreStatusStop;
        
    }
    self.twinsMoreView.hidden = !animating;
}


- (void)setEditButtonStatus:(BOOL)enabled {
    UIViewController *topVc = [TTNavigator navigator].topViewController;
    if ([topVc isKindOfClass:[SNFavoriteViewController class]]) {
        SNFavoriteViewController *favoriteVc = (SNFavoriteViewController *)topVc;
        favoriteVc.editEnabled = enabled;
    }
}


- (void)dealloc {
    _twinsMoreView.status = SNTwinsMoreStatusStop;
    [_twinsMoreView removeFromSuperview];
    [SNNotificationManager removeObserver:self];
}

#pragma mark - 处理我的录入返回数据
- (void)handleNewsGrabData:(id)response {
    NSDictionary *data = [response objectForKey:@"response"];
    if (_pageNum == 1) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
        self.favoritesArray = array;
        [_corpusNewsTableView reloadData];
        if ([self.favoritesArray count] != 0) {
            if (self.favoritesArray.count < kCorpusListCount / 2) {
                [self setTwinsMoreViewAnimating:NO];
                _statusLabel.text = kLoadFinished;
                _statusLabel.hidden = NO;
                
            }
        } else {
            [self initEmptyView];
            [self setTwinsMoreViewAnimating:NO];
            _statusLabel.text = nil;
            _statusLabel.hidden = YES;
        }
    } else {
        self.appendDataArray = [NSMutableArray arrayWithArray:[data objectForKey:@"list"]];
        if ([self.appendDataArray count] == 0) {
            if ([self.favoritesArray count] == 0) {
                [_corpusNewsTableView reloadData];
                [self initEmptyView];
                [self setTwinsMoreViewAnimating:NO];
                _statusLabel.text = nil;
                _statusLabel.hidden = YES;
            } else {
                [self setTwinsMoreViewAnimating:NO];
                _statusLabel.text = kLoadFinished;
                _statusLabel.hidden = NO;
            }
        } else {
            [self appendTableWith:self.appendDataArray];
        }
    }
    _backView.hidden = YES;
    self.animationImageView.status = SNImageLoadingStatusStopped;
}

- (CGFloat)calculateNewsGrabCellHeight:(NSDictionary *)newsItemDict {
    
    NSString *newsType = [newsItemDict stringValueForKey:kNewsType defaultValue:nil];
    NSString *newsTitle = [newsItemDict stringValueForKey:kTitle defaultValue:nil];
    NSString *templateType = [newsItemDict stringValueForKey:kTemplateType defaultValue:@""];
    NSString *url = [newsItemDict stringValueForKey:@"url" defaultValue:@""];
    
    id imageUrlobjc = [newsItemDict objectForKey:@"imageList"];
    if ([imageUrlobjc isKindOfClass:[NSArray class]]) {
        self.imageUrlArray = [newsItemDict objectForKey:@"imageList"];
    } else {
        self.imageUrlArray = nil;
    }
//    if ([newsType isEqualToString:@"3"] && [self.imageUrlArray count] > 1) {//服务端下发图片数大于1的，则用组图样式显示
//        newsType = @"4";
//    }
    NSString *showTitle = newsTitle;
    if (newsTitle.length <= 0 || [newsTitle isEqualToString:@""]) {
        showTitle = url;
    }
    if (([self.imageUrlArray isKindOfClass:[NSArray class]] && [self.imageUrlArray count] == 0) || !self.imageUrlArray) {//纯文本新闻,期刊，投票
        return [SNCorpusTitleCell getCellHeight:showTitle];
    } else if ([self.imageUrlArray count] <= 2) {//图文新闻/视频新闻/微博
        return [SNCorpusPhotoAndTitleCell getCellHeight:showTitle isEditMode:_isEditMode];
    } else if ([self.imageUrlArray count] == 3) {//组图
        return [SNCorpusPhotosCell getCellHeight:showTitle];
    } else {
        return 0;
    }
}

- (UITableViewCell *)newsGrabCellForRow:(NSDictionary *)newsItemDict cellIdentifier:(NSString *)cellIdentifier tableView:(UITableView *)tableView {
    
    NSString *linkString = [[newsItemDict objectForKey:kLink] URLEncodedString]; // link
    NSString *newsType = [newsItemDict stringValueForKey:kNewsType defaultValue:nil];
    NSString *templateType = [newsItemDict stringValueForKey:kTemplateType defaultValue:@""];
    NSString *newsTitle = [newsItemDict stringValueForKey:kTitle defaultValue:nil]; // 标题
    NSString *originalUrl = [newsItemDict stringValueForKey:@"url" defaultValue:@""]; // 收录的原url
    NSString *status = [newsItemDict stringValueForKey:@"status" defaultValue:nil]; // 审核状态
    NSString *remark = [newsItemDict stringValueForKey:@"remark" defaultValue:nil]; // 审核信息
    NSString *time = [newsItemDict stringValueForKey:@"ctime" defaultValue:nil]; // 收录时间
    id imageUrlobjc = [newsItemDict objectForKey:@"imageList"]; // images
    if ([imageUrlobjc isKindOfClass:[NSArray class]]) {
        self.imageUrlArray = [newsItemDict objectForKey:@"imageList"];
    } else {
        self.imageUrlArray = nil;
    }
    NSString *showTitle = newsTitle;
    if (newsTitle.length <= 0 || [newsTitle isEqualToString:@""]) {
        showTitle = originalUrl;
    }
    
    if (([self.imageUrlArray isKindOfClass:[NSArray class]] && [self.imageUrlArray count] == 0) || !self.imageUrlArray) {//纯文本新闻,期刊，投票
        cellIdentifier = @"cellTextIdentifier";
        SNCorpusTitleCell *cell = (SNCorpusTitleCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusTitleCell *)[[SNCorpusTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setCellInfoWithTitle:showTitle time:time ids:nil isEditMode:_isEditMode link:linkString isItemSelected:NO  hideStateView:![self.corpusName isEqualToString:kCorpusMyInclude] status:status remark:remark];
        return cell;
    } else if ([self.imageUrlArray count] <= 2) {//图文新闻/视频新闻/微博
        cellIdentifier = @"cellPhotoTextIdentifier";
        SNCorpusPhotoAndTitleCell *cell = (SNCorpusPhotoAndTitleCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusPhotoAndTitleCell *)[[SNCorpusPhotoAndTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSString *url = nil;
        if ([self.imageUrlArray count] > 0) {
            url = [self.imageUrlArray objectAtIndex:0];
            if ([url isEqual:[NSNull null]]) {
                url = nil;
            }
        }
        [cell setCellInfoWithUrl:url newsType:newsType title:showTitle time:time ids:nil isEditMode:_isEditMode link:linkString hasTV:NO isItemSelected:NO hideStateView:![self.corpusName isEqualToString:kCorpusMyInclude] status:status remark:remark];
        return cell;
    } else if ([self.imageUrlArray count] == 3) {//组图
        cellIdentifier = @"cellPhotosIdentifier";
        SNCorpusPhotosCell *cell = (SNCorpusPhotosCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = (SNCorpusPhotosCell *)[[SNCorpusPhotosCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell setCellInfoWithUrlArray:self.imageUrlArray newsType:newsType title:showTitle time:time ids:nil isEditMode:_isEditMode link:linkString isItemSelected:NO hideStateView:![self.corpusName isEqualToString:kCorpusMyInclude] status:status remark:remark];
        return cell;
    } else {
        return nil;
    }
}

@end
