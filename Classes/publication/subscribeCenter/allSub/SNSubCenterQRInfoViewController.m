//
//  SNSubCenterQRInfoViewController.m
//  sohunews
//
//  Created by jojo on 13-7-30.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNSubCenterQRInfoViewController.h"
#import "SNSubscribeCenterService.h"
#import "NSDictionaryExtend.h"
#import "SNActionMenuController.h"
#import "UIColor+ColorUtils.h"
#import "SNWebImageView.h"
#import "SNNewsShareManager.h"

@interface SNSubCenterQRInfoViewController () {
    UIImageView *_qrBgImageView;
    SNWebImageView *_qrImageView;
    
    UILabel *_subNameLabel;
    UILabel *_infoLabel;
    
    // toolbar buttons
    UIButton *_backButton;
    UIButton *_saveImageButton;
    UIButton *_shareQRImageButton;
    
    BOOL _hasImageLoaded;
}

@property(nonatomic, strong) SNActionMenuController *actionMenuController;
@property(nonatomic, strong) SNNewsShareManager *shareManager;

// data source
@property(nonatomic, strong) NSDictionary *subQRInfoDic;
@property(nonatomic, copy) NSString *subId;
@property(nonatomic, copy) NSString *subName;

@end

@implementation SNSubCenterQRInfoViewController
@synthesize subQRInfoDic = _subQRInfoDic;
@synthesize subId = _subId;
@synthesize subName = _subName;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        // use cache first
        self.subQRInfoDic = [query dictionaryValueForKey:@"subQR" defalutValue:nil];
        
        if (self.subQRInfoDic) {
            self.subId = [self.subQRInfoDic stringValueForKey:@"subId" defaultValue:nil];
            self.subName = [self.subQRInfoDic stringValueForKey:@"subName" defaultValue:nil];
        }
        else {
            self.subId = [query stringValueForKey:@"subId" defaultValue:nil];
            
            if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                // 需要从服务器获取数据
                [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeSubQRInfo];
                [[SNSubscribeCenterService defaultService] loadSubQRInfoFromServerBySubId:self.subId];
            }
            else {
                [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            }
        }
        
        if (query) {
            self.queryDic = [NSMutableDictionary dictionaryWithDictionary:query];
        }
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return paper_2dimensional;
}

- (NSString *)currentOpenLink2Url {
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:nil];
}

- (void)dealloc {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    
     //(_subQRInfoDic);
     //(_subId);
     //(_subName);
    
    _actionMenuController.delegate = nil;
     //(_actionMenuController);
    
     //(_qrBgImageView);
     //(_qrImageView);
     //(_backButton);
     //(_saveImageButton);
     //(_shareQRImageButton);
    
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorFromString:@"#303237"];
    
    [self initQRImageView];
    
    [self addToolbar];
    
    [self reloadViewData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
     //(_qrBgImageView);
     //(_qrImageView);
     //(_backButton);
     //(_saveImageButton);
     //(_shareQRImageButton);
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

#pragma mark - actions
- (void)saveImageAction:(id)sender {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if (!_hasImageLoaded) {
        SNDebugLog(@"%@: image is still loading", NSStringFromSelector(_cmd));
        return;
    }
    UIImageWriteToSavedPhotosAlbum(_qrImageView.image, [SNUtility getApplicationDelegate], @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//自媒体二维码分享
- (void)shareQRImageAction:(id)sender {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if (!_hasImageLoaded) {
        SNDebugLog(@"%@: image is still loading", NSStringFromSelector(_cmd));
        return;
    }
    
    
#if 1 //wangshun share test
    
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    NSString * protocol = [NSString stringWithFormat:@"subHome://subId=%@",_subId];
    [mDic setObject:protocol forKey:@"url"];
    [mDic setObject:@"subDetail" forKey:@"shareLogType"];
    [self callShare:mDic];
    return;
#endif
    
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    _actionMenuController.delegate = self;
    _actionMenuController.shareSubType = ShareSubTypeQuoteText;
    _actionMenuController.contextDic = [self createActionMenuContentContext];
    NSString * protocolUrl = [NSString stringWithFormat:@"subHome://subId=%@",_subId];
    [_actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    _actionMenuController.shareLogType = @"subDetail";
    _actionMenuController.disableLikeBtn = YES;
    _actionMenuController.disableSMSBtn = YES;
    [_actionMenuController showActionMenu];
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}


#pragma mark - SNActionMenuControllerDelegate

- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *urlPath = [self.subQRInfoDic stringValueForKey:@"markUrl" defaultValue:nil];
    if (urlPath) {
        [dic setObject:urlPath forKey:kShareInfoKeyImageUrl];
    }
    
    NSString *shareContent = [self.subQRInfoDic stringValueForKey:@"shareContent" defaultValue:nil];
    if (shareContent) {
        [dic setObject:shareContent forKey:kShareInfoKeyContent];
    }
    
    if (self.subName) {
        [dic setObject:self.subName forKey:kShareInfoKeyTitle];
    }
    
    if (self.subId) {
        [dic setObject:self.subId forKey:@"subId"];
    }
    
    // log
    if ([self.subId length] > 0) {
        [dic setObject:self.subId forKey:kShareInfoKeyNewsId];
    }
    
    if ([shareContent length] > 0) {
        [dic setObject:shareContent forKey:kShareInfoKeyShareContent];
    }
    
    return dic;
}

#pragma mark - SNSubscribeCenterServiceDelegate

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeSubQRInfo) {
        if ([dataSet.strongDataRef isKindOfClass:[NSDictionary class]]) {
            if ([self.subId isEqualToString:[(NSDictionary *)dataSet.strongDataRef stringValueForKey:@"subId" defaultValue:@""]]) {
                self.subQRInfoDic = dataSet.strongDataRef;
                self.subName = [self.subQRInfoDic stringValueForKey:@"subName" defaultValue:nil];
                
                [self reloadViewData];
            }
        }
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
}

#pragma mark - private

- (void)addToolbar {
    CGRect appFrame = TTApplicationFrame();
    CGFloat toolbarHeight = 45;
    CGFloat toolbarSideMargin = 4;
    
    UIView *toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, appFrame.size.height - toolbarHeight, self.view.width, toolbarHeight)];
    toolbarView.backgroundColor = [UIColor colorFromString:@"#303237"];
    [self.view addSubview:toolbarView];
    
    UIImage *backImage = [UIImage imageNamed:@"photo_slideshow_back.png"];
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(toolbarSideMargin, (toolbarView.height - backImage.size.height) / 2,
                                                             backImage.size.width,
                                                             backImage.size.height)];
    [_backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_backButton setImage:backImage forState:UIControlStateNormal];
    _backButton.accessibilityLabel = @"返回";
    [toolbarView addSubview:_backButton];
    
    UIImage *shareImage = [UIImage imageNamed:@"photo_slideshow_share.png"];
    _shareQRImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                     shareImage.size.width,
                                                                     shareImage.size.height)];
    _shareQRImageButton.centerY = _backButton.centerY;
    _shareQRImageButton.right = toolbarView.width - toolbarSideMargin;
    [_shareQRImageButton addTarget:self action:@selector(shareQRImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [_shareQRImageButton setImage:shareImage forState:UIControlStateNormal];
    _shareQRImageButton.accessibilityLabel = @"分享";
    [toolbarView addSubview:_shareQRImageButton];
    
    UIImage *saveImage = [UIImage imageNamed:@"photo_slideshow_download.png"];
    _saveImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                  saveImage.size.width,
                                                                  saveImage.size.height)];
    _saveImageButton.right = _shareQRImageButton.left - 4;
    _saveImageButton.centerY = _backButton.centerY;
    [_saveImageButton addTarget:self action:@selector(saveImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [_saveImageButton setImage:saveImage forState:UIControlStateNormal];
    _saveImageButton.accessibilityLabel = @"保存";
    [toolbarView addSubview:_saveImageButton];
    
     //(toolbarView);
}

- (void)initQRImageView {
    if (!_qrBgImageView) {
        UIImage *bgImage = [UIImage imageNamed:@"subcenter_detail_qr_bg.png"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height / 2 - 1,
                                                                        bgImage.size.width / 2 - 1,
                                                                        bgImage.size.height / 2 - 1,
                                                                        bgImage.size.width / 2 - 1)];
        
        _qrBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                       self.view.width,
                                                                       415)];
        _qrBgImageView.image = bgImage;
        _qrBgImageView.contentMode = UIViewContentModeScaleToFill;
        _qrBgImageView.clipsToBounds = YES;
        [self.view addSubview:_qrBgImageView];
    }
    
    // 如果是iphone 5 居中放
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight > 480) {
        screenHeight -= 20; // status bar height
        screenHeight -= 45; // tool bar height
        _qrBgImageView.centerY = screenHeight / 2;
    }
    
    if (!_qrImageView) {
        _qrImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(0, 0, 270, 270)];
        _qrImageView.top = _qrBgImageView.top + 30;
        _qrImageView.centerX = CGRectGetMidX(self.view.bounds);
        [_qrImageView setDefaultImage:[UIImage imageNamed:@"info_sohu_news.png"]];
        [self.view addSubview:_qrImageView];
    }
    
    if (!_subNameLabel) {
        _subNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  _qrImageView.bottom + 14 / 2,
                                                                  _qrImageView.width,
                                                                  34 / 2 + 1)];
        _subNameLabel.backgroundColor = [UIColor clearColor];
        _subNameLabel.centerX = _qrImageView.centerX;
        _subNameLabel.textAlignment = NSTextAlignmentCenter;
        _subNameLabel.textColor = RGBCOLOR(120, 120, 120);
        _subNameLabel.font = [UIFont systemFontOfSize:34 / 2];
        [self.view addSubview:_subNameLabel];
    }
    _subNameLabel.text = self.subName;
    
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_subNameLabel.left,
                                                               _subNameLabel.bottom + 82 / 2,
                                                               _subNameLabel.width,
                                                               24 / 2 + 1)];
        _infoLabel.text = @"扫描二维码，关注你喜欢的媒体账号";
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.font = [UIFont systemFontOfSize:24 / 2];
        _infoLabel.textColor = RGBCOLOR(141, 141, 141);
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_infoLabel];
    }
}

- (void)reloadViewData {
    _hasImageLoaded = NO;
    _saveImageButton.enabled = NO;
    _shareQRImageButton.enabled = NO;
    
    // 忽略无图模式
    NSString *urlPath = [self.subQRInfoDic stringValueForKey:@"markUrl" defaultValue:nil];
    [_qrImageView loadUrlPath:urlPath completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            _hasImageLoaded = YES;
            _saveImageButton.enabled = YES;
            _shareQRImageButton.enabled = YES;
        }
        if(error){
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        }
    }];
}

@end
