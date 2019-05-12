//
//  SNPhotosListViewController.m
//  sohunews
//
//  Created by wang yanchen on 13-4-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotosListViewController.h"
#import "NSDictionaryExtend.h"
#import "SNSubChannelHeadView.h"
#import "SNDBManager.h"
#import "SNGuideRegisterManager.h"
#import "SNVideoAdContext.h"
#import "SNSubscribeCenterService.h"
#import "SNUserManager.h"
#import "SNNewsLoginManager.h"

@interface SNPhotosListViewController (){
    NSString *_channelSubId;
    SNSubChannelHeadView *_headView;
    SNToolbar *_toolbar;
    
    UIButton *_backBtn;
    UIButton *_share;
    UIButton *_downloadBtn;
    UIButton *_pubInfoBtn;
}

@property(nonatomic, copy) NSString *channelSubId;
@property(nonatomic, assign) BOOL isFromSubDetail;

@end

@implementation SNPhotosListViewController
@synthesize channelSubId = _channelSubId;
@synthesize isFromSubDetail = _isFromSubDetail;

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        self.channelSubId = [query stringValueForKey:kChannelSubId defaultValue:nil];
        self.isFromSubDetail = [[query stringValueForKey:@"fromSubDetail" defaultValue:@""] length] > 0;
        self.isPhotoList = YES;
    }
    return self;
}

- (void)dealloc {
    [[SNSubscribeCenterService defaultService] removeListener:self];
     //(_channelSubId);
     //(_headView);
     //(_toolbar);
     //(_backBtn);
     //(_share);
     //(_downloadBtn);
     //(_pubInfoBtn);
    
}

- (SNToolbar *)toolbar {
	if (!_toolbar) {//tb_new_background
        //night_tb_new_background
        UIImage  *img = [UIImage themeImageNamed:@"postTab0.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        imgView.frame = CGRectMake(0,0,320,49);
		_toolbar = [[SNToolbar alloc] initWithFrame:CGRectMake(0,
															   self.view.height - img.size.height,
															   self.view.width,
															   img.size.height)];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_toolbar addSubview:imgView];
		[self.view addSubview:_toolbar];
         imgView = nil;
        
        _toolbar.backgroundColor = [UIColor clearColor];
    }
    return _toolbar;
}

- (void)loadView {
    [super loadView];
    
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
    
    _headView = [[SNSubChannelHeadView alloc] initWithFrame:CGRectZero];
    _headView.subTitle = subObj.subName;
    _headView.subId = subObj.subId;
    _headView.isSubed = [subObj.isSubscribed isEqualToString:@"1"];
    __weak __typeof(&*self)weakSelf = self;
    _headView.action = ^{
        
        if (![SNUserManager isLogin]) {//login
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
#pragma clang diagnostic pop
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method",[NSNumber numberWithInteger:SNGuideRegisterTypeSubscribe], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
            //[SNUtility openLoginViewWithDict:dict];
            //wangshun login open
            [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//000废弃
                
            } Failed:nil];
            return ;
        }
        
        
        SCSubscribeObject *object = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:weakSelf.channelSubId];
        
        if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:object]) {
            [SNGuideRegisterManager showGuideWithSubId:weakSelf.channelSubId];
            return;
        }
        
        if (!object) {
            object = [[SCSubscribeObject alloc] init];
            object.subId = weakSelf.channelSubId;
            object.moreInfo = @"确认关注";
        }
        
        if ([object.moreInfo length] == 0) {
            object.moreInfo = @"确认关注";
        }
        
        // 统计的refer
        //        if (_refer > 0) {
        //            object.from = _refer;
        //        } else {
        //            object.from = REFER_PAPER_SUBBTN;
        //        }
        
        BOOL isSub = [object.isSubscribed isEqualToString:@"1"];
        
        NSString *succMsg = isSub ? [object succUnsubMsg] : [object succSubMsg];
        NSString *failMsg = isSub ? [object failUnsubMsg] : [object failSubMsg];
        
        if (isSub) {
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRemoveMySubToServer request:nil refId:object.subId];
            [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
            [[SNSubscribeCenterService defaultService] removeMySubToServerBySubObject:object];
        } else {
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:object.subId];
            [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
            [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:object];
        }

//        _headView.isSubed = YES;
    };
//    [self.view addSubview:_headView];
    // 请求subinfo
    if (!subObj) {
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeSubInfo];
        [[SNSubscribeCenterService defaultService] loadSubInfoFromServerBySubId:self.channelSubId];
    }
    
    // tool bar
    
    // 返回按钮
    _backBtn = [[UIButton alloc] init];
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage themeImageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setBackgroundColor:[UIColor clearColor]];
    
    _backBtn.accessibilityLabel = @"返回";
    
    _share = [[UIButton alloc] init];
	[_share setImage:[UIImage themeImageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
	[_share setImage:[UIImage themeImageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
	[_share addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
	[_share setBackgroundColor:[UIColor clearColor]];
    
    _share.accessibilityLabel = @"分享";
    
    _downloadBtn = [[UIButton alloc] init];
	[_downloadBtn setImage:[UIImage themeImageNamed:@"tb_new_download.png"] forState:UIControlStateNormal];
	[_downloadBtn setImage:[UIImage themeImageNamed:@"tb_new_download_hl.png"] forState:UIControlStateHighlighted];
	[_downloadBtn addTarget:self action:@selector(downloadClicked:) forControlEvents:UIControlEventTouchUpInside];
	[_downloadBtn setBackgroundColor:[UIColor clearColor]];
    
    _downloadBtn.accessibilityLabel = @"离线下载";
    
    _pubInfoBtn = [[UIButton alloc] init];
    [_pubInfoBtn setImage:[UIImage themeImageNamed:@"tb_more.png"] forState:UIControlStateNormal];
    [_pubInfoBtn setImage:[UIImage themeImageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
    [_pubInfoBtn addTarget:self action:@selector(pubInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_pubInfoBtn setBackgroundColor:[UIColor clearColor]];
    
    _pubInfoBtn.accessibilityLabel = @"刊物信息";
    
    [self.toolbar setButtons:[NSArray arrayWithObjects:_backBtn, _downloadBtn, _share, _pubInfoBtn, nil]];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.frame = CGRectMake(0, _headView.bottom, self.view.width, self.view.height - _toolbar.height - _headView.height + 8);
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.frame = CGRectMake(0, kSystemBarHeight, self.view.width, self.view.height - _toolbar.height - _headView.height + 8);
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

- (void)viewDidUnload {
     //(_headView);
     //(_toolbar);
     //(_backBtn);
     //(_share);
     //(_downloadBtn);
     //(_pubInfoBtn);
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
    _headView.isSubed = [subObj.isSubscribed boolValue];
    
    self.tableView.tableHeaderView = _headView;
    self.tableView.frame = CGRectMake(0, kSystemBarHeight, self.view.width, self.view.height + 8);
}

// empty override
- (void)showAdView {
}
- (void)hideAdView {
}

- (void)enableScrollToTop {
    self.tableView.scrollsToTop = YES;
}

- (void)updateTheme:(NSNotification *)notifiction {
    //[self didReceiveMemoryWarning];
    [self updateTheme];
    
    [_headView updateTheme];
    
    [_toolbar removeFromSuperview];
     //(_toolbar);
    
    [_backBtn setImage:[UIImage imageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage imageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
    
	[_share setImage:[UIImage imageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
	[_share setImage:[UIImage imageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
    
	[_downloadBtn setImage:[UIImage imageNamed:@"tb_new_download.png"] forState:UIControlStateNormal];
	[_downloadBtn setImage:[UIImage imageNamed:@"tb_new_download_hl.png"] forState:UIControlStateHighlighted];
    
    [_pubInfoBtn setImage:[UIImage imageNamed:@"tb_more.png"] forState:UIControlStateNormal];
    [_pubInfoBtn setImage:[UIImage imageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
    
    [self.toolbar setButtons:[NSArray arrayWithObjects:_backBtn, _downloadBtn, _share, _pubInfoBtn, nil]];
}

#pragma mark - SNSubscribeCenterServiceDelegate
// 统一的数据回调
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if (dataSet.operation == SCServiceOperationTypeSubInfo) {
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
        _headView.subTitle = subObj.subName;
        _headView.subId = subObj.subId;
        _headView.isSubed = [subObj.isSubscribed isEqualToString:@"1"];
    }
    
    self.tableView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - actions
- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [[SNSubscribeCenterService defaultService] removeListener:self];
    }
}

- (void)onBack:(id)sender {
    [[SNSubscribeCenterService defaultService] removeListener:self];
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(id)sender {
    
}

- (void)downloadClicked:(id)sender {
    
}

- (void)pubInfoClicked:(id)sender {
    if (self.isFromSubDetail) {
        [self onBack:nil];
    }
    else {
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.channelSubId];
        if (!subObj) {
            subObj = [[SCSubscribeObject alloc] init];
            subObj.subId = self.channelSubId;
        }
        subObj.openContext = @{@"fromNewsPaper" : @"YES"};
        [subObj openDetail];
    }
}

@end
