//
//  SNNovelShelfController.m
//  sohunews
//
//  Created by qz on 15/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNTabbarView.h"
#import "SNNovelShelfController.h"
#import "SNBookShelf.h"
#import "SNNovelShelfCell.h"
#import "SNNovelUtilities.h"
#import "SNStoryUtility.h"
#import "SNUserManager.h"
#import "SNNovelChannelLoginTipView.h"
#import "SNNewAlertView.h"
#import "SNLoadingImageAnimationView.h"
#import "SNNewsLoginManager.h"

@interface SNNovelShelfController ()<UITableViewDelegate,UITableViewDataSource,SNNovelChannelLoginTipViewDelegate>{
    BOOL _isEditing;
    BOOL isLoginStatusChange;
    UIView *_bgLoadingView;
    UIButton *_notReachableIndicator;
}

@property(nonatomic,strong)UITableView *mainTable;
@property(nonatomic,strong)UIView *headerView;
@property(nonatomic,strong)UIView *editView;
@property(nonatomic,strong)UIView *emptyView;
@property(nonatomic,strong)UIButton *selectAllButton;
@property(nonatomic,strong)UIButton *deleteButton;
@property(nonatomic,strong)UIButton *manageButton;
@property(nonatomic,strong)NSMutableArray *sourceArray;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)SNNovelChannelLoginTipView *loginTip;
@property (nonatomic, strong) SNLoadingImageAnimationView * loadingImageView;

@end

@implementation SNNovelShelfController

-(void)dealloc
{
    [SNNotificationManager removeObserver:self name:kNovelDidAddBookShelfNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isEditing = NO;
    self.controllerCanPop = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarHeight) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    
    self.view.backgroundColor = SNUICOLOR(kThemeBg4Color);
    isLoginStatusChange = [SNStoryUtility isLogin];
    
    self.selectedBooks = [NSMutableArray array];
    self.sourceArray = [NSMutableArray array];
    [self initNav];
    [self initFooter];
    [self initTable];
    
    [SNNotificationManager addObserver:self selector:@selector(needRefreshBookShelf:) name:kNovelDidAddBookShelfNotification object:nil];
    [self showLoadingView];
}
//
//-(void)updateStatusBarHeight{
//    //[self updateFootViewFrame];
//}
//
//-(void)updateFootViewFrame{
//    if(!_footerView) return;
//
//    CGFloat originY = [UIScreen mainScreen].bounds.size.height-49;
//    CGFloat defaultHeight = 49;
//
//    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
//        originY = [UIScreen mainScreen].bounds.size.height-[SNTabbarView tabBarHeightForiPhoneX];
//        defaultHeight = [SNTabbarView tabBarHeightForiPhoneX];
//    }
//    if ([UIApplication sharedApplication].statusBarFrame.size.height == 40) {
//        originY = [UIScreen mainScreen].bounds.size.height-20-49;
//        defaultHeight = 49;
//    }
//
//    _footerView.frame = CGRectMake(0, originY, [UIScreen mainScreen].bounds.size.width, defaultHeight);
//}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //弹出登陆提醒tableHeaderView
    if ([SNUserManager isLogin]) {
        if (self.loginTip) {
            _mainTable.tableHeaderView = nil;
        }
    }
    
    if(!_isEditing){
        if (isLoginStatusChange == [SNStoryUtility isLogin]) {
            [self fetchShelfBooksWithAnimated:NO];
        } else {
            [self fetchShelfBooksWithAnimated:YES];
            isLoginStatusChange = [SNStoryUtility isLogin];
        }
        
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self updateEditStatus:NO];
}

-(void)initEmptyView{
    UIImage *normalImage = [UIImage imageNamed:@"icofiction_sjkb_v5.png"];
    CGFloat height = normalImage.size.height + 80;
    if (!_emptyView) {
        self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-normalImage.size.width)/2, (_mainTable.frame.size.height - height)/2+ CGRectGetMaxY(_headerView.frame), normalImage.size.width, height)];
        UIImageView *selectedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, normalImage.size.width, normalImage.size.height)];
        selectedIcon.image = normalImage;
        [_emptyView addSubview:selectedIcon];
     
        UIButton *addBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addBookButton.frame = CGRectMake(0, normalImage.size.height + 39 , normalImage.size.width, 40);
        [addBookButton addTarget:self action:@selector(addBookButtonTaped) forControlEvents:UIControlEventTouchUpInside];
        [addBookButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:0 ];
        [addBookButton setTitle:@"立即添加小说" forState:0];
        addBookButton.layer.cornerRadius = 2;
        addBookButton.layer.borderWidth = 1;
        addBookButton.layer.borderColor = SNUICOLOR(kThemeBg6Color).CGColor;
        [_emptyView addSubview:addBookButton];
        [self.view addSubview:_emptyView];
    }
    _mainTable.bounces = NO;
    _emptyView.hidden = NO;
}

- (void)showLoadingView {
    if (!_bgLoadingView) {
        _bgLoadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49)];
        _bgLoadingView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        [self.view addSubview:_bgLoadingView];
        [self.view insertSubview:_bgLoadingView belowSubview:self.headerView];
    }
    if (!self.loadingImageView) {
        self.loadingImageView = [[SNLoadingImageAnimationView alloc] init];
        self.loadingImageView.targetView = _bgLoadingView;
    }
    self.loadingImageView.status = SNImageLoadingStatusLoading;
    _bgLoadingView.hidden = NO;
}

- (void)hideLoadingView {
    self.loadingImageView.status = SNImageLoadingStatusStopped;
    _bgLoadingView.hidden = YES;
}

-(void)addBookButtonTaped{
    NSDictionary *dic = @{@"novelH5PageType":@"0",@"tagId":@"1",@"type":@"1"};
    [SNStoryUtility openUrlPath:@"tt://storyWebView" applyQuery:dic applyAnimated:YES];
}

- (void)initLoginTipBar {
    self.loginTip = [[SNNovelChannelLoginTipView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 40)];
    [self.loginTip hideCloseButton];
    self.loginTip.delegate = self;
}

- (void)noNetworkView {
    if (!_notReachableIndicator) {
        _loadingImageView.status = SNImageLoadingStatusStopped;
        UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeC];
        NSString *labelColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color];
        UIColor *fontColor = [UIColor colorFromString:labelColorString];
        CGFloat indicatorWidth = floorf(321/2.0f);
        CGFloat indicatorHeight = floorf(321/2.0f);
        CGFloat indicatorLeft = (self.view.frame.size.width-indicatorWidth)/2.0f;
        CGFloat indicatorTop = (self.view.frame.size.height-indicatorHeight)/2.0f;
        
        UIImage *image = [UIImage imageNamed:@"icofiction_hqsb_v5.png"];
        _notReachableIndicator = [UIButton buttonWithType:UIButtonTypeCustom];
        _notReachableIndicator.frame = CGRectMake(indicatorLeft, indicatorTop, indicatorWidth, indicatorHeight);
        [_notReachableIndicator setImage:image forState:UIControlStateNormal];
        [_notReachableIndicator setImage:image forState:UIControlStateHighlighted];
        [_notReachableIndicator setTitle:@"点击屏幕 重新加载" forState:UIControlStateNormal];
        [_notReachableIndicator.titleLabel setFont:font];
        [_notReachableIndicator setTitleColor:fontColor forState:UIControlStateNormal];
        [_notReachableIndicator addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
        _notReachableIndicator.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _notReachableIndicator.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        CGSize size = _notReachableIndicator.frame.size;
        CGFloat imgViewEdgeInsetLeft = (size.width - image.size.width)/2;
        CGFloat imgViewEdgeInsetTop = _notReachableIndicator.imageView.top;
        CGFloat titleLabelEdgeInsetLeft = (size.width - _notReachableIndicator.titleLabel.size.width)/2 - image.size.width - 50;
        CGFloat titleLabelEdgeInsetTop  = imgViewEdgeInsetTop + image.size.height + 12;
        UIEdgeInsets imgViewEdgeInsets = UIEdgeInsetsMake(0, imgViewEdgeInsetLeft, 0, 0);
        UIEdgeInsets titleLabelEdgeInsets = UIEdgeInsetsMake(titleLabelEdgeInsetTop, titleLabelEdgeInsetLeft, 0, 0);
        [_notReachableIndicator setImageEdgeInsets:imgViewEdgeInsets];
        [_notReachableIndicator setTitleEdgeInsets:titleLabelEdgeInsets];
        
        [self.view addSubview:_notReachableIndicator];
        [self.view bringSubviewToFront:_notReachableIndicator];
    }
}

- (void)retry {
    [self fetchShelfBooksWithAnimated:YES];
}

#pragma mark -- 小说频道登陆提醒
- (void)novelLoginTipDidClickLogin {

    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)]; 
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method, @"method", [NSNumber numberWithInteger:SNGuideRegisterTypeLogin], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
    //[SNUtility openLoginViewWithDict:dict];
    [SNNewsReport reportADotGif:@"act=fic&tp=login"];

    //wangshun login open
    [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111书架
        
    } Failed:nil];
    
    [SNNewsReport reportADotGif:@"act=fic&tp=login"];
    
//    NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:[NSDictionary dictionaryWithObjectsAndKeys:method, @"method", [NSNumber numberWithInteger:SNGuideRegisterTypeLogin], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil]];
    
    [SNNewsReport reportADotGif:@"act=fic&tp=login"];
//    [[TTNavigator navigator] openURLAction:_urlAction];

}

- (void)novelLoginTipDidClickClose {
    [SNStoryUtility loginTipCloseStateWithState:NO];
    
    [UIView animateWithDuration:.3 animations:^{
        self.loginTip.alpha = 0;
        [self.mainTable.tableHeaderView removeFromSuperview];
        self.mainTable.tableHeaderView = nil;
    } completion:^(BOOL finished) {
        if (finished) {
            self.loginTip.alpha = 1;
        }
    }];
}

- (void)loginSuccess {
    [self novelLoginTipDidClickClose];
}

-(void)initTable{

    self.mainTable = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-49) style:UITableViewStylePlain];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTable.dataSource = self;
    _mainTable.delegate = self;
    _mainTable.backgroundColor = SNUICOLOR(kThemeBg3Color);
    [self.view addSubview:_mainTable];
    if (_headerView) {
        [self.view bringSubviewToFront:_headerView];
    }
    if (_footerView) {
        [self.view bringSubviewToFront:_footerView];
    }
    //弹出登陆提醒tableHeaderView
    if (![SNUserManager isLogin]) {
        if (self.loginTip) {
            _mainTable.tableHeaderView = self.loginTip;
        } else {
            [self initLoginTipBar];
            _mainTable.tableHeaderView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg2Color]];
            _mainTable.tableHeaderView = self.loginTip;
        }
    }
}

-(void)initFooter{
    if(!_footerView){
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, [UIScreen mainScreen].bounds.size.width, 49)];
        
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            _footerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-[SNTabbarView tabBarHeightForiPhoneX], [UIScreen mainScreen].bounds.size.width, [SNTabbarView tabBarHeightForiPhoneX]);
        }else{
            _footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        }
        _footerView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 40, 50);
        [backBtn setImage:[UIImage themeImageNamed:@"icotext_back_v5.png"] forState:0];
        [backBtn setImage:[UIImage themeImageNamed:@"icotext_backpress_v5.png"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:backBtn];
        
        self.editView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 49)];
        _editView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        [_footerView addSubview:_editView];
        
        UIImage *normalImage = [UIImage imageNamed:@"novel_icofiction_wxz_v5.png"];
        UIImage *selectedImage = [UIImage imageNamed:@"novel_icofiction_xz_v5.png"];
        self.selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectAllButton.frame = CGRectMake(12, 0, 60, _editView.frame.size.height);
        _selectAllButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_selectAllButton setTitle:@"全选" forState:0];
        [_selectAllButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
        [_selectAllButton setImage:normalImage forState:0];
        [_selectAllButton setImage:selectedImage forState:UIControlStateSelected];
        [_selectAllButton addTarget:self action:@selector(selectAllBooks:) forControlEvents:UIControlEventTouchUpInside];
        _selectAllButton.backgroundColor = [UIColor clearColor];
        _selectAllButton.imageEdgeInsets = UIEdgeInsetsMake(0, -14, 0, 0);
        _selectAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 0);
        [_editView addSubview:_selectAllButton];

        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-52, 0, 40, _editView.frame.size.height);
        [_deleteButton setTitle:@"删除" forState:0];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:0];
        [_deleteButton addTarget:self action:@selector(deleteSeveralBooks:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.backgroundColor = [UIColor clearColor];
        _deleteButton.titleEdgeInsets = UIEdgeInsetsMake(-1, 0, 0, 0);
        [_editView addSubview:_deleteButton];
        
        _editView.hidden = YES;
        
        //Top edge shadow
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 1, 2, 1);
        UIImage *shadowImg = [[UIImage imageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        UIImageView *_topEdgeShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, -shadowImg.size.height, self.view.width, shadowImg.size.height)];
        _topEdgeShadow.image = shadowImg;
        [_footerView addSubview:_topEdgeShadow];
        
        [self.view addSubview:_footerView];
    }
}

-(void)back{
    if (!_controllerCanPop) {
        return;
    }
    if (_bookAnimating) {
        return;
    }
    //@qz 书架 返回按钮 埋点
    //[SNNewsReport reportADotGif:@"_act=cc&fun="];
    
    _controllerCanPop = NO;
    
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }else{
        [[TTNavigator navigator].topViewController.flipboardNavigationController popViewController];
    }
}

-(void)deleteSeveralBooks:(UIButton *)sender{
    
    if (_selectedBooks.count == 0) {
        _deleteButton.enabled = NO;
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:0];
        return;
    }
    
    NSString *bookId = @"";
    for (SNBook *book in _selectedBooks) {
        bookId = [bookId stringByAppendingFormat:@",%@",book.bookId];
    }
    if ([bookId hasPrefix:@","]) {
        bookId = [bookId substringFromIndex:1];
    }
    if (bookId.length > 0) {
        
        SNNewAlertView *newAlertView = [[SNNewAlertView alloc]initWithTitle:nil message:@"您确定删除选中书籍吗？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定"];
        [newAlertView show];
        [newAlertView actionWithBlocksCancelButtonHandler:^{
            
        } otherButtonHandler:^{
            
            if([SNStoryUtility currentReachabilityStatusForStory] == StoryNetworkReachabilityStatusNotReachable)
            {
                [[SNCenterToast shareInstance]showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            }
            else{
                
                __weak typeof(self)weakSelf = self;
                
                [SNBookShelf removeBookShelf:bookId completed:^(BOOL success) {
                    if(success) {
                        [weakSelf updateEditStatus:NO];
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已删除" toUrl:nil mode:SNCenterToastModeSuccess];
                        [weakSelf fetchShelfBooksWithAnimated:NO];
                    }else{
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"删除失败" toUrl:nil mode:SNCenterToastModeError];
                    }
                }];
            }
            
        }];
    }
}

-(void)selectAllBooks:(UIButton *)sender{
    sender.selected = !sender.selected;

    if (sender.selected) {
        if (_sourceArray.count) {
            [self.selectedBooks addObjectsFromArray:_sourceArray];
        }
    }else{
        if (_selectedBooks) {
            [_selectedBooks removeAllObjects];
        }
    }
    
    if (_selectedBooks.count == 0) {
        _deleteButton.enabled = NO;
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:0];
    }else{
        _deleteButton.enabled = YES;
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
    }
    
    [_mainTable reloadData];
}

-(void)fetchShelfBooksWithAnimated:(BOOL)animated {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        if (!_sourceArray || _sourceArray.count==0) {
           [self noNetworkView];
        }
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }else{
        [_notReachableIndicator removeFromSuperview];
        _notReachableIndicator = nil;
    }

    __weak typeof(self)weakSelf = self;
    if (animated) {
        [self showLoadingView];
    }
    [SNBookShelf getBooks:@"" count:@"" complete:^(BOOL success,NSArray *books) {
        NSMutableArray * bookShelf = [NSMutableArray arrayWithCapacity:books.count];
        
        if (success) {
            
            if (weakSelf.sourceArray.count) {
                [weakSelf.sourceArray removeAllObjects];
            }
            for (NSDictionary * bookDic in books) {
                @autoreleasepool {
                    SNBook * book = [SNRollingNews createBookWithDictionary:bookDic];
                    [weakSelf.sourceArray addObject:book];
                }
            }
            
            [weakSelf arrangeArrayFromSourceArray:weakSelf.sourceArray];
            if(weakSelf.dataItem){
                weakSelf.dataItem.bookShelf = bookShelf;
            }
            if (weakSelf.sourceArray.count == 0) {
                [weakSelf initEmptyView];
                [weakSelf.manageButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:0];
            }else{
                [weakSelf.manageButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
                weakSelf.emptyView.hidden = YES;
                _mainTable.bounces = YES;
            }
            [weakSelf.mainTable reloadData];
        }
        [self hideLoadingView];
    }];
}

- (void)initNav{
    if(!_headerView){
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
            _headerView.frame = CGRectMake(0, 24, [UIScreen mainScreen].bounds.size.width, 64);
        }
        _headerView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        
        UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(17, 32, 100, 100)];
        titleLbl.text = @"书架";
        titleLbl.textColor = SNUICOLOR(kThemeRed1Color);
        titleLbl.tag = 9999;
        titleLbl.font = [UIFont systemFontOfSize:17];
        [titleLbl sizeToFit];
        titleLbl.frame = (CGRect){CGPointMake(17, 32),titleLbl.frame.size};
        [_headerView addSubview:titleLbl];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(12, CGRectGetHeight(_headerView.frame), 43, 2)];
        lineView.backgroundColor = SNUICOLOR(kThemeRed1Color);
        [_headerView addSubview:lineView];
        
        self.manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _manageButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-52, 16, 40, 50);
        [_manageButton setTitle:@"管理" forState:0];
        _manageButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_manageButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
        [_manageButton addTarget:self action:@selector(editBooks:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_manageButton];
        
        //Top edge shadow
        UIImage *shadowImg = [UIImage imageNamed:@"icotitlebar_shadow_v5.png"];
        shadowImg =[shadowImg stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        UIImageView *_topEdgeShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0,_headerView.frame.size.height, self.view.width, shadowImg.size.height)];
        _topEdgeShadow.image = shadowImg;
        [_headerView addSubview:_topEdgeShadow];
        
        [self.view addSubview:_headerView];
    }
}

-(void)editBooks:(UIButton *)sender{
    //进入编辑状态
    if(self.sourceArray.count == 0) return;
    
    sender.selected = !sender.selected;
    [self updateEditStatus:sender.selected];
}

-(void)updateEditStatus:(BOOL)editing{
    
    _isEditing = editing;
    if (_isEditing) {
        [_manageButton setTitle:@"完成" forState:0];
        
        _editView.hidden = NO;
        
        if (![SNUserManager isLogin]) {
            _mainTable.tableHeaderView = nil;
        }

    }else{
        [_manageButton setTitle:@"管理" forState:0];
        
        _manageButton.selected = NO;
        
        _selectAllButton.selected = NO;
        
        _deleteButton.enabled = NO;
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:0];
        
        if(_selectedBooks){
            [_selectedBooks removeAllObjects];
        }
        _editView.hidden = YES;
        
        if (![SNUserManager isLogin]) {
            if (_loginTip) {
                _mainTable.tableHeaderView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBg2Color]];
                _mainTable.tableHeaderView = _loginTip;
            }
        }
    }

    [_mainTable reloadData];
}

-(void)arrangeArrayFromSourceArray:(NSArray *)sourceArray{
    self.dataArray = [NSMutableArray array];
    if (sourceArray.count) {
        
        NSMutableArray *tmpArray = [NSMutableArray array];
        
        for (id item in sourceArray) {
            NSInteger index = [sourceArray indexOfObject:item];
            [tmpArray addObject:item];
            if ((tmpArray.count == [SNNovelUtilities bookNumbersOfSingleShelfRow])
                || (index == sourceArray.count-1))
            {
                [_dataArray addObject:[NSArray arrayWithArray:tmpArray]];
                [tmpArray removeAllObjects];
            }
        }
    }
}

-(void)needRefreshBookShelf:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString * scrollTop = userInfo[@"scrollTop"];
    NSString * bookId = userInfo[@"bookId"];
    if (scrollTop && [scrollTop isEqualToString:@"1"]) {
        [self.mainTable setContentOffset:CGPointMake(0, 0)];
    }
    
    if (bookId && bookId.length > 0) {
        
        [SNBookShelf setBookHasRead:bookId complete:^(BOOL success) {
            
            [self fetchShelfBooksWithAnimated:NO];
        }];
    }
    else
    {
        [self fetchShelfBooksWithAnimated:NO];
    }
}

-(void)refreshSelectState{
    if (!_sourceArray || _sourceArray.count == 0) return;
    
    if (_sourceArray.count == _selectedBooks.count) {
        
        _selectAllButton.selected = YES;
        
        _deleteButton.enabled = YES;
        [_deleteButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
    }else{
        
        _selectAllButton.selected = NO;
        
        if (_editView.hidden == NO) {
            if (_selectedBooks.count == 0) {
                _deleteButton.enabled = NO;
                [_deleteButton setTitleColor:SNUICOLOR(kThemeText3Color) forState:0];
            }else{
                _deleteButton.enabled = YES;
                [_deleteButton setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray ? _dataArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [SNNovelUtilities shelfCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"novelAprilCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[SNNovelShelfCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        cell.backgroundColor = SNUICOLOR(kThemeBg3Color);
    }
    
    SNNovelShelfCell *novelShelfCell = (SNNovelShelfCell *)cell;
    novelShelfCell.sourceController = self;
    [novelShelfCell updateView: _dataArray isEdit:_isEditing indexPath:indexPath];
    
    return cell;
}

@end
