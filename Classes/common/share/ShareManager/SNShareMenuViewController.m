//
//  SNShareMenuViewController.m
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareMenuViewController.h"
#import "SNShareItemsView.h"
#import "SNNewsShareHeader.h"
#import "SNNewsShareParamsHeader.h"
#import "SNNewsShareManager.h"
#import "AppDelegate+ApplicationAssistant.h"
#import "SNAdvertiseManager.h"
#import "SNCloseAdImageView.h"

@interface SNShareMenuViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, SNNewAlertViewDelegate>

@property (nonatomic,strong) SNShareMenuViewModel* viewModel;
@property (nonatomic, strong) SNNewAlertView* alertView;
@property (nonatomic, strong) SMPageControl* pageControl;
@property (nonatomic, strong) SNCloseAdImageView *adView;
@property (nonatomic, strong) NSDictionary* shareData;//分享数据
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation SNShareMenuViewController

-(instancetype)initWithData:(NSDictionary*)dic{
    if (self = [super init]) {
        [SNUtility registerSharePlatform];
        if (_viewModel == nil) {
            self.viewModel = [[SNShareMenuViewModel alloc] initWithData:dic];
            self.shareData = dic;
            self.didDisAppearShareView = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark -  showActionMenu

- (void)showActionMenu {
    [self showActionMenuFromView:nil];
}

- (void)showActionMenuFromView:(UIView *)fromView {
    UIView* v = [self createShareView];
    [self.view setFrame:v.bounds];
    [self.view addSubview:v];
    
    SNNewAlertView *actionSheet = [[SNNewAlertView alloc] initWithContentView:self.view backgroundColor:[UIColor clearColor] alertStyle:SNNewAlertViewStyleActionSheet];
    actionSheet.delegate = self;
    self.alertView = actionSheet;
    
    if (nil == fromView) {
        [actionSheet show];
    } else {
        [actionSheet showInView:fromView];
    }
}

// MARK: - 截屏分享 TODO:交给王舜
- (void)showScreenShotShareView {
    __weak typeof(self)weakself = self;
    SNShareItemsView *screenShotShareView = [[SNShareItemsView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 100) shareItems:self.viewModel.shareIconsArr handler:^(NSString *title) {
        [weakself.alertView dismiss];
    }];
    SNNewAlertView *actionSheet = [[SNNewAlertView alloc] initWithContentView:screenShotShareView cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    actionSheet.delegate = self;
    self.alertView = actionSheet;
    [actionSheet show];
}

#pragma mark -  createShareView
// MARK: - 分享 TODO:待设计确定再调整
- (UIView *)setupShareView {
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 200)];
    __weak typeof(self)weakself = self;
    SNShareItemsView *firstView = [[SNShareItemsView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 100) shareItems:self.viewModel.shareIconsArr handler:^(NSString *title) {
        [weakself.alertView dismiss];
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(shareIconSelected:ShareData:)]) {
            CGFloat delayTime = 0;
            if (kAppScreenWidth > kAppScreenHeight) {
                delayTime = 0.2;
                [SNUtility forceScreenPortrait];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.delegate shareIconSelected:title ShareData:weakself.shareData];
            });
        }
    }];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 100, kAppScreenWidth - 40, 1)];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    
    SNShareItemsView *secondView = [[SNShareItemsView alloc] initWithFrame:CGRectMake(0, 100, kAppScreenWidth, 100) shareItems:self.viewModel.shareIconsArr handler:^(NSString *title) {
        [weakself.alertView dismiss];
    }];
    
    [shareView addSubview:firstView];
    [shareView addSubview:secondView];
    [shareView addSubview:lineView];
    
    return shareView;
}

- (UIView *)createShareView {
    SNChannelsAdData * sharePageAD = [[SNAdvertiseManager sharedManager] sharePageAD];
    CGFloat cancelBtnHeight = 48.0f;
    CGFloat iphoneXBottomOffSet = [SNDevice sharedInstance].isPhoneX ? 18.0 : 0;
    CGFloat shareHeight = 155 + 2*kShareIconImgWidth + cancelBtnHeight + iphoneXBottomOffSet;
    BOOL adEnable = sharePageAD.enable && (shareHeight + 130/2.f + 20 < kAppScreenHeight);
    CGFloat adHeight = adEnable ? 130/2.f : 0;
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, shareHeight + adHeight)];
    coverView.backgroundColor = [UIColor clearColor];
    if (adEnable) { // 添加广告展示
        __weak __typeof(self)weakSelf = self;
        self.adView = [[SNCloseAdImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, adHeight)
                                                    closeAction:^(id sender) {
                                                        [sharePageAD didManualClosedAD];
                                                        [weakSelf.adView removeFromSuperview];
                                                        weakSelf.adView = nil;
                                                        coverView.top -= adHeight;
                                                        weakSelf.alertView.height -= adHeight;
                                                        weakSelf.alertView.top += adHeight;
                                                        
                                                    } clikcAction:^{
                                                        if (sharePageAD.adClickUrl.length > 0) {
                                                            [weakSelf.alertView dismiss];
                                                            sohunewsAppDelegate * delegate = (sohunewsAppDelegate *)[UIApplication sharedApplication].delegate;
                                                            [delegate.splashViewController enterApp];
                                                            [SNUtility shouldUseSpreadAnimation:NO];
                                                            [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_clk&_tp=pv&apid=%@&from=2",sharePageAD.adId]];
                                                            [SNUtility openProtocolUrl:sharePageAD.adClickUrl context:nil];
                                                        }
                                                    }];
        [self.adView setCloseButtonOrigin:CGPointMake(_adView.width - 40, 10)];
        [coverView addSubview:self.adView];
        self.adView.backgroundColor = [UIColor clearColor];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width * scale;
        CGFloat imageHeight = scale == 3 ? 215 : 130;
        [self.adView loadImageWithUrl:sharePageAD.adImageUrl size:CGSizeMake(imageWidth, imageHeight) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (image) {
                self.adView.closeEnable = YES;
                self.adView.hidden = NO;
                [self.adView setBottomLineHidden:NO];
                [self.adView setBackgroundViewHidden:NO];
                [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_expos&_tp=pv&apid=%@&from=2",sharePageAD.adId]];
            }else{
                coverView.frame = CGRectMake(0, 0, kAppScreenWidth, shareHeight);
                [self.adView removeFromSuperview];
                self.adView = nil;
                coverView.top -= adHeight;
                self.alertView.height -= adHeight;
                self.alertView.top += adHeight;
            }
        }];
    }
    
    UIView *shareView = [[SNNavigationBar alloc] initWithFrame:CGRectMake(0, adHeight, [UIScreen mainScreen].bounds.size.width, shareHeight)];
    [coverView addSubview:shareView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:shareView.bounds];
    whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:[SNThemeManager sharedThemeManager].isNightTheme ? 0:0.6];
    [shareView addSubview:whiteView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 16, 100, 20)];
    titleLabel.text = @"分享到";
    
    NSString* floatTitle = [self.shareData objectForKey:SNNewsShare_ShareViewTitle];
    if (floatTitle&&floatTitle.length>0) {
        titleLabel.text = floatTitle;
    }
    
    titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [shareView addSubview:titleLabel];
    CGFloat margin = (kAppScreenWidth - kShareIconImgWidth * 4) / 5 / 2;
    SNShareCollectionViewLayout *flowLayout = [[SNShareCollectionViewLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(kShareIconImgWidth + 2 * margin, 25+kShareIconImgWidth);
    flowLayout.minimumLineSpacing = 20;
    flowLayout.minimumInteritemSpacing = 0;
    CGFloat offset = (kAppScreenWidth == 667) ? (margin - 5) : margin; // 暂时还不知道原因
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, offset, 0, offset)];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 46, kAppScreenWidth, (25 + kShareIconImgWidth)*2 + 25) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.clipsToBounds = NO;
    [self.collectionView registerClass:[SNShareCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([SNShareCollectionViewCell class])];
    [shareView addSubview:self.collectionView];
    
    SMPageControl *pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 14, 160+2*kShareIconImgWidth - 25, 28, 15)];
    pageControl.currentPage = 0;
    pageControl.numberOfPages = self.viewModel.shareIconsArr.count % 8 ? (self.viewModel.shareIconsArr.count / 8 + 1):self.viewModel.shareIconsArr.count / 8;
    pageControl.numberOfPages = self.viewModel.shareIconsArr.count % 8 ? (self.viewModel.shareIconsArr.count / 8 + 1):self.viewModel.shareIconsArr.count / 8;
    pageControl.indicatorMargin = 5.0f;
    pageControl.indicatorDiameter = 5.5f;
    pageControl.hidesForSinglePage = YES;
    [shareView addSubview:pageControl];
    
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.pageIndicatorTintColor = [UIColor colorFromString:[SNThemeManager sharedThemeManager].isNightTheme ? @"#343434":@"#dadada"];;
    pageControl.currentPageIndicatorTintColor = [UIColor colorFromString:[SNThemeManager sharedThemeManager].isNightTheme ? @"#4e4e4e":@"#b1b1b1"];;
    self.pageControl = pageControl;
    
    // cancelButton
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(0, shareView.height - cancelBtnHeight - iphoneXBottomOffSet, kAppScreenWidth, cancelBtnHeight);
    [shareView addSubview:cancelButton];
    // lineView
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cancelButton.top, kAppScreenWidth, 0.5)];
    lineView.backgroundColor = [SNThemeManager sharedThemeManager].isNightTheme ? SNUICOLOR(kThemeBg1Color):SNUICOLOR(kThemeBg1Color);
    [shareView addSubview:lineView];
    
    return coverView;
}

/// 点击了取消按钮
- (void)cancelButtonClicked {
    [self.alertView dismiss];
    [self shareCompletionHandle];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.viewModel.shareIconsArr[indexPath.item][kShareIconTitle];
    __weak typeof(self)weakself = self;
    [self.alertView dismissWithCompletion:^{
        if (weakself.delegate && [weakself.delegate respondsToSelector:@selector(shareIconSelected:ShareData:)]) {
            CGFloat delayTime = 0;
            if (kAppScreenWidth > kAppScreenHeight) {
                delayTime = 0.2;
                [SNUtility forceScreenPortrait];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself.delegate shareIconSelected:title ShareData:weakself.shareData];
            });
            
        }
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.shareIconsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SNShareCollectionViewCell class]) forIndexPath:indexPath];
    
    [cell setDataWithDict:self.viewModel.shareIconsArr[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    SNShareCollectionViewCell *cell = (SNShareCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setImageViewStateWithHightlighted:YES andDict:self.viewModel.shareIconsArr[indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    SNShareCollectionViewCell *cell = (SNShareCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setImageViewStateWithHightlighted:NO andDict:self.viewModel.shareIconsArr[indexPath.item]];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    self.pageControl.currentPage = index;
}

#pragma mark - SNNewAlertViewDelegate
- (void)willDisAppearAlertView:(SNNewAlertView *)alertView withButtonIndex:(NSInteger)buttonIndex {
    [[SNUtility sharedUtility] setLastOpenUrl:nil];//避免二代协议打开浮层，再次点击不能打开
}

- (void)didAppearAlertView:(SNNewAlertView *)alertView{
    SNDebugLog(@"didAppearAlertView");
}

- (void)didDisAppearAlertView:(SNNewAlertView *)alertView
              withButtonIndex:(NSInteger)buttonIndex {
    SNDebugLog(@"didDisAppearAlertView:::%d",buttonIndex);
    self.didDisAppearShareView = YES;
    if (1 == buttonIndex) { // 点击了浮层空白区域
        [self shareCompletionHandle];
    }
}

- (void)shareCompletionHandle {
    sohunewsAppDelegate *delegate = (id)[UIApplication sharedApplication].delegate;
    if (delegate.shareCompletionBlock) {
        NSString *providerId = nil;
        BOOL success = NO;
        NSString *aid = nil;
        NSString *vid = nil;
        delegate.shareCompletionBlock(0, providerId, success, aid, vid);
    }
}

- (void)dealloc {
    if (self.collectionView) {
        self.collectionView.delegate = nil;
        self.collectionView.dataSource = nil;
        self.collectionView = nil;
    }
}

@end
