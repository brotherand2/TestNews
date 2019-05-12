//
//  SNSuggestionFeedBackViewController.m
//  UserFeedBack
//
//  Created by 李腾 on 2016/10/2.
//  Copyright © 2016年 suhu. All rights reserved.
//

#import "SNSuggestionFeedBackViewController.h"
#import "SNQuickFeedbackViewController.h"
#import "SNQuestionTypeCell.h"
#import "SNFBTypeModel.h"
#import "SNNewsReport.h"
#import "SNUserManager.h"
#import "SNLoadingImageAnimationView.h"
#import "SNTripletsLoadingView.h"


@interface SNSuggestionFeedBackViewController () <UICollectionViewDelegate, UICollectionViewDataSource, SNTripletsLoadingViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UILabel *tipLabel;
@property (nonatomic, weak) UIView *footerView;

@property (nonatomic, strong) NSArray *fbTypeListArr;

@property (nonatomic, strong) NSString *typeID;

@property (nonatomic, assign, getter=isSelectType) BOOL selectType;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) SNLoadingImageAnimationView *animationImageView;
@property (nonatomic, strong) SNTripletsLoadingView *loadingView;

@end

@implementation SNSuggestionFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];
    self.view.backgroundColor = SNUICOLOR(kThemeBg2Color);
    self.animationImageView.status = SNImageLoadingStatusLoading;
    [self loadQuestionTypeFromService];
    [self updateTheme];
    [SNNotificationManager addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_animationImageView) {
        _animationImageView.status = SNImageLoadingStatusStopped;
    }
}

- (void)reachabilityChanged:(NSNotification *)noti {
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    if ([conn currentReachabilityStatus] != NotReachable) {
        [self loadQuestionTypeFromService];
    }
}

- (void)loadQuestionTypeFromService {
    [SNFBTypeModel requestFBTypeListWithFinishHandle:^(NSArray<SNFBTypeModel *> *typeList) {
        self.fbTypeListArr = typeList;
        [self.collectionView reloadData];
        self.animationImageView.status = SNImageLoadingStatusStopped;
        self.backView.hidden = YES;
        [self hideError];
    } failure:^(NSError *error) {
        [self showError];
    }];
    
}

- (void)initSubViews {
    
    [self createQuetionTypeHeaderView];
    [self createQuestionTypeView];
}

- (void)createQuetionTypeHeaderView {
    
    UILabel *subLabel = [[UILabel alloc] init];
    _tipLabel = subLabel;
    subLabel.text = @"请选择问题发生的场景，再向客服小秘书反馈";
    [subLabel sizeToFit];
    subLabel.left = 14;
    subLabel.top = 11;
    subLabel.font = [UIFont systemFontOfSize:kThemeFontSizeG];
    subLabel.textColor = SNUICOLOR(kThemeText3Color);
//    subLabel.backgroundColor = SNUICOLOR(kThemeBg1Color);
    [self.view addSubview:subLabel];
}

- (void)createQuestionTypeView {
    CGFloat height = 126.0 /125.0 * kAppScreenWidth / 3;
    
    CGFloat margin = 0.0;
    CGFloat itemW = kAppScreenWidth / 3;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemW, height);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    CGFloat collectionViewY = 39.0f;
    CGFloat collectionViewH = kAppScreenHeight - kHeaderHeightWithoutBottom - kToolbarHeight - collectionViewY;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, kAppScreenWidth , collectionViewH) collectionViewLayout:flowLayout];
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollsToTop = NO;
    collectionView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    [self.view addSubview:collectionView];
    [collectionView registerClass:[SNQuestionTypeCell class] forCellWithReuseIdentifier:NSStringFromClass([SNQuestionTypeCell class])];

}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.fbTypeListArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SNQuestionTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SNQuestionTypeCell class]) forIndexPath:indexPath];
    
    cell.typeModel = self.fbTypeListArr[indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     [collectionView deselectItemAtIndexPath:indexPath animated:YES] ;
    SNFBTypeModel *typeModel = self.fbTypeListArr[indexPath.item];
    self.typeID = [NSString stringWithFormat:@"%@",typeModel.typeID];
    if (self.typeID.integerValue != 10000) self.selectType = YES;
    [self feedBack];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)feedBack {
    // 统计埋点
    [SNNewsReport reportADotGif:@"act=cc&fun=96"];

    TTURLAction *urlAction = [TTURLAction actionWithURLPath:@"tt://quickFeedBack"];
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    if (self.isSelectType) [query setObject:self.typeID forKey:@"typeID"];
    if (query.count > 0) [urlAction applyQuery:query];
    TTNavigator *navigator = [TTNavigator navigator];
    [navigator openURLAction:urlAction];
    
}

- (NSArray *)fbTypeListArr {
    if (_fbTypeListArr == nil) {
        _fbTypeListArr = [NSArray array];
    }
    return _fbTypeListArr;
}

- (void)updateTheme:(NSNotification *)notifiction
{
    [super updateTheme:notifiction];
    [self updateTheme];
    [self.collectionView reloadData];
}

- (void)updateTheme{
    
    self.view.backgroundColor = SNUICOLOR(kThemeBg2Color);
    _collectionView.backgroundColor = SNUICOLOR(kThemeBg2Color);
}

- (SNLoadingImageAnimationView *)animationImageView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, -64, kAppScreenWidth, kAppScreenHeight)];
        _backView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        [self.view addSubview:_backView];
    }
    if (!_animationImageView) {
        _animationImageView = [[SNLoadingImageAnimationView alloc] init];
        _animationImageView.targetView = _backView;
    }
    
    return _animationImageView;
}

- (void)showError {
    if (!_loadingView)
    {
        CGRect rect = CGRectMake(0, -64, kAppScreenWidth, kAppScreenHeight);
        _loadingView = [[SNTripletsLoadingView alloc] initWithFrame:rect];
        _loadingView.delegate = self;
        _loadingView.status = SNTripletsLoadingStatusStopped;
        [self.view addSubview:_loadingView];
    }
    _loadingView.status = SNTripletsLoadingStatusNetworkNotReachable;
}

- (void)hideError {
    _loadingView.status = SNTripletsLoadingStatusStopped;
}

#pragma mark - SNTripletsLoadingViewDelegate

- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView {
    [self hideError];
    [self loadQuestionTypeFromService];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
