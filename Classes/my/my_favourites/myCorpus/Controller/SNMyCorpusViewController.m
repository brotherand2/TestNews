//
//  SNMyCorpusViewController.m
//  sohunews
//
//  Created by yangln on 15/8/26.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNMyCorpusViewController.h"
#import "SNCorpusTableViewCell.h"
#import "SNTripletsLoadingView.h"
#import "SNLoadingImageAnimationView.h"
#import "SNCorpusList.h"
#import "SNCorpusListRequest.h"

#define kNormalDistance 33/2.0
#define kLoginBetweenDistance 12/2.0
#define kCorpusTableViewTopDistance ((kAppScreenWidth > 375.0) ? 28.0/3 : 15.0/2)
#define kLoginButtonFont ((kAppScreenWidth == 320.0) ? kThemeFontSizeC : kThemeFontSizeD)

@interface SNMyCorpusViewController () <UITableViewDataSource, UITableViewDelegate, SNTripletsLoadingViewDelegate, SNCorpusTableViewCellDelegate>{
    UIButton *_manageButton;
    UIButton *_loginButton;
    UILabel *_loginLabel;
    CGFloat _corpusTableHeight;
    BOOL _isEditMode;
    BOOL _isOpenCreatCorpus;
    BOOL _isKeyboardHidden;
    BOOL _isViewDisappear;
    BOOL _is3DTouch;
}


@property (nonatomic, weak)UITableView *corpusTableView;

@property (nonatomic, strong)NSMutableArray *corpusImageArray;
@property (nonatomic, strong)NSMutableArray *corpusTextArray;
@property (nonatomic, strong)NSMutableArray *corpusIDArray;
@property (nonatomic, strong)NSMutableArray *colorTypeArray;

@property (nonatomic, weak)SNTripletsLoadingView *loadingView;
@property (nonatomic, weak)SNLoadingImageAnimationView *animationImageView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation SNMyCorpusViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        if ([[query objectForKey:kIs3DTouchOpen] boolValue]) {
            _is3DTouch = YES;
        } else {
            _is3DTouch = NO;
        }
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.corpusImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.corpusTextArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.corpusIDArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.colorTypeArray = [[NSMutableArray alloc] initWithCapacity:0];

    [self initCorpusTableView];
    self.loadingView.status = SNTripletsLoadingStatusStopped;
    self.loadingView.hidden = YES;
    self.animationImageView.status = SNImageLoadingStatusLoading;
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObjects:kCorpusFavoritesManage, nil]];
    CGSize titleSize = [kCorpusFavoritesManage sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    [self initManageButton];
    [self addToolbar];
    
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(receivePushNotification:) name:kNotifyDidReceive object:nil];
    [SNNotificationManager addObserver:self selector:@selector(receivePushNotification:) name:kOpenNewsFromWidgetNotification object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(resetToolBarOrigin)
                                  name:UIApplicationWillChangeStatusBarFrameNotification
                                object:nil];
    //从3DTouch 启动 客户端到收藏列表时不走viewWillAppear:所以这里。。。。（这样的话从3DTouch 后台 调起客户端到收藏列表时也会走这）
    if (_is3DTouch) {
        [self viewWillAppear:YES];
    }
    [self getCorpusList];
}

- (void)updateTheme:(NSNotification *)notifiction {
    [super updateTheme:notifiction];
    [_manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetToolBarOrigin];
    
    
//    _corpusTableView.frame = CGRectMake(0, kHeaderTotalHeight, kAppScreenWidth, kAppScreenHeight-kHeaderTotalHeight-kToolbarHeight);
//    _corpusTableHeight = _corpusTableView.height;
    
    _isViewDisappear = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.colorTypeArray count] > 0) {
        [self.colorTypeArray replaceObjectAtIndex:[self.colorTypeArray count]-1 withObject:@"0"];
    }
    _isViewDisappear = YES;
    
    if (_animationImageView) {
        _animationImageView.status = SNImageLoadingStatusStopped;
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark init
- (void)getCorpusList {
    
    [SNCorpusList loadCorpusListFromServerWithSuccessHandler:^(NSArray *corpusArray) {
        if ([corpusArray count] == 0) {
            self.corpusTextArray = [NSMutableArray arrayWithObjects:kCorpusMyFavourite, kCorpusMyShare, nil];
        } else {
            self.corpusTextArray = [NSMutableArray arrayWithObjects:kCorpusMyFavourite, kCorpusMyShare, nil];
            NSDictionary *dictCorpus = nil;
            NSString *corpusID = nil;
            [self.corpusIDArray removeAllObjects];
            for (int i = 0; i < [corpusArray count]; i++) {
                dictCorpus = [corpusArray objectAtIndex:i];
                [self.corpusTextArray addObject:[dictCorpus objectForKey:kCorpusFolderName]];
                
                corpusID = [dictCorpus stringValueForKey:kCorpusID defaultValue:nil];
                [self.corpusIDArray addObject:corpusID];

            }
            [_manageButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
            _manageButton.userInteractionEnabled = YES;
        }
        [self.colorTypeArray removeAllObjects];
        for (int i = 0; i < [self.corpusTextArray count]; i ++) {
            [self.colorTypeArray addObject:@"0"];
        }
        [_corpusTableView reloadData];

    } failure:^{
        self.loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
        self.loadingView.hidden = NO;
        self.animationImageView.status = SNImageLoadingStatusStopped;
    }];
    
}

- (void)initManageButton {
    _manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_manageButton setTitle:kCorpusManage forState:UIControlStateNormal];
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


- (void)initCorpusTableView {
    if (!_corpusTableView) {
        UITableView *corpusTableView = [[UITableView alloc] init];
        _corpusTableView = corpusTableView;
        _corpusTableView.frame = CGRectMake(0, kHeaderTotalHeight, kAppScreenWidth, kAppScreenHeight-kHeaderTotalHeight-kToolbarHeight);

        _corpusTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _corpusTableView.separatorColor = [UIColor clearColor];
        _corpusTableView.backgroundColor = [UIColor clearColor];
        //        _corpusTableView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
        _corpusTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kToolbarViewHeight, 0);
        _corpusTableView.scrollsToTop = YES;
        _corpusTableView.delegate = self;
        _corpusTableView.dataSource = self;
        [self.view addSubview:_corpusTableView];
        
//        _corpusTableHeight = _corpusTableView.height;
    }
}

#pragma mark UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.corpusTextArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCorpusTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNCorpusTableViewCell *cell = nil;
    NSInteger row = [indexPath row];
    static NSString * cellIdentifier = @"corpusCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SNCorpusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    __weak typeof(self)weakself = self;
    [cell setCorpusBlock:^(SNCorpusTableViewCell *cell) {
        weakself.currentIndexPath = [weakself.corpusTableView indexPathForCell:cell];
    }];
    NSString *imageName = nil;
    NSString *textColor = [self.colorTypeArray objectAtIndex:row];
    NSString *cellTitle = [self.corpusTextArray objectAtIndex:row];
    if ((row > 1) && [self.corpusIDArray count] > 0) {
        NSInteger remainder = (row-2)%kCorpusCount;
        imageName = [NSString stringWithFormat:@"ico_file%zd_v5.png",remainder + 1];
        [cell setCellItemWithImagName:imageName text:[self.corpusTextArray objectAtIndex:row] corpusID:[self.corpusIDArray objectAtIndex:row - 2] isEditMode:_isEditMode textColor:textColor];
    }
    else {
        if (row == 0) {
            imageName = @"ico_shouchang_v5.png";
        }
        else if (row == 1) {
            imageName = @"ico_corpus_share_v5.png";
        }
        else {
            imageName = @"ico_xinjianda_v5.png";
        }
        [cell setCellItemWithImagName:imageName text:[self.corpusTextArray objectAtIndex:row] corpusID:nil isEditMode:_isEditMode textColor:textColor];
    }
    if (_isEditMode &&([cellTitle isEqualToString:kCorpusMyFavourite] || [cellTitle isEqualToString:kCorpusMyShare] || [cellTitle isEqualToString:kCorpusNewFavourite])) {
        cell.userInteractionEnabled = NO;
    }
    else {
        cell.userInteractionEnabled = YES;
    }
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SNUtility shouldUseSpreadAnimation:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_manageButton.titleLabel.text isEqualToString:kCorpusDown]) {
        return;
    }
    NSInteger row = [indexPath row];

    _isOpenCreatCorpus = NO;
    NSString *corpusID = nil;
    if ([self.corpusIDArray count] > 0 && row > 1) {
        corpusID = [self.corpusIDArray objectAtIndex:row-2];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[self.corpusTextArray objectAtIndex:row] forKey:kCorpusFolderName];
    if (corpusID.length > 0) {
        
        [dict setObject:corpusID forKey:kCorpusID];
    }

    [dict setObject:[NSNumber numberWithBool:YES] forKey:kFromFavoriteManager];
    
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://corpusList"] applyAnimated:YES] applyQuery:dict];
    [[TTNavigator navigator] openURLAction:_urlAction];
    //    }
}

- (void)manageButtonAction:(id)sender {
    _isOpenCreatCorpus = NO;
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:kCorpusManage]) {//管理
        for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                gesture.enabled = NO;
            }
        }
        [_manageButton setTitle:kCorpusDown forState:UIControlStateNormal];

        __weak typeof(self)weakself = self;
        [_corpusTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNCorpusTableViewCell *cell = (SNCorpusTableViewCell *)obj;

            [cell cellDeleteMode:kCellAnimationDuration];
            weakself.toolbarView.frame = CGRectMake(0, kAppScreenHeight - [SNToolbar toolbarHeight], kAppScreenWidth, [SNToolbar toolbarHeight]);
            [weakself.view endEditing:YES];

        }];
        _isEditMode = YES;
       
    }
    else {//完成
        for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                gesture.enabled = YES;
            }
        }
        [_manageButton setTitle:kCorpusManage forState:UIControlStateNormal];
        [_corpusTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNCorpusTableViewCell *cell = (SNCorpusTableViewCell *)obj;
            [cell cellNormalMode];
            cell.userInteractionEnabled = YES;
        }];
        
        [self resetToolBarOrigin];

        _isEditMode = NO;
        
        [_corpusTableView.visibleCells enumerateObjectsUsingBlock:^(__kindof SNCorpusTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj finishManageCorpus];
        }];
//        [SNNotificationManager postNotificationName:kFinishedManageCorpusNotification object:nil];
        [self performSelector:@selector(getCorpusList) withObject:nil afterDelay:kCellAnimationDuration];
    }
}

- (void)loginAction:(id)sender {
    [SNGuideRegisterManager login:kLoginFromMyCorpus];
    [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
}

//#pragma mark NSNotification
//- (void)refreshCorpusList:(NSNotification *)notification {
//    [self refreshTable:notification.userInfo];
//    [self manageButtonAction:nil];
//    if ([self.colorTypeArray count] > 0) {
//        [self.colorTypeArray replaceObjectAtIndex:[self.colorTypeArray count]-1 withObject:@"0"];
//    }
//}

//- (void)updateCorpusName:(NSNotification *)notification {
//    [self.corpusIDArray enumerateObjectsUsingBlock:^(NSString *corpusID, NSUInteger idx, BOOL *stop) {
//        if ([notification.userInfo objectForKey:kCorpusID] == corpusID) {
//            [self.corpusTextArray replaceObjectAtIndex:idx + 2 withObject:[notification.userInfo objectForKey:kCorpusFolderName]];
//            *stop = YES;
//        }
//    }];
//}

#pragma mark - SNCorpusTableViewCellDelegate
- (void)updateCorpusNameWithDict:(NSDictionary *)dict {
    
    __weak typeof(self)weakself = self;
    [self.corpusIDArray enumerateObjectsUsingBlock:^(NSString *corpusID, NSUInteger idx, BOOL *stop) {
        if ([dict objectForKey:kCorpusID] == corpusID) {
            [weakself.corpusTextArray replaceObjectAtIndex:idx + 2 withObject:[dict objectForKey:kCorpusFolderName]];
            *stop = YES;
        }
    }];
}

- (void)resetToolBar {
   [self resetToolBarOrigin];
}

- (void)refreshCorpusListWithDict:(NSDictionary *)dict {
    [self refreshTable:dict];
    [self manageButtonAction:nil];
    if ([self.colorTypeArray count] > 0) {
        [self.colorTypeArray replaceObjectAtIndex:[self.colorTypeArray count]-1 withObject:@"0"];
    }
}




- (void)refreshTable:(NSDictionary *)dict {
    
    __weak typeof(self)weakself = self;
    [self.corpusIDArray enumerateObjectsUsingBlock:^(NSString *corpusID, NSUInteger idx, BOOL *stop) {
        if ([[dict objectForKey:kCorpusID] isEqualToString:corpusID]) {
            [weakself.corpusIDArray removeObject:corpusID];
            *stop = YES;
        }
    }];
    
    [self.corpusTextArray enumerateObjectsUsingBlock:^(NSString *corpusName, NSUInteger idx, BOOL *stop) {
        if ([[dict objectForKey:kCorpusFolderName] isEqualToString:corpusName]) {
            [weakself.corpusTextArray removeObject:corpusName];
            *stop = YES;
        }
    }];
    
    [_corpusTableView reloadData];
    
    if ([self.corpusIDArray count] == 0) {
        [_manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:UIControlStateNormal];
        _manageButton.userInteractionEnabled = NO;
    }
}


- (void)receivePushNotification:(NSNotification *)notification {
    [self resetToolBarOrigin];

    _isKeyboardHidden = YES;
    [_corpusTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNCorpusTableViewCell *cell = (SNCorpusTableViewCell *)obj;
        [cell.itemTextField resignFirstResponder];
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (_isOpenCreatCorpus ||_isKeyboardHidden || _isViewDisappear) {
        _isKeyboardHidden = NO;
        return;
    }
    
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    // 修改滚动条和tableView的contentInset
    self.corpusTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    self.corpusTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    
    // 跳转到当前点击的输入框所在的cell
    [UIView animateWithDuration:0.2 animations:^{
        [self.corpusTableView scrollToRowAtIndexPath:self.currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
    
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    CGFloat pointY = kAppScreenHeight - bg.size.height - keyboardSize.height + 5;
    self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    self.corpusTableView.contentInset = UIEdgeInsetsZero;
    self.corpusTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [self resetToolBarOrigin];
}


- (SNTripletsLoadingView *)loadingView {
    if (!_loadingView) {
        SNTripletsLoadingView *loadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
        _loadingView = loadingView;
        _loadingView.delegate = self;
        [self.view addSubview:_loadingView];
    }
    return _loadingView;
}

#pragma mark SNTripletsLoadingView delegate
-(void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    //    self.loadingView.status = SNTripletsLoadingStatusLoading;
    self.loadingView.hidden = YES;
    self.animationImageView.status = SNImageLoadingStatusLoading;
    [self getCorpusList];
}

- (void)onBack:(id)sender {
    [_corpusTableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNCorpusTableViewCell *cell = (SNCorpusTableViewCell *)obj;
        if ([cell.itemTextField isFirstResponder]) {
            
            [cell.itemTextField resignFirstResponder];
            
            [cell changeCorpusName];
        }
    }];
    [super onBack:sender];
}

- (SNLoadingImageAnimationView *)animationImageView {
    if (!_animationImageView) {
        SNLoadingImageAnimationView *animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView = animationImageView;
        _animationImageView.targetView = self.view;
    }
    return _animationImageView;
}

- (void)dealloc {

    [SNNotificationManager removeObserver:self];
}

@end
