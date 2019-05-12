//
//  SNNewsPaperWebController.m
//  Three20Learning
//
//  Created by zhukx on 5/15/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#define LOGO_VIEW_HEIGHT                        (62)
#define TERM_DATE                                (@"termDate")
#define PUB_LOGO                                 (@"pubLogo51")
#define PUB_LOGO2                                (@"pubLogo52")
#import "SNNewsPaperWebController.h"
#import "SNPaperItem.h"
#import "SNSubItem.h"
#import "SNNotificationCenter.h"
#import "SNToolbar.h"
#import "SNDBManager.h"
#import "SNHistoryController.h"
#import "SNAlert.h"
#import "SNPaperHistoryItem.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"
#import "SNDownloadManager.h"
#import "SNShareConfigs.h"
#import "SNUserManager.h"


#if kNeedDownloadRollingNews
#import "SNDownloadScheduler.h"
#endif

#import "RegexKitLite.h"

#import "NSDate-Utilities.h"
#import "SNSubscribeCenterService.h"
#import "SNSubscribeAlertView.h"
#import "SNSubscribeHintPushAlertView.h"
#import "SNDatabase_CloudSave.h"
#import "TBXML.h"
#import "NSObject+YAJL.h"
#import "SNTimelinePostService.h"
#import "SNCommentEditorViewController.h"
#import "SNDatabase+ReadFlag.h"
#import "SNTimelinePostService.h"
#import "SNDatabase_ReadCircle.h"
#import "SNCommentEditorViewController.h"
#import "SNGuideRegisterManager.h"
#import "SNClientRegister.h"

#import "SNMyFavouriteManager.h"
#import "SNVideoAdContext.h"

#import "SNNewsShareManager.h"
#import "SNNewsLoginManager.h"


#define LinkRegexExpress  (@"<\\s*a.+?href=(\'|\")(.+?)(\'|\").*?>((.|\\n)*?)<\\s*/\\s*a\\s*>|(http://|https://|www\\.|3g\\.)[\\./a-z0-9_-]*((\\?[a-z0-9]+=[a-z0-9\\u4E00-\\u9FFF]*)(&[a-z0-9]+=[a-z0-9\\u4E00-\\u9FFF]*)*)*(#[a-z0-9_-]*)?")

@interface SNNewsPaperWebController () {
    SNSubscribeAlertView *_subscribeAlertView;
    SNSubscribeHintPushAlertView *_subAddAlertView;
    
    BOOL _bShouldRefreshUpdateDate;
    int _refer;
    BOOL _isOpenFromPaper;
    SNTimelineOriginContentObject *_shareObj;
}


@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) SNNewsShareManager *shareManager;
@property (nonatomic, strong) UIView *adView;

- (void)downloadClicked:(id)sender;
- (void)doStartDownload;
- (void)downloadClickedCancel:(id)sender;
- (void)stopAction:(id)sender;
- (void)wangqiAction;

- (void)parseResponseForParams:(NSDictionary *)responseHeader;
- (bool)isNewsAvailableOnDisk:(NSString*)termId newsId:(NSString*)newsId userInfo:(NSMutableDictionary *)userInfo;
- (NSString *)findSubStrFromStr:(NSString *)str withKey:(NSString *)key;
- (void)addASubscribe;
- (void)showRefreshTabItem;
- (void)showStopTabItem;
- (void)addMyFavourite;
- (void)removeMyFavourite;
- (void)saveOneVisit;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SNNewsPaperWebController
@synthesize paperItem = _paperItem;
@synthesize subItem = _subItem;
@synthesize isDownloading = _isDownloading;
@synthesize webConnection = _webConnection;
@synthesize htmlData = _htmlData;
@synthesize webRequest = _webRequest;
@synthesize pubId;
@synthesize pubName;
@synthesize pubTime;
@synthesize adView;
@synthesize visitStack = _visitStack;
@synthesize linkType = _linkType;
@synthesize redirectToURL = _redirectToURL;
@synthesize isContinuous;
@synthesize queryDic = _queryDic;

#pragma mark -
#pragma mark Controller lifecycle
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super init]) {
        adRefreshCount = 0;
        self.title = NSLocalizedString(@"SohuNews", nil);
        if (query) {
            self.queryDic = [NSMutableDictionary dictionaryWithDictionary:query];
        }
        
        SNDebugLog(@"SNNewsPaperWebController query description : %@, linkType：%@", [query description], [query objectForKey:@"linkType"]);
		_backController = [query objectForKey:@"backcontroller"];
        
		_linkType = [[query objectForKey:@"linkType"] copy];
        SNDebugLog(SN_String("INFO: linkType: %@"), _linkType);
        
        _protoParamsFeedbackStr = [[query objectForKey:kProtocolParamsFeedback] copy];
        
        _refer = [[query objectForKey:kRefer] intValue];
        
		id newItem = [query objectForKey:@"subitem"];
        SNDebugLog(@"new item class %@",[newItem class]);
        if ([newItem isKindOfClass:[NewspaperItem class]]) {
            self.subId = [(NewspaperItem *)newItem subId];
            self.pubId = [(NewspaperItem *)newItem pubId];
            self.pubTime = [(NewspaperItem *)newItem termTime];
            self.pubName = [(NewspaperItem *)newItem termName];
        } else {
            self.pubId = ([newItem respondsToSelector:@selector(pubIds)] ? [newItem pubIds] : [newItem pubId]);
            self.subId = [newItem subId];
            if ([newItem respondsToSelector:@selector(pubName)]) {
                self.pubName = [newItem pubName];
            } else if ([newItem respondsToSelector:@selector(termName)]){
                
                self.pubName = [newItem termName];
            }
            if([newItem respondsToSelector:@selector(termTime)]){
                self.pubTime = [newItem termTime];
            }
        }
        [super setSubId:self.subId];
        
        if ([newItem respondsToSelector:@selector(termId)]) {
            [super setTermId:[newItem termId]];
        }
        SNDebugLog(SN_String("INFO: subId: %@, termId: %@, pubId: %@"), [newItem subId], [newItem termId], [newItem pubId]);
		if ([query objectForKey:@"notification"]) {
			_isNotification = YES;
		}
        
        _isFromMySubList = !![query objectForKey:@"FromMySubList"];
        _isFromSubDetail = !![query objectForKey:@"fromSubDetail"];
        _isOpenFromPaper = !![query objectForKey:@"openFrom"];
        
	    //HomeV3接口
		if ([_linkType isEqualToString:@"SUBLIST"] && [newItem isKindOfClass:[SubscribeHomeMySubscribePO class]]) {
			SubscribeHomeMySubscribePO *existItem = nil;
            //如果是用户点击进入刊物首页
            if (!_isNotification) {
                SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:[newItem subId]];
                if (subObj) {
                    existItem = [subObj toSubscribeHomeMySubscribePO];
                }

            }
            //如果是通过推送通知进入刊物首页
            else {
                SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectByPubId:self.pubId];
                if (subObj) {
                    existItem = [subObj toSubscribeHomeMySubscribePO];
                }

                SNDebugLog(@"INFO: existItem is [%@]", [existItem description]);
                _pubIDsForWangQiAction = [existItem.pubIds copy];
            }
			if (existItem) {
				if ([newItem lastTermLink]) {
					existItem.lastTermLink = [newItem lastTermLink];
				}
				if ([newItem pubName]) {
					existItem.subName = [newItem subName];
                    SNDebugLog(@"existItem.subName : %@",existItem.subName);
				}
				if ([newItem pubId] && [[newItem pubId] length]) {
					existItem.pubIds = [newItem pubId];
				}
				newItem = existItem;
			}
		}        
        
        self.subItem = newItem;
		
        //从往期列表进入
		NSString *isNavigatedFromWangqi	= [query objectForKey:@"navigateFromWangqi"];
        
        SNDebugLog(@"isNavigatedFromWangqi : %@",isNavigatedFromWangqi);
        
		if ([isNavigatedFromWangqi length] != 0 && [isNavigatedFromWangqi isEqualToString:@"1"]) {
			_isNavigatedFromWangqi = YES;
            [super setIsHistory:isNavigatedFromWangqi];
		}
		else {
			_isNavigatedFromWangqi = NO;
            [super setIsHistory:nil];
		}
        
        _isOffLineMode = NO;
		_isFirstLoad	= YES;
        
        // save opentimes
        SCSubscribeObject *object = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
        if (object) {
            NSString *openTimes = [NSString stringWithFormat:@"%d", [object.openTimes intValue] + 1];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:openTimes, TB_SUB_CENTER_ALL_SUB_OPEN_TIMES, nil];
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:object.subId withValuePairs:dic];
        }
        
        [SNNotificationManager addObserver:self selector:@selector(pushNotificationWillCome) name:kNotifyDidReceive object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateNonPicMode:) name:kNonePictureModeChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(handleMySubDidChangedNotify:) name:kSubscribeCenterMySubDidChangedNotify object:nil];
    }
    
    return self;
}

- (SNCCPVPage)currentPage {
    return paper_main;
}

- (NSString *)currentOpenLink2Url {
    return [self.queryDic stringValueForKey:kOpenProtocolOriginalLink2 defaultValue:nil];
}

- (SNPaperItem *)paperItem {
	if (!_paperItem) {
		_paperItem = [[SNPaperItem alloc] init];
	}
	return _paperItem;
}

- (NSString *)pubTime
{
    if ([pubTime rangeOfString:@"-"].location == NSNotFound && [pubTime length] > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        self.pubTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:([pubTime floatValue] / 1000)]];
        return pubTime;
    }
    
    if(pubTime && pubTime.length >= 10){
        return [pubTime substringToIndex:10];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        self.pubTime = [formatter stringFromDate:[NSDate date]];
        return pubTime;
    }
}

- (void)setSubItem:(SNSubItem *)newItem {
	if (newItem && _subItem != newItem) {
		 //(_subItem);
		_subItem = newItem;
        SNDebugLog(@"INFO: subId:%@-----pubId:%@", [_subItem subId], [_subItem pubId]);
		self.paperItem.subId = [_subItem subId];
		self.paperItem.pubId = [_subItem pubId];
        self.paperItem.termId = newItem.termId;

		if ([_linkType isEqualToString:@"SUBLIST"]) {
			self.paperItem.termName = [_subItem pubName];
		} 
		else {
			self.paperItem.termName = [_subItem termName];
		}

		
		self.paperItem.termId = [_subItem termId];
		//_history.badgeString = _subItem.noReadCount;
	}
}

- (void)setIsDownloading:(BOOL)isDown {
	_isDownloading = isDown;
	if (_isDownloading) {
		_downloadBtn.enabled = NO;
	}
	else {
		_downloadBtn.enabled = YES;
	}
}

-(void)dealloc {
    [SNNotificationManager removeObserver:self];
	if (_isDownloading) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"RunInBackground", @"您有下载任务未完成，将转入后台进行") toUrl:nil mode:SNCenterToastModeOnlyText];
	}
    [_webConnection cancel];
    _actionMenuController.delegate = nil;
 }

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    _isVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    _isVisible = YES;
    
    [self enableOrDisableDownloadBtn];
    
    _webView.frame = CGRectMake(0, kSystemBarHeight, 320, kAppScreenHeight - kToolbarViewTop -kSystemBarHeight);
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    SNDebugLog(@"INFO: %@--%@, _isNotification : %d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _isNotification);
    //如果是用户点击进入新闻页
    
    // 根据相应条件决定是否显示订阅按钮
    SCSubscribeObject *po = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_paperItem.subId];
    
    if (!po) {
        po =  [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectByPubId:_paperItem.pubId];
    }
    
    if (po == nil || ![po.isSubscribed boolValue]) {
        logoView.state = UnSubcribe;
    } else {
        logoView.state = Subscribe;
    }
}

- (void)setPaperLogo {
    NewspaperItem *localNewspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:_paperItem.termId];
    
    if (localNewspaper) {
        logoView.normalLogoUrl = localNewspaper.normalLogo;
        logoView.nightLogoUrl = localNewspaper.nightLogo;
        
        if([[SNThemeManager sharedThemeManager].currentTheme isEqualToString:kThemeNight]) {
            if (logoView.nightLogoUrl.length > 0) {
                [logoView setLogoUrl:logoView.nightLogoUrl];
            }
        } else {
            if (logoView.normalLogoUrl.length > 0) {
                [logoView setLogoUrl:logoView.normalLogoUrl];
            }
        }
    }
}

- (void)refreshNewspaper {
    
	NSString *linkStr = nil;
    //技持HomeV3接口
	if ([_linkType isEqualToString:@"SUBLIST"] && [_subItem isKindOfClass:[SubscribeHomeMySubscribePO class]]) {
        if (_refreshFromDrag) {
            if (self.paperItem.termId && ![self.paperItem.termId isEqualToString:@"0"]) {
                linkStr = [NSString stringWithFormat:kUrlTermPaper, self.paperItem.termId];
            } else {
                linkStr = [_subItem lastTermLink];
            }
            
            linkStr = [linkStr stringByAppendingString:@"&pull=1"];
        } else {
            linkStr = [_subItem lastTermLink];
        }
	}
	else if ([_linkType isEqualToString:@"SUBLIST"] && [_subItem isKindOfClass:[SubscribeItem class]]) {
		linkStr = [_subItem lastTermLink];
        if (_refreshFromDrag) {
            linkStr = [linkStr stringByAppendingString:@"&pull=1"];
        }
	}
	else if ([_linkType isEqualToString:@"HISTORYLIST"] && [_subItem isKindOfClass:[SubscribeHomeImageItem class]]) {
		linkStr = [_subItem link];
	}
    
    _refreshFromDrag = NO;
    
    SNDebugLog(@"INFO: %@--%@, Refresh newspaper with url : %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), linkStr);
    NSString *currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    
    if ([linkStr length]) {
        if ([currentTheme isEqualToString:kThemeNight]) {
            linkStr = [linkStr stringByAppendingString:@"&mode=1"];
        }
        if ([SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
            if (!_shouldUseSlidershow) {
                linkStr = [linkStr stringByAppendingString:@"&noPic=1"];
            }
        }
        if (_protoParamsFeedbackStr.length > 0) {
            linkStr = [linkStr stringByAppendingString:_protoParamsFeedbackStr];
        }
        
		[self openURL:[NSURL URLWithString:linkStr]];
        return;
	}
    
    if([_linkType isEqualToString:@"LOCAL"])
    {
        if([_subItem isKindOfClass:[NewspaperItem class]])
        {
            linkStr = [_subItem realNewspaperPath];
            
            SNDebugLog(@"linkStr===%@",linkStr);
            
            NSFileManager *fm	 = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:linkStr]) {
                _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
                _isOffLineMode = YES;
                self.title = [_subItem termName];
                //[self openURL:[NSURL fileURLWithPath:linkStr]];

                NSString *currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
                NSError *error = nil;
                NSString *htmContent = [NSString stringWithContentsOfFile:linkStr encoding:NSUTF8StringEncoding error:&error];
                [self checkPaperTemplateId:htmContent];
                
                if ([currentTheme isEqualToString:kThemeNight]) {
                    htmContent = [self switchMode:htmContent];
                    [_webView loadHTMLString:htmContent baseURL:[NSURL fileURLWithPath:linkStr]];
                } else {
                    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:linkStr]]];
                }
            }
        }
    }
}

- (void)updateTheme:(NSNotification*)notification {
    if ([self isViewLoaded]) {
        [self updateBackgroundColor];
        
        [logoView updateTheme];
        
        [_toolbar removeFromSuperview];
        _toolbar = nil;
        
        [_backBtn setImage:[UIImage imageNamed:@"tb_new_back.png"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"tb_new_back_hl.png"] forState:UIControlStateHighlighted];
        
        [_share setImage:[UIImage imageNamed:@"icotext_share_v5.png"] forState:UIControlStateNormal];
        [_share setImage:[UIImage imageNamed:@"icotext_sharepress_v5.png"] forState:UIControlStateHighlighted];
        
        [_history setImage:[UIImage imageNamed:@"tb_new_history.png"] forState:UIControlStateNormal];
        [_history setImage:[UIImage imageNamed:@"tb_new_history_hl.png"] forState:UIControlStateHighlighted];
        
        [_downloadBtn setImage:[UIImage imageNamed:@"tb_new_download.png"] forState:UIControlStateNormal];
        [_downloadBtn setImage:[UIImage imageNamed:@"tb_new_download_hl.png"] forState:UIControlStateHighlighted];
        
        [_pubInfoBtn setImage:[UIImage imageNamed:@"tb_more.png"] forState:UIControlStateNormal];
        [_pubInfoBtn setImage:[UIImage imageNamed:@"tb_more_hl.png"] forState:UIControlStateHighlighted];
        
        
        [self.toolbar setButtons:[NSArray arrayWithObjects:_backBtn,_history, _downloadBtn, _share, _pubInfoBtn, nil]];
        

        [self resetEmptyHTML];
        [self refreshNewspaper];
    }
}

- (void)updateNonPicMode:(NSNotification*)notification {
    if ([self isViewLoaded]) {
        [self resetEmptyHTML];
        [self refreshNewspaper];
    }
}

//过滤html
- (NSString *)switchMode:(NSString *)htmContent {
	NSString *bodyHtml = [htmContent stringByMatching:@"<body.*?>" options:RKLCaseless inRange:(NSRange){0, NSUIntegerMax} capture:0 error:NULL];
	if (bodyHtml) {
		NSString *bodyHtmlWithClass = [bodyHtml stringByReplacingOccurrencesOfString:@">" withString:@" class=\"Mode1\">"];
        htmContent = [htmContent stringByReplacingOccurrencesOfString:bodyHtml withString:bodyHtmlWithClass];
	}
    return htmContent;
}

- (void)loadView {
	[super loadView];

    logoView = [[SNPaperLogoView alloc] initWithFrame:CGRectMake(0, 0, 320, 61) Delegate:self];
    [logoView setDateString:self.pubTime];
    logoView.isAccessibilityElement = YES;
    logoView.accessibilityLabel = self.pubName;
    
    logoView.subId = self.subId;
    logoView.pubName = self.pubName;
    UIScrollView *scrollView = _webView.scrollView;
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        [self.view addSubview:logoView];//故意让logo头部悬浮顶部抢占voiceover焦点，防止voiceover看完一篇文章点返回之后总是回到报纸第一个新闻
    } else {
        logoView.top = -logoView.height;
        [scrollView addSubview:logoView];
    }

    _dragView.frame = CGRectMake(0, -logoView.height - _dragView.height, _dragView.width, _dragView.height);
    _dragView.hidden = NO;

    SCSubscribeObject *po = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
    
    if (!po && self.pubId) {
        po =  [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectByPubId:self.pubId];
    }
    
    if (po == nil || [po.isSubscribed boolValue]) {
        logoView.state = Subscribe;
    } else {
        logoView.state = UnSubcribe;
    }
    
    // 设置logo
    [self setPaperLogo];

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
	[_share addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
	[_share setBackgroundColor:[UIColor clearColor]];
    
    _share.accessibilityLabel = @"分享";
    _share.enabled = NO;
    
    _history = [[UIButton alloc] init];
	[_history setImage:[UIImage themeImageNamed:@"tb_new_history.png"] forState:UIControlStateNormal];
	[_history setImage:[UIImage themeImageNamed:@"tb_new_history_hl.png"] forState:UIControlStateHighlighted];
	[_history addTarget:self action:@selector(wangqiAction) forControlEvents:UIControlEventTouchUpInside];
	[_history setBackgroundColor:[UIColor clearColor]];
    
    _history.accessibilityLabel = @"往期内容";
    
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
    
    _pubInfoBtn.accessibilityLabel = @"媒体信息";
    
    [self.toolbar setButtons:[NSArray arrayWithObjects:_backBtn,_history, _downloadBtn, _share, _pubInfoBtn, nil]];

    if ([SNPreference sharedInstance].debugModeEnabled) {
        if (![_linkType isEqualToString:@"LOCAL"]) {
    //        SNDebugLog(@"subId:%@--pubId:%@--noReadCount:%@", [_subItem subId], [_subItem pubId], [_subItem noReadCount]);
        }
    }
	
	[self refreshNewspaper];
    [self saveOneVisit];
	
	if (_subItem) {
		_history.enabled = YES;
	}
	else {
		_history.enabled = NO;
	}
	_downloadBtn.enabled = NO;
    
    [self createAdView];
    
    
    adViewClosed = YES;
    
    _webView.frame = CGRectMake(0, kSystemBarHeight, 320, kAppScreenHeight - kToolbarViewTop -kSystemBarHeight);
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        if (adViewClosed || self.adView.hidden) {
            _webScrollView.contentInset = UIEdgeInsetsMake(logoView.height , 0, kToolbarViewHeight, 0);
            [_webScrollView setContentOffset: CGPointMake(0, -logoView.height) animated:NO];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webUrlView.hidden = YES;
    self.progress.hidden = YES;
    #if kNeedDownloadRollingNews
    [[SNDownloadScheduler sharedInstance] setDelegate:self];
    #endif
}

- (void)createAdView {

    UIScrollView *scrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
    self.adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    adView.frame = CGRectMake(10, -50, 320, 50);
    adView.hidden = YES;
    [scrollView addSubview:adView];
}
- (void)showAdView {
    isAnimating = YES;
    UIScrollView *scrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showAdViewAnimationStopped)];
    
    self.adView.frame =  CGRectMake(10, -50, self.adView.width, self.adView.height);
    self.adView.hidden = NO;
    _dragView.frame = CGRectMake(0, -_dragView.height - adView.height - logoView.height, _dragView.frame.size.width , _dragView.frame.size.height);
    logoView.frame =CGRectMake(0, -logoView.height - adView.height, logoView.width, logoView.height);
    
    scrollView.contentInset = UIEdgeInsetsMake(logoView.height + adView.height ,0,kToolbarViewHeight,0);
    if (scrollView.contentOffset.y <= -logoView.height) {
        [scrollView setContentOffset:CGPointMake(0, -logoView.height-adView.height) animated:NO];
    }
    [UIView commitAnimations];
}

- (void)hideAdView {
    isAnimating = YES;
    UIScrollView *scrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideAdViewAnimationStopped)];
    
    self.adView.frame = CGRectMake(10, 0, adView.width, 0);
    //    scrollView.contentInset = UIEdgeInsetsZero;
    self.adView.hidden = YES;
    _dragView.frame = CGRectMake(0, -_dragView.height - logoView.height, _dragView.frame.size.width , _dragView.frame.size.height);
    logoView.frame =CGRectMake(0, -logoView.height, logoView.width, logoView.height);
    
    scrollView.contentInset = UIEdgeInsetsMake(logoView.height,0,kToolbarViewHeight,0);
    if (scrollView.contentOffset.y <= -logoView.height-adView.height) {
        [scrollView setContentOffset:CGPointMake(0, -logoView.height) animated:NO];
    }
    SNDebugLog(@"scrollView contentOffset %@",NSStringFromCGPoint(scrollView.contentOffset));
    [UIView commitAnimations];
}

- (void)showAdViewAnimationStopped {
    isAnimating = NO;
}

- (void)hideAdViewAnimationStopped {
    isAnimating = NO;
}

#pragma mark -
#pragma mark Override
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_dragView.hidden) {
        return;
    }
    CGFloat top = kWebViewRefreshDeltaY - logoView.height;
    if (!adViewClosed) {
        top = kWebViewRefreshDeltaY - 50 - logoView.height;
    }
    
    if (scrollView.dragging && !_isLoading) {
        if (scrollView.contentOffset.y > top
            && scrollView.contentOffset.y < 0.0f) {
            
            if (_bShouldRefreshUpdateDate) {
                // 这里需要一个上次刷新时间的提醒
                [_dragView refreshUpdateDate];
                _bShouldRefreshUpdateDate = NO;
            }
            
            [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
            
        } else if (scrollView.contentOffset.y < top) {
            
            [_dragView setStatus:TTTableHeaderDragRefreshReleaseToReload];
            
        } else if (scrollView.contentOffset.y > 0) {
            //            _model.isRefreshManually = isLoadingMore;
            //            _model.isRefreshManually = NO;
        }
    }
	
	// This is to prevent odd behavior with plain table section headers. They are affected by the
	// content inset, so if the table is scrolled such that there might be a section header abutting
	// the top, we need to clear the content inset.
	if (_isLoading) {
		if (scrollView.contentOffset.y >= 0) {
			scrollView.contentInset = UIEdgeInsetsMake(logoView.height, 0, kToolbarViewHeight, 0);
			
		} else if (scrollView.contentOffset.y < 0) {
            CGFloat height = kWebViewHeaderVisibleHeight + logoView.height;
            if (!adViewClosed) {
                height = kWebViewHeaderVisibleHeight + 50 +logoView.height;
            }
			scrollView.contentInset = UIEdgeInsetsMake(height, 0, kToolbarViewHeight, 0);
		}
	}
}



- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    
    if (_dragView.hidden) {
        return;
    }
    
    _bShouldRefreshUpdateDate = YES;
    
	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
    CGFloat top = kWebViewRefreshDeltaY - logoView.height;
    if (!adViewClosed) {
        top = kWebViewRefreshDeltaY - 50 - logoView.height;
    }
	if (scrollView.contentOffset.y <= top && !_isLoading) {
        _isLoading = YES;
        initialScrollPosition = 0; // fix for : 手动刷新锚点跳跃 @jojo
        [self dragViewStartLoad];
        [self refreshAction];
	}
}


- (void)dragViewStartLoad {
    if (_dragView.hidden) {
        return;
    }
    
    _refreshFromDrag = YES;

    // show drag view loading
    CGFloat top = kWebViewHeaderVisibleHeight + 50 +logoView.height;
    if (adViewClosed) {
        top = kWebViewHeaderVisibleHeight +logoView.height;
    }
    [_dragView setStatus:TTTableHeaderDragRefreshLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    
    if (_webScrollView.contentOffset.y < 0) {
        _webScrollView.contentInset = UIEdgeInsetsMake(top, 0.0f, kToolbarViewHeight, 0.0f);
    }
    [UIView commitAnimations];
    
    _webScrollView.contentInset = UIEdgeInsetsMake(top, 0.0f, kToolbarViewHeight, 0.0f);
}




- (void)dragViewFinishLoad
{
    if (_dragView.hidden) {
        return;
    }
    
    // drag view
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];

    SNDebugLog(@"adViewClosed drag = %d",adViewClosed);
    if (adViewClosed) {
        _webScrollView.contentInset = UIEdgeInsetsMake(logoView.height, 0, kToolbarViewHeight, 0);
    } else {
        _webScrollView.contentInset = UIEdgeInsetsMake(50 + logoView.height, 0, kToolbarViewHeight, 0);
    }
    if (_webScrollView.contentOffset.y < 0) {
        if (adViewClosed) {
            _webScrollView.contentOffset = CGPointMake(0, -logoView.height);
        } else {
            _webScrollView.contentOffset = CGPointMake(0, -50 - logoView.height);
        }
    }
    [UIView commitAnimations];
    
    SNDebugLog(@"webScrollView offset %@",NSStringFromCGPoint(_webScrollView.contentOffset));
    [_dragView setCurrentDate];
    _bShouldRefreshUpdateDate = YES;
}

- (void)dragViewFailLoad {
    if (_dragView.hidden) {
        return;
    }
    
    [_dragView setStatus:TTTableHeaderDragRefreshPullToReload];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];

    SNDebugLog(@"adViewClosed drag = %d",adViewClosed);
    if (adViewClosed) {
        _webScrollView.contentInset = UIEdgeInsetsMake(logoView.height, 0, kToolbarViewHeight, 0);
    } else {
        _webScrollView.contentInset = UIEdgeInsetsMake(50 + logoView.height, 0, kToolbarViewHeight, 0);
    }
    if (_webScrollView.contentOffset.y < 0) {
        if (adViewClosed) {
            _webScrollView.contentOffset = CGPointMake(0, -logoView.height);
        } else {
            _webScrollView.contentOffset = CGPointMake(0, -50 - logoView.height);
        }
    }

    [UIView commitAnimations];
}

#pragma mark -
#pragma mark SNAdBannerViewDelegate

- (void)didFinishLoadAds:(int)adsCount {
    if (isAnimating) {
        return;
    }
    adRefreshCount++;
    
    if (adsCount > 0) {
        adViewClosed = NO;
        [self showAdView];
    } else {
        adViewClosed = YES;
        [self hideAdView];
    }
    SNDebugLog(@"adViewClosed didFinishLoadAds = %d",adViewClosed);
}

- (void)didTapCloseButton {
    if (isAnimating) {
        return;
    }
    [self hideAdView];
    adViewClosed = YES;

}

#if kNeedDownloadRollingNews
#pragma mark - SNDownloadSchedulerDelegate

- (void)didFailedDownloadSub:(SCSubscribeObject *)sub {
    if (_downloadBtn && !!(sub.subId) && [sub.subId isEqualToString:_paperItem.subId] && [sub.termId isEqualToString:_paperItem.termId]) {
        _downloadBtn.enabled = YES;
    }
}

- (void)didFinishedDownloadSub:(SCSubscribeObject *)sub {
    if (_downloadBtn && !!(sub.subId) && [sub.subId isEqualToString:_paperItem.subId] && [sub.termId isEqualToString:_paperItem.termId]) {
        _downloadBtn.enabled = NO;
    }
}
#endif

#pragma mark - Public methods called by SNDownloadManager

- (void)didFailStartDownload {
    if (_downloadBtn) {
        _downloadBtn.enabled = YES;
    }
}

- (void)didFailSingleDownload:(SubscribeHomeMySubscribePO *)mySubPO {
    if (_downloadBtn && [mySubPO.subId isEqualToString:_paperItem.subId]) {
        _downloadBtn.enabled = YES;
    }
}

- (void)didSucceedSingleDownload:(SubscribeHomeMySubscribePO *)mySubPO {
    if (_downloadBtn && [mySubPO.subId isEqualToString:_paperItem.subId]) {
        _downloadBtn.enabled = NO;
    }
}

- (BOOL)canOpenByNewsProtocol:(NSString *)reqUrlStr
{
    if (reqUrlStr) {
		
        NSString* protocol = nil;
        if(NSNotFound != [reqUrlStr rangeOfString:kProtocolNews options:NSCaseInsensitiveSearch].location)
            protocol = kProtocolNews;
        else if(NSNotFound != [reqUrlStr rangeOfString:kProtocolVote options:NSCaseInsensitiveSearch].location)
            protocol = kProtocolVote;
        else
            return NO;
        
		//NSString *newsUrlPath	= [reqUrlStr substringFromIndex:[kProtocolNews length]];
		NSMutableDictionary *newsUrlPathInfo	= [SNUtility parseProtocolUrl:reqUrlStr schema:protocol];
        if (![newsUrlPathInfo objectForKey:kTermId] && [newsUrlPathInfo objectForKey:kChannelId]) {
            [newsUrlPathInfo setObject:[newsUrlPathInfo objectForKey:kChannelId] forKey:kTermId];
        }
        [newsUrlPathInfo removeObjectForKey:kChannelId];
        
        // 一代link转为二代link，termId替换channelId
        NSString *linkUrl = reqUrlStr;
        
        if (![SNUtility isProtocolV2:reqUrlStr]) {
            NSString *params = [newsUrlPathInfo toUrlString];
            if ([[params substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"&"]) {
                params = [params substringFromIndex:1];
            }
            linkUrl = [NSString stringWithFormat:@"%@%@", protocol, params];
        }
                
		if ([newsUrlPathInfo count] > 0) {
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:newsUrlPathInfo];
			if ([self isNewsAvailableOnDisk:[newsUrlPathInfo objectForKey:kTermId] newsId:[newsUrlPathInfo objectForKey:kNewsId] userInfo:userInfo]) {
				[userInfo setObject:kNewsOffline forKey:kNewsMode];
			}
			else {
				[userInfo setObject:kNewsOnline forKey:kNewsMode];
			}
			
			if ([_subItem respondsToSelector:@selector(pubName)] && [_subItem pubName]) {
				[userInfo setObject:[_subItem pubName] forKey:@"title"];
			}
            //如果是离线内容，取的是NewspaperItem，没有pubName，取termName
            else if ([_subItem respondsToSelector:@selector(termName)] && [_subItem termName]) {
                [userInfo setObject:[_subItem termName] forKey:@"title"];
            }
            
            [userInfo setObject:kReferFromPublication forKey:kReferFrom];
            
            [userInfo setObject:linkUrl forKey:kLink];
            
            // 统计
            //initialScrollPosition = [[_webView stringByEvaluatingJavaScriptFromString:@"scrollY"] intValue];
            
            //连续阅读
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            [dic setObject:userInfo forKey:kContinuityNews];
            [dic setObject:kContinuityNews forKey:kContinuityType];
            [dic setObject:self forKey:kNewsPaperPtr];
            
            if (isContinuous) {
                isContinuous = NO;
                [(SNNavigationController *)self.flipboardNavigationController setOnlyAnimation:YES];
            }
            
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:urlAction];
			return YES;
		}
	}
    
    return NO;

}

- (BOOL)canOpenByPhotoProtocol:(NSString *)reqUrlStr
{
    if (reqUrlStr &&
        NSNotFound != [reqUrlStr rangeOfString:kProtocolPhoto options:NSCaseInsensitiveSearch].location) {
		
		//NSString *newsUrlPath	= [reqUrlStr substringFromIndex:[kProtocolPhoto length]];
		NSMutableDictionary* newsUrlPathInfo	= [SNUtility parseProtocolUrl:reqUrlStr schema:kProtocolPhoto];

        if (![newsUrlPathInfo objectForKey:kTermId] && [newsUrlPathInfo objectForKey:kChannelId]) {
            [newsUrlPathInfo setObject:[newsUrlPathInfo objectForKey:kChannelId] forKey:kTermId];
        }
        [newsUrlPathInfo removeObjectForKey:kChannelId];

		if ([newsUrlPathInfo count] > 0) {
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:newsUrlPathInfo];
			if ([self isNewsAvailableOnDisk:[newsUrlPathInfo objectForKey:kTermId] newsId:[newsUrlPathInfo objectForKey:kNewsId] userInfo:userInfo]) {
				[userInfo setObject:kNewsOffline forKey:kNewsMode];
			}
			else {
				[userInfo setObject:kNewsOnline forKey:kNewsMode];
			}
            
            if ([_subItem respondsToSelector:@selector(pubName)] && [_subItem pubName]) {
				[userInfo setObject:[_subItem pubName] forKey:@"title"];
			}
            //如果是离线内容，取的是NewspaperItem，没有pubName，取termName
            else if ([_subItem respondsToSelector:@selector(termName)] && [_subItem termName]) {
                [userInfo setObject:[_subItem termName] forKey:@"title"];
            }
            
            [userInfo setObject:[NSNumber numberWithInt:GallerySourceTypeNewsPaper] forKey:kGallerySourceType];
            
            NSString *newsID = [newsUrlPathInfo objectForKey:kNewsId];
            if (newsID.length > 0) {
                [userInfo setObject:newsID forKey:kNewsId];
            }
            
            [userInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS] forKey:kMyFavouriteRefer];
            [userInfo setObject:kReferFromPublication forKey:kReferFrom];
            
            [userInfo setObject:reqUrlStr forKey:kLink];
            
            if (_shouldUseSlidershow) {
                NSString *action = @"tt://photoSlideshow";
                [userInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_PUB_MAG_HOME] forKey:kMyFavouriteRefer];
                [userInfo setValue:_paperItem.termTime forKey:kPubDate];
                
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:action] applyAnimated:YES] applyQuery:userInfo];
                [[TTNavigator navigator] openURLAction:urlAction];
                return YES;
            }
            
            // 统计
            //initialScrollPosition = [[_webView stringByEvaluatingJavaScriptFromString:@"scrollY"] intValue];
            
            //连续阅读
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            [dic setObject:userInfo forKey:kContinuityPhoto];
            [dic setObject:kContinuityPhoto forKey:kContinuityType];
            [dic setObject:self forKey:kNewsPaperPtr];

            if (isContinuous) {
                isContinuous = NO;
                [(SNNavigationController *)self.flipboardNavigationController setOnlyAnimation:YES];
            }

            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:urlAction];
			return YES;
		}
	}
    
    return NO;
}

- (void)startRequestForParsingResponse:(NSString *)reqUrlStr
{
    //update redirect url, used as base url by [loadData:MIMEType:textEncodingName:baseURL:], otherwise relative css, js, img will not be reached.
    self.redirectToURL = [NSURL URLWithString:reqUrlStr];
    
    self.webRequest = [NSMutableURLRequest requestWithURL:self.redirectToURL];
    _webRequest.timeoutInterval = WEBVIEW_REQUEST_TIMEOUT;
    [_webRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];//reduce cache usage
    if ([SNClientRegister sharedInstance].s_cookie.length > 0) {
        [_webRequest setValue:[SNClientRegister sharedInstance].s_cookie forHTTPHeaderField:@"SCOOKIE"];
    }
    self.webConnection = [NSURLConnection connectionWithRequest:_webRequest delegate:self];
}

- (BOOL)canOpenByHTTPProtocol:(NSString *)reqUrlStr navigationType:(UIWebViewNavigationType)navigationType
{
    if ([reqUrlStr hasPrefix:kProtocolHTTP]) {
        
        BOOL isSohuNewsDomain = [SNUtility isSohuDomain:reqUrlStr];
        
        if (isSohuNewsDomain) {
            
            //load current paper
            if (UIWebViewNavigationTypeOther == navigationType) {
                
                [self showInitProgress];
                
                //从推送打开，访问 term.go?termId=16553
                //从往期打开，访问 term.go?termId=16553
                //从相关推荐打开，访问 term.go?termId=16553
                NSString *termIdStr = self.paperItem.termId;
//                if (NSNotFound != [reqUrlStr rangeOfString:@"termId=" options:NSCaseInsensitiveSearch].location) {
//                    termIdStr = [self findSubStrFromStr:reqUrlStr withKey:@"termid="];
//                }
//                //从我的订阅打开，访问 lastTermLink.go?subId=107
//                //从所有订阅打开，访问 lastTermLink.go?subId=107
//                else {
//                    termIdStr = self.paperItem.termId;
//                }
                
                if (termIdStr) {
                    _paperItem.termId = termIdStr;
                    _share.enabled = NO;
                    if ([self openLocalNewspaperByTermId]) {
                        return YES;
                    }
                }
                
                //从离线列表打开，不会进入这里
                BOOL isChangedUrl = NO;
                if (NSNotFound == [reqUrlStr rangeOfString:@"u=" options:NSCaseInsensitiveSearch].location) {
                    if (NSNotFound == [reqUrlStr rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                        reqUrlStr = [reqUrlStr stringByAppendingFormat:@"?u=%@", [SNAPI productId]];
                    }
                    else {
                        reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&u=%@", [SNAPI productId]];
                    }
                    isChangedUrl = YES;
                    SNDebugLog(@"add ChanPinID ----%@", reqUrlStr);
                }
                
                if (NSNotFound == [reqUrlStr rangeOfString:@"p1=" options:NSCaseInsensitiveSearch].location) {
                    if (!_encodeUid) {
                        NSString *savedUid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
                        self.encodeUid = [[savedUid dataUsingEncoding:NSUTF8StringEncoding] base64String];
                    }
                    NSString *p1Str = [_encodeUid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    if (NSNotFound == [reqUrlStr rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                        reqUrlStr = [reqUrlStr stringByAppendingFormat:@"?p1=%@", p1Str];
                    }
                    else {
                        reqUrlStr = [reqUrlStr stringByAppendingFormat:@"&p1=%@", p1Str];
                    }
                    isChangedUrl = YES;
                    SNDebugLog(@"add p1 ----%@", reqUrlStr);
                }
                
                if (isChangedUrl) {
                    SNDebugLog(@"request url again----%@", reqUrlStr);
                    
                    [self startRequestForParsingResponse:reqUrlStr];
                    
                    return YES;
                }

            }
            
            //click 外链HTTP新闻
            if (UIWebViewNavigationTypeLinkClicked == navigationType) {
                
                // 统计
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:reqUrlStr forKey:@"address"];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:userInfo];
                
                //initialScrollPosition = [[_webView stringByEvaluatingJavaScriptFromString:@"scrollY"] intValue];
                //SNDebugLog(@"initialScrollPosition %d", initialScrollPosition);
                
                [[TTNavigator navigator] openURLAction:urlAction];
                
                return YES;
                
            }
            
            _isOffLineMode = NO;
        }
        
        //第三方外链
        else {
            
            //click 外链HTTP新闻，
            if (UIWebViewNavigationTypeLinkClicked == navigationType) {
                
                // 统计
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:reqUrlStr forKey:@"address"];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:userInfo];
                
                //initialScrollPosition = [[_webView stringByEvaluatingJavaScriptFromString:@"scrollY"] intValue];
                //SNDebugLog(@"initialScrollPosition %d", initialScrollPosition);
                
                [[TTNavigator navigator] openURLAction:urlAction];
                
                return YES;
                
            }
            //第三方外链报纸
            else {
                return NO;
            }
        }
        
	}
    
    return NO;
}

- (BOOL)canOpenByPaperProtocol:(NSString *)reqUrlStr
{
    return [reqUrlStr hasPrefix:kProtocolPaper] || [reqUrlStr hasPrefix:kProtocolDataFlow];
}

#pragma mark - share read

- (void)parseShareReadContentAndCache {
    // 解析并缓存 shareRead 字段 by jojo
    NSString *shareContentStr = nil;
    TBXML *xml = [TBXML tbxmlWithXMLData:_htmlData];
    TBXMLElement *rootElm = xml.rootXMLElement;
    TBXMLElement *headElm = [TBXML childElementNamed:@"head" parentElement:rootElm];
    TBXMLElement *metaElm = [TBXML childElementNamed:@"meta" parentElement:headElm];
    if (metaElm) {
        do {
            NSString *shareReadId = [TBXML valueOfAttributeNamed:@"name" forElement:metaElm];
            if ([shareReadId isEqualToString:@"sohunews-share"]) {
                shareContentStr = [TBXML valueOfAttributeNamed:@"content" forElement:metaElm];
                break;
            }
        } while ((metaElm = [TBXML nextSiblingNamed:@"meta" searchFromElement:metaElm]) != nil);
    }
    
    shareContentStr = [shareContentStr URLDecodedString];
    SNDebugLog(@"shareContentStr %@", shareContentStr);
    
    if (shareContentStr) {
        NSError *error = nil;
        NSDictionary *dic = [shareContentStr yajl_JSON:&error];
        if (error) {
            SNDebugLog(@"%@-%@: parse share read json error %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
        }
        if (dic && !error && [dic isKindOfClass:[NSDictionary class]]) {
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:dic];
            if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypePaper contentId:self.subId.length > 0 ? self.subId : self.termId];
        }
    }
}

#pragma mark - Read Flag
- (void)refreshReadFlag:(UIWebView *)webView {
    if (!_shouldUseSlidershow) {
        NSString *script = @"(function(){var anchorElements = document.getElementsByTagName('a'); var links; for(var i = 0;i<anchorElements.length;i++){ var anchor = anchorElements[i]; links+='|';links+=anchor.href;}  return links;})();";
        NSString *parameter =[webView stringByEvaluatingJavaScriptFromString:script];
        NSArray *linkArray = [parameter componentsSeparatedByString:@"|"];
        for (NSString *link2 in linkArray) {
            BOOL flag = [[SNDBManager currentDataBase] readFlagForLink2:[SNUtility link2Format:link2]];
            if (flag) {
                NSString *script = [NSString stringWithFormat:@"var anchorElements = document.getElementsByTagName('a'); for(var i = 0;i<anchorElements.length;i++){ var anchor = anchorElements[i]; if(anchor.href==\"%@\"){ anchor.className='markread';break;}}", link2];
                [webView stringByEvaluatingJavaScriptFromString:script];
            }
        }
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    if (_didTriggerBack) {
        return NO;
    }

	SNDebugLog(@"SNNewsPaperWebController shouldStartLoadWithRequest %@", [request.URL absoluteString]);
	NSString *reqUrlStr = [request.URL absoluteString];

    if (!_shouldUseSlidershow) {
        
        //友盟那种第三方报纸不需要处理已读
        if ([SNUtility isProtocolV2:reqUrlStr]) {
            [[SNDBManager currentDataBase] saveLink2:[SNUtility link2Format:reqUrlStr] read:YES];
            NSString *script = [NSString stringWithFormat:@"var anchorElements = document.getElementsByTagName('a'); for(var i = 0;i<anchorElements.length;i++){ var anchor = anchorElements[i]; if(anchor.href==\"%@\"){ anchor.className='markread';break;}}", reqUrlStr];
            [webView stringByEvaluatingJavaScriptFromString:script];
        }
    }
 
    
    //update redirect url, used as base url by [loadData:MIMEType:textEncodingName:baseURL:], otherwise relative css, js, img will not be reached.
    self.redirectToURL = [NSURL URLWithString:reqUrlStr];
    
    if ([SNAPI isItunes:reqUrlStr] || [reqUrlStr containsString:@"sohuExternalLink=1"]) {
        [self hideInitProgress];
        [[UIApplication sharedApplication] openURL:_redirectToURL];
        return NO;
    }

    //news://
    //vote://...
    if ([self canOpenByNewsProtocol:reqUrlStr]) {
        return NO;
    }

    //photo://
	else if ([self canOpenByPhotoProtocol:reqUrlStr]) {
        return NO;
    }
    
    //http://
	else if ([self canOpenByHTTPProtocol:reqUrlStr navigationType:navigationType]) {
        return NO;
    }
    
    //paper protocol: papper://123.xml
    //@jojo 兼容老的paper协议的同时，支持新的协议：paper://subID_termID.xml   
    else if ([self canOpenByPaperProtocol:reqUrlStr]) {
        NSDictionary *context = @{kRefer : [NSString stringWithFormat:@"%d", REFER_PUBRECOMMEND],
                                  @"openFrom" : @"paper"};
        [SNUtility openProtocolUrl:reqUrlStr context:context];
        return NO;
    }
    
    else if ([reqUrlStr hasPrefix:kProtocolSpecial] ||  // special://subId_termId.xml (subId = 0)
             [reqUrlStr hasPrefix:kProtocolLive] ||     // live://typeid_liveid
             [reqUrlStr hasPrefix:kProtocolWeibo] ||    // weibo://channelId_weiboId
             //[reqUrlStr hasPrefix:kProtocolVote] ||     // vote://...
             [reqUrlStr hasPrefix:kProtocolSub] ||        // sub://...
             [reqUrlStr hasPrefix:kProtocolNewsChannel] ||
             [reqUrlStr hasPrefix:kProtocolWeiboChannel] ||
             [reqUrlStr hasPrefix:kProtocolPhotoChannel] ||
             [reqUrlStr hasPrefix:kProtocolLiveChannel])
    {
        [SNUtility openProtocolUrl:reqUrlStr];
        return NO;
    } else {
        if (![reqUrlStr hasPrefix:kProtocolHTTP] && ![reqUrlStr hasPrefix:kProtocolFILE] && [SNUtility isWhiteListURL: request.URL]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
    }
        
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView*)webView {
    
	SNDebugLog(@"webViewDidFinishLoad %@", [webView.request.URL absoluteString]);
    
	_isLoading = NO;
	_share.enabled = YES;
    _myFavouriteBtn.enabled = YES;
	
	//[_loading stopAnimating];
    
    // cache share read content  by jojo
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self parseShareReadContentAndCache];
    });
	
	//self.title = self.subItem.pubName;
	[webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';document.body.style.webkitUserSelect='none';"];

	//going back to the last place you were in uiwebview
	if (initialScrollPosition != 0) {
		
		// Scroll to the position.
        [webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:)
                      withObject:[NSString stringWithFormat:@"window.scrollTo(0, %d);", initialScrollPosition]
                      afterDelay:0.1];
        
		SNDebugLog(@"window.scrollTo(0, %d);", initialScrollPosition);
		
		// Set the initial scroll value to zero so we don't try
		// to scroll to it again if the user navigates to another page.
		initialScrollPosition = 0;
	}
	
    //[chh 20112-05-21 modified]: 更新已读标志位
    if (_paperItem.readFlag == nil || ![_paperItem.readFlag isEqualToString:@"1"]) {
        _paperItem.readFlag  = @"1";
        
        if (_paperItem.termName && _paperItem.termId) {
            NSDictionary *updateValuePairs	= [NSDictionary dictionaryWithObject:_paperItem.readFlag forKey:TB_NEWSPAPER_READFLAG];
            BOOL bSucceed	= [[SNDBManager currentDataBase] updateNewspaperByTermId:_paperItem.termId withValuePairs:updateValuePairs];
            if (bSucceed) {
                SNDebugLog(@"%@", @"update succeeded!");
            }
        }
    }
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        _webScrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
        
        if (adViewClosed || self.adView.hidden) {
            _webScrollView.contentInset = UIEdgeInsetsMake(logoView.height , 0, kToolbarViewHeight, 0);
            [_webScrollView setContentOffset: CGPointMake(0, -logoView.height) animated:NO];
        } else {
            _webScrollView.contentInset = UIEdgeInsetsMake(logoView.height+adView.height , 0, kToolbarViewHeight, 0);
            [_webScrollView setContentOffset: CGPointMake(0, -logoView.height-adView.height) animated:NO];
        }
    }
    [self dragViewFinishLoad];
    
    [self refreshReadFlag:webView];
    
}

- (void)webViewDidStartLoad:(UIWebView*)webView {
	//[super webViewDidStartLoad:webView]; DO NOT call super method, because super class will insert block view. we need to show loading logo long enough.
	
	_isLoading = YES;
    [_dragView setStatus:TTTableHeaderDragRefreshLoading];
	
	_back.enabled = [_webView canGoBack];
	_front.enabled = [_webView canGoForward];
	_share.enabled = NO;

	SNDebugLog(@"webViewDidStartLoad : URL = %@",[_webView.request.URL absoluteString]);
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {

    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        _webScrollView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
        
        if (adViewClosed || self.adView.hidden || self.adView.height == 0) {
            _webScrollView.contentInset = UIEdgeInsetsMake(logoView.height , 0, kToolbarViewHeight, 0);
            [_webScrollView setContentOffset: CGPointMake(0, -logoView.height) animated:NO];
        }
    }

    [self dragViewFailLoad];
	SNDebugLog(@"didFailLoadWithError--%d--%@", error.code, [error description]);
	if (kCFURLErrorBadURL == error.code || 
		kCFURLErrorUnsupportedURL == error.code ||
		kCFURLErrorCannotFindHost == error.code ||
		kCFURLErrorTimedOut == error.code ||
		kCFURLErrorCannotConnectToHost == error.code ||
		kCFURLErrorNotConnectedToInternet == error.code) {
		_isLoading = NO;
		
		//[_loading stopAnimating];
		
		[self webViewDidFinishLoad:webView];
		
		NSArray *papers = nil;
        
        SNPaperItem *localNewspaper = (SNPaperItem *)[[SNDBManager currentDataBase] getNewspaperByTermId:_paperItem.termId];
        
        // chh：这一块代码进不去，项目中找不到其他@"HOMELIST"
        if (localNewspaper && [_linkType isEqualToString:@"HOMELIST"]) {
            if (localNewspaper != nil 
				&& [localNewspaper.downloadFlag isEqualToString:@"1"] 
				&& [localNewspaper.newspaperPath length] != 0) {
				//本地数据库查询到zip包已经下载，判断zip包是否有效
				self.paperItem = localNewspaper;
                NSString *realpath = [localNewspaper realNewspaperPath];
                
				NSFileManager *fm	 = [NSFileManager defaultManager];
				if ([fm fileExistsAtPath:realpath]) {
					//zip包有效，则从本地加载，取消此次网络请求
					_isOffLineMode = YES;
					//[self updateOfflineDownloadMode];
					self.title = localNewspaper.termName;
					[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:realpath]]];
                    return;
				}
			}
        }
        
		if ([_linkType isEqualToString:@"SUBLIST"]) {            
			papers = [[SNDBManager currentDataBase] getNewspaperDownloadedListBySubId:_paperItem.subId];
		}
		else if ([_linkType isEqualToString:@"HISTORYLIST"]) {
			papers = [[SNDBManager currentDataBase] getNewspaperDownloadedListByPubId:_paperItem.pubId];
		}
		 
		if (papers.count) {
			SNPaperItem *localNewspaper = [papers lastObject];//[papers objectAtIndex:0];
			NSString *realpath = [localNewspaper realNewspaperPath];
            
			if (localNewspaper != nil 
				&& [localNewspaper.downloadFlag isEqualToString:@"1"] 
				&& [realpath length] != 0) {
				//本地数据库查询到zip包已经下载，判断zip包是否有效
				self.paperItem = localNewspaper;
				NSFileManager *fm	 = [NSFileManager defaultManager];
				if ([fm fileExistsAtPath:realpath]) {
					//zip包有效，则从本地加载，取消此次网络请求
					_isOffLineMode = YES;
					//[self updateOfflineDownloadMode];
					self.title = localNewspaper.termName;
                    
                    NSString *currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
                    NSError *error = nil;
                    NSString *htmContent = [NSString stringWithContentsOfFile:realpath encoding:NSUTF8StringEncoding error:&error];
                    [self checkPaperTemplateId:htmContent];
                    
                    if ([currentTheme isEqualToString:kThemeNight]) {
                        htmContent = [self switchMode:htmContent];
                        [_webView loadHTMLString:htmContent baseURL:[NSURL fileURLWithPath:realpath]];
                    } else {
                        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:realpath]]];
                    }
				}
                return;
			}
		}
		
		else {
			//self.navigationItem.rightBarButtonItem = _downloadBarBtn;
            [self showErrorView:NSLocalizedString(@"LoadFailRefresh", @"")];
		}
	}
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    [self showLoading];
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    SNDebugLog(SN_String("INFO: Request url : %@"), [[response URL] absoluteString]);
    
    //第三方报纸重定向
    self.redirectToURL = [response URL];
    
    SNDebugLog(@"response header :%@",((NSHTTPURLResponse *)response).allHeaderFields);
	self.htmlData = [NSMutableData data];
	[self parseResponseForParams:[(NSHTTPURLResponse *)response allHeaderFields]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_htmlData appendData:data];
}

- (BOOL)openLocalNewspaperByTermId
{
    //查询本地缓存，是否已经下载该报纸的zip包
    NewspaperItem *localNewspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:_paperItem.termId];
    if (localNewspaper != nil 
        && [localNewspaper.downloadFlag isEqualToString:@"1"] 
        && [localNewspaper.newspaperPath length] != 0) {
        
        // 如果当前publishTime与下载包的publishTime不一致，则不打开本地termId的zip包
        if (_isFromMySubList) {
            SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
            if (subObj) {
                if (![subObj.publishTime isEqualToString:localNewspaper.publishTime]) {
                    SNDebugLog(@"mysub.publistTime != newspaper.publishTime, do not open local newspaper");
                    return NO;
                }
            }
        }
        
        //本地数据库查询到zip包已经下载，判断zip包是否有效
        self.paperItem = (SNPaperItem *)localNewspaper;
        
        NSString *paperPath = [localNewspaper realNewspaperPath];
        
        NSFileManager *fm	 = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:paperPath]) {
            //zip包有效，则从本地加载，取消此次网络请求
            _isOffLineMode = YES;
            _downloadBtn.enabled = NO;
            //[self updateOfflineDownloadMode];
            self.title = localNewspaper.termName;
            
            SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:localNewspaper.subId];
            if (subObj) {
                self.pubName = subObj.subName;
                logoView.pubName = subObj.subName;
                self.pubTime = localNewspaper.termTime;
                [logoView setDateString:self.pubTime];
                if([subObj.isSubscribed isEqualToString:@"1"]){
                    [logoView setState:Subscribe];
                } else {
                    [logoView setState:UnSubcribe];
                }
            }
            else {
                self.pubName = localNewspaper.termName;
                self.pubTime = localNewspaper.termTime;
                
                [logoView setDateString:localNewspaper.termTime];
                logoView.pubName = localNewspaper.termName;
                [logoView setState:UnSubcribe];
            }
            
            // 本地报纸没有logourl  这里需要传nil 将logoimageview 隐藏 否则之前显示的logo可能与当前的刊物不符; by jojo
            [logoView setLogoUrl:nil];
            
            SNDebugLog(@"localNewspaper.termName : %@",localNewspaper.termName);

            NSString *currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
            NSError *error = nil;
            NSString *htmContent = [NSString stringWithContentsOfFile:paperPath encoding:NSUTF8StringEncoding error:&error];
            [self checkPaperTemplateId:htmContent];
            
            if ([currentTheme isEqualToString:kThemeNight]) {
                htmContent = [self switchMode:htmContent];
                [_webView loadHTMLString:htmContent baseURL:[NSURL fileURLWithPath:paperPath]];
            } else {
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:paperPath]]];
            }
            
            //离线内容
            //统计报纸的打开信息
            if (_isFirstLoad) {
                _isFirstLoad	= NO;
            }
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)openLastLocalNewspaperBySubIdOrPubId
{
    //不确定termId，就取最近一期
    
	NSArray *papers = nil;
    
    if ([_linkType isEqualToString:@"SUBLIST"]) {        
        papers = [[SNDBManager currentDataBase] getNewspaperDownloadedListBySubId:_paperItem.subId];
    }
    else if ([_linkType isEqualToString:@"HISTORYLIST"]) {
        papers = [[SNDBManager currentDataBase] getNewspaperDownloadedListByPubId:_paperItem.pubId];
    }
    
    if (papers.count) {
        SNPaperItem *localNewspaper = [papers objectAtIndex:0];//[papers lastObject];
        
        if (localNewspaper != nil 
            && [localNewspaper.downloadFlag isEqualToString:@"1"] 
            && [localNewspaper.newspaperPath length] != 0) {
            //本地数据库查询到zip包已经下载，判断zip包是否有效
            self.paperItem = localNewspaper;
            NSString *realpath = [localNewspaper realNewspaperPath];
            
            NSFileManager *fm	 = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:realpath]) {
                //zip包有效，则从本地加载，取消此次网络请求
                _isOffLineMode = YES;
                //[self updateOfflineDownloadMode];
                self.title = localNewspaper.termName;
                //[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:realpath]]];
                NSString *currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
                NSError *error = nil;
                NSString *htmContent = [NSString stringWithContentsOfFile:realpath encoding:NSUTF8StringEncoding error:&error];
                [self checkPaperTemplateId:htmContent];
                
                if ([currentTheme isEqualToString:kThemeNight]) {
                    htmContent = [self switchMode:htmContent];
                    [_webView loadHTMLString:htmContent baseURL:[NSURL fileURLWithPath:realpath]];
                } else {
                    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:realpath]]];
                }
            }
            return YES;
        }
    }
 
    return NO; 
}

- (BOOL)openLocalNewspaper
{
    if (_isNavigatedFromWangqi) {
        return [self openLocalNewspaperByTermId];
    } else if ([_linkType isEqualToString:@"HISTORYLIST"]) {
        return [self openLocalNewspaperByTermId];
    } else if ([_linkType isEqualToString:@"SUBLIST"]) {
        return [self openLastLocalNewspaperBySubIdOrPubId];
    }
    return NO;
}

- (void)checkPaperTemplateId:(NSString *)htmlContent {
    NSString *htmlTag = [htmlContent stringByMatching:@"<html.*?>" options:RKLCaseless inRange:(NSRange){0, NSUIntegerMax} capture:0 error:NULL];
	if (htmlTag) {
        NSString *htmlAttr = [htmlTag stringByMatching:@"date-templateId=\"\\d+\"" options:RKLCaseless inRange:(NSRange){0, NSUIntegerMax} capture:0 error:NULL];
        if (htmlAttr.length > 0) {
            NSUInteger location = @"date-templateId=\"".length;
            NSUInteger length   = htmlAttr.length - location - 1;
            NSString *typeNum = [htmlAttr substringWithRange:NSMakeRange(location,length)];
            if ([typeNum isEqualToString:@"8"]) {
                _shouldUseSlidershow = YES;
            } else {
                _shouldUseSlidershow = NO;
            }
        } else {
            _shouldUseSlidershow = NO;
        }
	} else {
        _shouldUseSlidershow = NO;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *htmlContent = [[NSString alloc] initWithData:_htmlData encoding:NSUTF8StringEncoding];
    [self checkPaperTemplateId:htmlContent];
     //(htmlContent);
    
    [_webView loadData:_htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:_redirectToURL];
    
    SNDebugLog(@"_htmlData %@", [NSString stringWithCString:[_htmlData bytes] encoding:NSUTF8StringEncoding]);
    
    // 看画报类刊物时非wifi提醒
    if (_shouldUseSlidershow) {
        [SNUtility showNoWifiTipForPhotosWithKey:@"photoNoWifiInfoPub"];
    }

    if (_isFirstLoad) {
        _isFirstLoad	= NO;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    // 打开失败，尝试打开本地已离线的报纸
    BOOL openLocalSuccess = NO;
    if (_isFromMySubList) {
        // hack 打开指定term的离线报纸，忽略publishTime
        _isFromMySubList = NO;
       openLocalSuccess = [self openLocalNewspaperByTermId];
        _isFromMySubList = YES;
    }
    
    if (!openLocalSuccess) {
        //    [self showRefreshTabItem];
        [self showErrorView:NSLocalizedString(@"LoadFailRefresh", @"")];
        [self hideInitProgress];
    }
    
    _isLoading = NO;
    [self dragViewFailLoad];
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

#pragma mark - Override methods

- (SNToolbar *)toolbar { 
	if (!_toolbar) {//tb_new_background
              //night_tb_new_background
        UIImage  *img = [UIImage  themeImageNamed:@"postTab0.png"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
        imgView.frame = CGRectMake(0,0,320,49);
		_toolbar = [[SNToolbar alloc] initWithFrame:CGRectMake(0, 
															   kAppScreenHeight - img.size.height,
															   self.view.width, 
															   img.size.height)];
        
        [_toolbar addSubview:imgView];
		[self.view addSubview:_toolbar];
         imgView = nil;
        
        _toolbar.backgroundColor = [UIColor clearColor];
    }
    return _toolbar;
}

#pragma mark -
#pragma mark private method
- (void)doBack {
    /*
     SNDebugLog(@"before pop num of stack = %d", _visitStack.count);
     // 先把当前的历史pop出来
     if ([self.visitStack count] > 0) {
     [self.visitStack pop];
     }
     SNDebugLog(@"after pop num of stack = %d", _visitStack.count);
     // 再去判断之前有没有浏览历史
     if ([self.visitStack count] > 0) {
     NSDictionary *oneVisitInfo = [_visitStack pop];
     [_visitStack push:oneVisitInfo];
     _linkType = [oneVisitInfo objectForKey:@"linkType"];
     self.subItem = [oneVisitInfo objectForKey:@"subItem"];
     NSNumber *posObj = [oneVisitInfo objectForKey:@"scrollY"];
     if (posObj) {
     initialScrollPosition = [posObj intValue];
     }
     
     [self resetEmptyHTML];
     [self showLoading];
     [self refreshNewspaper];
     SNDebugLog(@"after back num of stack = %d", _visitStack.count);
     
     // 设置当前logo
     [self setPaperLogo];
     
     return;
     }
     */
    
#if 0 //3.3版返回刊物时不弹提示
    SCSubscribeObject *po = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
    
    if (![po.isSubscribed boolValue] && ![po.backPromotion boolValue] && [po.openTimes intValue] > 1) {
        NSString *titleStr = [NSString stringWithFormat:@"您还未订阅《%@》", po.subName];
        _subscribeAlertView = [[[SNSubscribeAlertView alloc]
                                initWithTitle:titleStr
                                message:NSLocalizedString(@"subscribe hint", @"")
                                delegate:self
                                cancelButtonTitle:NSLocalizedString(@"not subscribe for now", @"")
                                otherButtonTitle:NSLocalizedString(@"subscribe now", @"")] autorelease];
        _subscribeAlertView.snAlertUserData = po;
        [_subscribeAlertView show];
        return;
    }
#endif
    
    //为了解决：刊物首页点某新闻后快速点back后页面错乱，即一旦点返后webView的shouldStartLoadWithRequest不处理；
    //另注意：_didTriggerBack在这里而没有在这个方法的第一行设为YES，
    //是为避免在刊物首页最下方原地打开一个推荐刊物首页然后点back时上一刊物首页打不开了，因为原地打开刊物首页再back时把_didTriggerBack设为YES了；
    _didTriggerBack = YES;
    
    //如果返回到我的订阅列表时webView还在loading，则stopLoading;防止Back时TT内存回收本controller时webView还在loading，从而程序crash；
    if ([_webView isLoading]) {
        [_webView stopLoading];
    }
    
#if kNeedDownloadRollingNews
    [[SNDownloadScheduler sharedInstance] removeDelegate:self];
#endif
    
    // do remove listener immediately
    [[SNSubscribeCenterService defaultService] removeListener:self];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        [self doBack];
    }
}

- (void)onBack:(id)sender
{
    [self doBack];
    if(_isNotification)
    {
        //[self.flipboardNavigationController popToRootViewControllerAnimated:NO];
        [SNUtility popToTabViewController:self];
        [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
        //推荐中点击查看更多的操作的操作也是返回到头条流并刷新，故发送kRecommendReadMoreDidClickNotification
        [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kClickSohuIconBackToHomePageKey]];
    }
    else
    {
        [self.flipboardNavigationController popViewControllerAnimated:YES];
    }
}

- (void)handleWebViewProgressDidChange:(NSNotification *)notification {
    if (notification.object == _webView) {
        CGFloat progress = [[notification userInfo] floatValueForKey:kSNWebViewCurrentProgressValueKey
                                                        defaultValue:0];
        
        SNDebugLog(@"progressChanged :%f",progress);
        if (progress > 0) {
            _loading.status = SNEmbededActivityIndicatorStatusStopLoading;
        }
        
        CGRect f = _progress.frame;
        f.size.width = TTScreenBounds().size.width * progress;
        _progress.frame = f;
        
        if (1 == progress) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1];
            
            _progress.alpha = 0;
            
            [UIView commitAnimations];
        } else {
            _progress.alpha = 1;
        }
    }
}

- (void)wangqiAction {
    //统计
    
	if (_isNavigatedFromWangqi/* && _visitStack.count == 1*/)
    {
		[self.flipboardNavigationController popViewControllerAnimated:YES];
	}
	else {
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
		if (_paperItem && _linkType) {
            
            SNDebugLog(@"INFO: PubID is [%@] SubId = %@", _paperItem.pubId, _paperItem.subId);
            
			[userInfo setObject:_paperItem forKey:@"paperitem"];
			[userInfo setObject:_linkType forKey:@"linkType"];
            if (!!_pubIDsForWangQiAction) {
                [userInfo setObject:_pubIDsForWangQiAction forKey:kPubIDsForWangQiAction];
            }

			TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://wangqi"] applyAnimated:YES] applyQuery:userInfo];
			[[TTNavigator navigator] openURLAction:urlAction];
		}
	}
}

- (void)showRefreshTabItem
{
//    [self.toolbar replaceButtonAtIndex:0 withItem:_refresh];
}

- (void)showStopTabItem
{
//    [self.toolbar replaceButtonAtIndex:0 withItem:_stopBtn];
}

- (void)stopAction:(id)sender {
	if (_webConnection) {
		[_webConnection cancel];
	}
	[_webView stopLoading];
	//[_loading stopAnimating];
}

- (void)refreshAction {
    
    SNDebugLog(@"%d===%d",[self isError], _isFirstLoad);
    if (self.isError) {
        if ([SNUtility getApplicationDelegate].isNetworkReachable) {
            [self resetEmptyHTML];
            [self showLoading];
        }
    } else {
        if (_isFirstLoad) {
            [self showLoading];
        } else {
            [self.loading removeFromSuperview];
        }
    }
    [self refreshNewspaper];
}

- (void)downloadClickedCancel:(id)sender {
	self.isDownloading = NO;
	[[SNDBManager currentDataBase] cancelRequestByUrl:_paperItem.termZip];
}

- (void)downloadClicked:(id)sender {
    //统计
    //如果网络不可用提示网络不可用；
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }

    //2G、3G网络下进行流量警告
    if ([SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        SNActionSheet *actionSheet = [[SNActionSheet alloc] initWithTitle:NSLocalizedString(@"network_2g_3g", @"")
                                                                        delegate:self
                                                                       iconImage:[UIImage imageNamed:@"act_dataflow_notice.png"]
                                                                         content:NSLocalizedString(@"waste_data_bandwidth", @"")
                                                                      actionType:SNActionSheetTypeDefault
                                                               cancelButtonTitle:NSLocalizedString(@"stop_downloading", @"")
                                                          destructiveButtonTitle:nil
                                                               otherButtonTitles:@[NSLocalizedString(@"download anyway", @"")]];
        [[TTNavigator navigator].window addSubview:actionSheet];
        [actionSheet showActionViewAnimation];
        return;
    }
    
    //Wifi网络环境下就直接下载
    [self doStartDownload];
}

- (void)doStartDownload {
	_downloadBtn.enabled = NO;
	if (_paperItem == nil) {
        _downloadBtn.enabled = YES;
		return;
	}
    
    #if kNeedDownloadRollingNews
    SCSubscribeObject *_subObj = [[SCSubscribeObject alloc] init];
    _subObj.subId = _paperItem.subId;
    _subObj.pubIds = _paperItem.pubId;
    _subObj.termName = _paperItem.termName;
    _subObj.termId = _paperItem.termId;
    _subObj.publishTime = _paperItem.termTime;
    
    [[SNDownloadScheduler sharedInstance] setDelegate:self];
    [[SNDownloadScheduler sharedInstance] downloadSub:_subObj];
    
    #else
    SubscribeHomeMySubscribePO *_mySubscribeHomePO = nil;
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_paperItem.subId];
    if (subObj) {
        _mySubscribeHomePO = [subObj toSubscribeHomeMySubscribePO];
    }
    else {
        _mySubscribeHomePO = [[[SubscribeHomeMySubscribePO alloc] init] autorelease];
        _mySubscribeHomePO.subId = _paperItem.subId;
    }
    _mySubscribeHomePO.termTime = _paperItem.termTime;
    _mySubscribeHomePO.pubIds = _paperItem.pubId;
    _mySubscribeHomePO.termName = _paperItem.termName;
    _mySubscribeHomePO.termId = _paperItem.termId;
    [[SNDownloadManager sharedInstance] addSpecifiedDownloadingItemImmediatlyWith:_mySubscribeHomePO];
    #endif
}

- (void)pubInfoClicked:(id)sender {
    if (_isFromSubDetail/* && [_visitStack count] == 1*/) {
        [self onBack:nil];
    }
    else {
        if ([self.subItem respondsToSelector:@selector(subId)]) {
            NSString *__subId = [self.subItem subId];
            if ([__subId length] > 0) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:__subId forKey:@"subId"];
                [dic setObject:@"1" forKey:@"fromNewsPaper"];

                if (_refer > 0) {
                    [dic setObject:[NSNumber numberWithInt:_refer] forKey:kRefer];
                }

                TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:dic];
                [[TTNavigator navigator] openURLAction:action];
            }
        }
    }
}

- (NSString *)findSubStrFromStr:(NSString *)str withKey:(NSString *)key {
	NSString *pathUrl = nil;
	NSString *resultStr = nil;
	NSRange range = [str rangeOfString:key options:NSCaseInsensitiveSearch];
	if (NSNotFound != range.location) {
		pathUrl = [str substringFromIndex:range.location + range.length];
		NSRange aRange = [pathUrl rangeOfString:@"&"];
		if (NSNotFound != aRange.location) {
			resultStr = [pathUrl substringToIndex:aRange.location];
		}
	}
	return resultStr;
}

- (void)parseResponseForParams:(NSDictionary *)responseHeader {
	SNDebugLog(@"INFO: %@--%@, parseResponseForParams--%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), responseHeader);
	NSString *termIdStr = nil;
	NSString *termNameStr = nil;
	NSString *termTimeStr = nil;
	NSString *pubIdStr = nil;
    NSString *logoNormarlUrl = nil;
    NSString *logoNightUrl = nil;
    NSString *logoDateStr = nil;
    NSString *subIdStr = nil;
    NSString *needLogin = nil;
	/*********************************************************************************************************************************************************
     * 这是一段 magic code “忽略大小写的动态解析”: why ? 由于ios4 解析http header，所有key都给自动设置为首字母大写，如果用固定的key去解析，有可能解析出错。。。 
     * 为了提醒后人，留下这些 magic words~
     * 2012-10-26 by jojo
     */
	NSEnumerator *enumerator = [responseHeader keyEnumerator];
	id key;
	while (key = [enumerator nextObject]) {
		if ([key isKindOfClass:[NSString class]]) {

			if (NSNotFound != [key rangeOfString:@"termid" options:NSCaseInsensitiveSearch].location) {
				termIdStr = [responseHeader objectForKey:key];
			}
			else if (NSNotFound != [key rangeOfString:@"termName" options:NSCaseInsensitiveSearch].location) {
				termNameStr = [responseHeader objectForKey:key];
			}
			else if (NSNotFound != [key rangeOfString:@"termTime" options:NSCaseInsensitiveSearch].location) {
				termTimeStr = [responseHeader objectForKey:key];
                self.pubTime = termTimeStr;
                [logoView setDateString:self.pubTime];

			}
            else if (NSNotFound != [key rangeOfString:@"subId" options:NSCaseInsensitiveSearch].location) {
                subIdStr = [responseHeader objectForKey:key];
            }
			else if (NSNotFound != [key rangeOfString:@"pubId" options:NSCaseInsensitiveSearch].location) {
				pubIdStr = [responseHeader objectForKey:key];
			}
            else if (NSNotFound != [key rangeOfString:TERM_DATE options:NSCaseInsensitiveSearch].location) {
                logoDateStr = [responseHeader objectForKey:key];
            }
            else if (NSNotFound != [key rangeOfString:PUB_LOGO options:NSCaseInsensitiveSearch].location) {
                logoNormarlUrl = [responseHeader objectForKey:key];
            }
            else if (NSNotFound != [key rangeOfString:PUB_LOGO2 options:NSCaseInsensitiveSearch].location) {
                logoNightUrl = [responseHeader objectForKey:key];
            }
            else if (NSNotFound != [key rangeOfString:@"needLogin" options:NSCaseInsensitiveSearch].location) {
                needLogin = [responseHeader objectForKey:key];
            }
		}
	}
    /*
     *********************************************************************************************************************************************************/
    
    SNDebugLog(@"termid=%@, termName=%@, termTime=%@, pubId=%@, subId=%@", termIdStr, [termNameStr URLDecodedString], termTimeStr, pubIdStr, subIdStr);
    SCSubscribeObject *subObj = nil;
    
    // for logo view
    {
        if ([logoDateStr length] > 0) {
            [logoView setDateString:logoDateStr];
        }
        logoView.normalLogoUrl = logoNormarlUrl;
        logoView.nightLogoUrl  = logoNightUrl;

        self.paperItem.normalLogo = logoNormarlUrl;
        self.paperItem.nightLogo = logoNightUrl;
        
        if([[SNThemeManager sharedThemeManager].currentTheme isEqualToString:kThemeDefault]) {
            [logoView setLogoUrl:logoView.normalLogoUrl];
        } else if([[SNThemeManager sharedThemeManager].currentTheme isEqualToString:kThemeNight]) {
            [logoView setLogoUrl:logoView.nightLogoUrl];
        }
        
        if ([subIdStr length] == 0) {
            if ([self.subItem respondsToSelector:@selector(subId)]) {
                subIdStr = [self.subItem subId];
            }
        }
        else {
            self.subId = subIdStr;
        }
        
        if ([subIdStr length] > 0) {

            subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subIdStr];
            
            SNDebugLog(@"po == %@",subObj.subName);
            
            if (subObj) {
                logoView.pubName = subObj.subName;
                logoView.subId  = subObj.subId;
                _paperItem.subId = subObj.subId;
                _paperItem.pubId = subObj.pubIds;
                
                
                if (_paperItem.pubId.length == 0) {
                    _paperItem.pubId = pubIdStr;
                }
                
                if ([subObj.isSubscribed boolValue]) {
                    logoView.state = Subscribe;
                }
                else {
                    logoView.state = UnSubcribe;
                }
                
            } else {
                _paperItem.subId = subIdStr;
                _paperItem.pubId = pubIdStr;
                
                if (_isNotification) {
                    logoView.state = Subscribe;
                }
                else {
                    logoView.state = UnSubcribe;
                }
            }
            
            if ([self.subItem respondsToSelector:@selector(setSubId:)]) {
                [self.subItem setSubId:_paperItem.subId];
            }
        }
    }
	
    if (termNameStr && termNameStr.length) {
		//NSString *termNameStrUtf8 = [[NSString alloc] initWithData:[termNameStr dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
		SNDebugLog(@"termName:%@", termNameStr);
		termNameStr = [termNameStr URLDecodedString];
		_paperItem.termName = termNameStr;
		self.title = _paperItem.termName;
        if (!subObj) {
            logoView.pubName = termNameStr;
        }
	}
	else if ([_subItem pubName]){
		self.title = [_subItem pubName];
	}
	else {
		self.title = kBundleNameKey;
	}
	
	if (termTimeStr && termTimeStr.length) {
		termTimeStr = [termTimeStr URLDecodedString];
		_paperItem.termTime = termTimeStr;
	}
	
	if (pubIdStr && pubIdStr.length && [_linkType isEqualToString:@"HISTORYLIST"]) {
		pubIdStr = [pubIdStr URLDecodedString];
		_paperItem.pubId = pubIdStr;
	}
	
	if (termIdStr && termIdStr.length) {
		_paperItem.termId = termIdStr;
		//_paperItem.readFlag  = @"1";
        _paperItem.downloadFlag = nil;
        _paperItem.newspaperPath = nil;
        _paperItem.downloadTime = nil;
		
		NSString *zipStr = [NSString stringWithFormat:kUrlTermZip, termIdStr];
		NSString *termLinkStr = [NSString stringWithFormat:kUrlTermPaper, termIdStr];
		self.paperItem.termLink = termLinkStr;
		self.paperItem.termZip = zipStr;
		if (_paperItem.termName && _paperItem.termId) {
			[[SNDBManager currentDataBase] addSingleNewspaper:_paperItem updateIfExist:NO];
			SNDebugLog(@"subId: %@, termId:%d, latestTermId:%d", [_subItem subId], [[_subItem termId] intValue], [termIdStr intValue]);
            
            //----
            NSMutableDictionary *changeInfo = [NSMutableDictionary dictionary];
            //支持HomeV3接口
            if ([_linkType isEqualToString:@"SUBLIST"] && [_subItem isKindOfClass:[SubscribeHomeMySubscribePO class]]) {
                //如果是用户点击进入新闻页
                if (!_isNotification) {
                    //>>SubscribeHomeMySubscribePO *existItem = (SubscribeHomeMySubscribePO *)[[SNDBManager currentDataBase] getSubHomeMySubscribeBySubId:[_subItem subId]];
                    SCSubscribeObject *existItem = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:[_subItem subId]];
                    
                    if (existItem && [[existItem termId] intValue] != [termIdStr intValue] && !_isOpenFromPaper) {
                        [_subItem setTermId:termIdStr];
                        if ([_subItem termId].length) {
                            //有最新一期则把本地我的订阅和所有订阅的termId更新到最新；
                            [changeInfo setObject:[_subItem termId] forKey:kTermId];
                            //>>[cacheMgr updateSubHomeMySubscribePOBySubId:[_subItem subId] withValuePairs:changeInfo];
                            //>>[cacheMgr updateSubHomeAllSubscribePOBySubId:[_subItem subId] withValuePairs:changeInfo];
                            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:[_subItem subId] withValuePairs:changeInfo];
                        }
                    }
                }
                //如果是通过推送通知进入新闻页
                else {
                    //>>SubscribeHomeMySubscribePO *existItem = (SubscribeHomeMySubscribePO *)[[SNDBManager currentDataBase] getSubHomeMySubscribeByPubId:self.pubId];
                    SCSubscribeObject *existItem = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:[_subItem subId]];
                    
                    if (existItem && [[existItem termId] intValue] != [termIdStr intValue] && !_isOpenFromPaper) {
                        [_subItem setTermId:termIdStr];
                        if (termIdStr.length) {
                            [changeInfo setObject:termIdStr forKey:kTermId];
                            //>>[cacheMgr updateSubHomeMySubscribePOByPubId:self.pubId withValuePairs:changeInfo];
                            //>>[cacheMgr updateSubHomeAllSubscribePOByPubId:self.pubId withValuePairs:changeInfo];
                            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:[_subItem subId] withValuePairs:changeInfo];
                        }
                    }
                }
            }
            
		}

        [self enableOrDisableDownloadBtn];
	}
    
    if (subObj == nil) {
        subObj = [[SCSubscribeObject alloc] init];
        subObj.subId = _paperItem.subId;
        subObj.subName = self.title;
        subObj.pubIds = _paperItem.pubId;
        subObj.termId = _paperItem.termId;
        
        // 如果本地没有这个刊物 needLogin需要缓存到本地数据库
        if (needLogin && [needLogin isKindOfClass:[NSString class]] && needLogin.length > 0)
            subObj.needLogin = needLogin;
        
        [[SNDBManager currentDataBase] addASubscribeCenterSubscribeObject:subObj];
    }
}

- (void)enableOrDisableDownloadBtn {
    SNPaperItem *localNewspaper = (SNPaperItem *)[[SNDBManager currentDataBase] getNewspaperByTermId:_paperItem.termId];
    
    //刊物当前一期已经下载，则不让下载这一期内容。
    if (localNewspaper && [@"1" isEqualToString:localNewspaper.downloadFlag]) {
        _downloadBtn.enabled = NO;
    }
    //刊物当前一期没有下载过
    else {
        //新版下载
        #if kNeedDownloadRollingNews
        //正在下载刊物或新闻
        if (![SNDownloadScheduler sharedInstance].isAllDownloadFinished) {
            
            //刊物当前一期正在下载则不让下载
            SCSubscribeObject *_scSubscribeObj = [[SCSubscribeObject alloc] init];
            _scSubscribeObj.subId = localNewspaper.subId;
            _scSubscribeObj.termId = localNewspaper.termId;
            if ([[SNDownloadScheduler sharedInstance] isDownloadingItem:_scSubscribeObj]) {
                _downloadBtn.enabled = NO;
            }
            //当前要下载刊物这一期是失败项或这一期就不在下载列队里
            else if ([[SNDownloadScheduler sharedInstance] isDetachedItem:_scSubscribeObj]
                     || [[SNDownloadScheduler sharedInstance] isFailedItem:_scSubscribeObj]) {
                _downloadBtn.enabled = YES;
            }
             //(_scSubscribeObj);
        }
        //刊物或新闻下载队列完全为空
        else {
            _downloadBtn.enabled = YES;
        }
        
        //旧版下载
        #else
        //下载器正在运行
        if (![SNDownloadManager sharedInstance].isAllFinished) {
            //刊物当前一期正在下载则不让下载
            if ([[SNDownloadManager sharedInstance] isInDownloadingItems:_paperItem.termId]) {
                _downloadBtn.enabled = NO;
            }
            
            /**
             * 刊物当前一期在下载显示列表中显示但是不在下载列表中说明下载已经失败，可下载，即让用户重试下载。
             * 致于又重试下载同一期刊物的问题会在下载器的addSpecifiedDownloadingItemImmediatlyWith:方法中兼容；
             */
            else if ([[SNDownloadManager sharedInstance] isInDownloadingItemsForRender:_paperItem.termId])  {
                _downloadBtn.enabled = YES;
            }
            //刊物当前一期即不在下载显示列表也不在下载列表中，说明这是一期从未下载过的刊物，可下载。
            else {
                _downloadBtn.enabled = YES;
            }
        }
        /**
         * 下载器没有运行：说明 1）下载器的下载列表肯定是空的；2）下载显法列表中有可能有刊物当前一期即之前这一期下载失败过。
         * 第一种，说明从来没有下载过更没有下载失败过；第二种，说明下载过，但之前失败过。
         * 那么么这两种情况都应该让用户下载，对于第一种情况是添加一个新下载，对于第二种情况是一个下载重试。
         * 致于下载器对于这两种情况的处理已在addSpecifiedDownloadingItemImmediatlyWith:方法中兼容；
         */
        else {
            _downloadBtn.enabled = YES;
        }
        #endif
    }
}

- (bool)isNewsAvailableOnDisk:(NSString*)termId newsId:(NSString*)newsId userInfo:(NSMutableDictionary *)userInfo{
	if ([termId length] == 0 || [newsId length] == 0) {
		return NO;
	}

    NSString *realpath = nil;
    
    if([_linkType isEqualToString:@"LOCAL"])
    {
        if([_subItem isKindOfClass:[NewspaperItem class]])
        {
            realpath = [_subItem realNewspaperPath];
        }
    }

    if (realpath == nil) {
        NewspaperItem *newspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:_paperItem.termId];
        //NewspaperItem *newspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:termId];
        if ([newspaper.newspaperPath length] == 0) {
            return NO;
        }
	
        realpath = [newspaper realNewspaperPath];
    }
    
	NSFileManager *fm	= [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:realpath]) {
		return NO;
	}
	
	NSRange rangeLastPath	= [realpath rangeOfString:@"/" options: NSBackwardsSearch];
	if (rangeLastPath.location == NSNotFound) {
		return NO;
	}

	NSString *filePrefix = [realpath substringToIndex:rangeLastPath.location];
    if (filePrefix && [filePrefix length] > 0) {
        [userInfo setObject:filePrefix forKey:kNewsPaperDir];
    }
	NSString *newsFileName	= [NSString stringWithFormat:@"%@_%@.xml",termId,newsId];
	NSString *newsFilePath	= [filePrefix stringByAppendingPathComponent:newsFileName];
	
	return [fm fileExistsAtPath:newsFilePath];
}

//- (void)showGuideMask
//{
//    NSString *firstOnRun = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileMaskGuidePaperOnFirstRun];
//    
//    if ([@"1" isEqualToString:firstOnRun]) {
//        _guide = [[SNGuideMaskController alloc] initWithIndex:2];
//        [[SNUtility getApplicationDelegate].navigator.window addSubview:_guide.view];
//        [_guide show:YES animated:YES];
//    }
//}

//添加订阅：同步订阅数据到本地数据库和远程服务器
- (void)addASubscribe {
    
    SNDebugLog(@"paperItem = %@",_paperItem);
    
    SNDebugLog(@"paperItem.subid = %@",_paperItem.subId);
    
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
    
    SCSubscribeObject *object = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_paperItem.subId];
    
    if ([object.isSubscribed isEqualToString:@"1"]) {
        
        if ([object.moreInfo length] == 0) {
            object.moreInfo = @"确认退订";
        }
        
        NSString *succMsg = [object succUnsubMsg];
        NSString *failMsg = [object failUnsubMsg];
        
        SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeRemoveMySubToServer request:nil refId:object.subId];
        [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
        [[SNSubscribeCenterService defaultService] removeMySubToServerBySubObject:object];
        logoView.state = UnSubcribe;
        
    }
    else {
        if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:object]) {
            [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_PAPER referId:_paperItem.subId referAct:SNReferActSubscribe];
            [SNGuideRegisterManager showGuideWithSubId:_paperItem.subId];
            return;
        }
        
        if (!object) {
            object = [[SCSubscribeObject alloc] init];
            object.subId = _paperItem.subId;
            object.moreInfo = @"确认关注";
        }
        
        if ([object.moreInfo length] == 0) {
            object.moreInfo = @"确认关注";
        }
        
        if (_refer > 0) {
            object.from = _refer;
        } else {
            object.from = REFER_PAPER_SUBBTN;
        }
        
        NSString *succMsg = [object succSubMsg];
        NSString *failMsg = [object failSubMsg];
        
        logoView.state = Subscribe;
        
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
        SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:object.subId];
        [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
        [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:object];
    }
}

- (void)actionmenuDidSelectLikeBtn {
    if ([self checkIfHadBeenMyFavourite]) {
        [self removeMyFavourite];
    } else {
        [self addMyFavourite];
    }
}

- (void)addMyFavourite
{
    SNNewspaperFavourite *newspaperFavourite = [[SNNewspaperFavourite alloc] init];
    newspaperFavourite.title = (_paperItem.termName && ![@"" isEqualToString:_paperItem.termName]) ?
    _paperItem.termName :((_paperItem.pushName && ![@"" isEqualToString:_paperItem.pushName]) ? 
                          _paperItem.pushName : NSLocalizedString(@"default_my_favourite_publication_text", nil));
    
    newspaperFavourite.type = MYFAVOURITE_REFER_PUB_HOME;
    newspaperFavourite.contentLevelFirstID = _paperItem.pubId;
    newspaperFavourite.contentLevelSecondID = (_paperItem.subId && [_paperItem.subId length]) ? [NSString stringWithFormat:@"%@#%@",_paperItem.termId,_paperItem.subId] : _paperItem.termId;
    newspaperFavourite.publicationDate = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970]*1000];
    
    [[SNMyFavouriteManager shareInstance] addToMyFavouriteList:newspaperFavourite];
}

- (void)removeMyFavourite
{
    SNNewspaperFavourite *newspaperFavourite = [[SNNewspaperFavourite alloc] init];
    newspaperFavourite.type = MYFAVOURITE_REFER_PUB_HOME;
    newspaperFavourite.contentLevelFirstID = _paperItem.pubId;
    newspaperFavourite.contentLevelSecondID = (_paperItem.subId && [_paperItem.subId length]) ? [NSString stringWithFormat:@"%@#%@",_paperItem.termId,_paperItem.subId] : _paperItem.termId;
    
    [[SNMyFavouriteManager shareInstance] deleteFromMyFavouriteList:newspaperFavourite];

}

- (void)saveOneVisit {
    return;
    NSMutableDictionary *oneVisitInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [oneVisitInfo setObject:_linkType forKey:@"linkType"];
    if (_subItem) {
        [oneVisitInfo setObject:_subItem forKey:@"subItem"];
    }
    if (!_visitStack) {
        self.visitStack = [[SNStack alloc] init];
    }
    [_visitStack push:oneVisitInfo];
    SNDebugLog(@"after save num of stack = %d", _visitStack.count);
}

- (BOOL)checkIfHadBeenMyFavourite
{
    SNNewspaperFavourite *newspaperFavourite = [[SNNewspaperFavourite alloc] init];
    newspaperFavourite.type = MYFAVOURITE_REFER_PUB_HOME;
    newspaperFavourite.contentLevelFirstID = _paperItem.pubId;
    newspaperFavourite.contentLevelSecondID = (_paperItem.subId && [_paperItem.subId length]) ? [NSString stringWithFormat:@"%@#%@",_paperItem.termId,_paperItem.subId] : _paperItem.termId;
    
    return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:newspaperFavourite];
}
#pragma mark -
#pragma mark ShareInfo
- (void)shareAction {
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [self createActionMenuContentContext];
    [mDic setObject:@"term" forKey:SNNewsShare_LOG_type];
    
    SNTimelineOriginContentObject *oobj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePaper contentId:[self.subId length] > 0 ? self.subId : self.termId];
    NSString* sourceType = @"";
    if (oobj) {
        sourceType = [NSString stringWithFormat:@"%d",oobj.sourceType];
    } else {
        sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeSub];
    }
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    [self callShare:mDic];
    
    return;
#endif

    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    self.actionMenuController.contextDic = [self createActionMenuContentContext];
    self.actionMenuController.timelineContentId = [self.subId length] > 0 ? self.subId : self.termId;
    self.actionMenuController.timelineContentType = SNTimelineContentTypePaper;
    self.actionMenuController.shareLogType = @"term";
    self.actionMenuController.shareSubType = ShareSubTypeQuoteText;
    self.actionMenuController.delegate = self;
    self.actionMenuController.isLiked = [self checkIfHadBeenMyFavourite];
    self.actionMenuController.disableCopyLinkBtn = YES;
    self.actionMenuController.disableLikeBtn = ![self isKindOfClass:[SNNewsPaperWebController class]]; // 普通web页不能收藏 只有报纸可以 @jojo
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePaper
                                                                                         contentId:[self.subId length] > 0 ? self.subId : self.termId];
    if (obj) {
        self.actionMenuController.sourceType = obj.sourceType;
    } else {
        self.actionMenuController.sourceType = SNShareSourceTypeSub;
    }
    [self.actionMenuController showActionMenu];
}

- (void)callShare:(NSDictionary*)paramsDic{
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

#pragma mark -
#pragma mark SNActionMenuControllerDelegate

- (SharedInfo *)getSharedInfo {
	SharedInfo *sharedInfo = [[SharedInfo alloc] init];
    
    // 解析并缓存 shareRead 字段 by jojo
    NSString *shareContentStr = nil;
    TBXML *xml = [TBXML tbxmlWithXMLData:_htmlData];
    TBXMLElement *rootElm = xml.rootXMLElement;
    TBXMLElement *headElm = [TBXML childElementNamed:@"head" parentElement:rootElm];
    TBXMLElement *metaElm = [TBXML childElementNamed:@"meta" parentElement:headElm];
        
    if (metaElm) {
        do {
            NSString *shareReadId = [TBXML valueOfAttributeNamed:@"name" forElement:metaElm];
            if ([shareReadId isEqualToString:@"sohunews-shareSns"]) {
                shareContentStr = [TBXML valueOfAttributeNamed:@"content" forElement:metaElm];
                break;
            }
        } while ((metaElm = [TBXML nextSiblingNamed:@"meta" searchFromElement:metaElm]) != nil);
    }
    
    shareContentStr = [shareContentStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SNDebugLog(@"shareContentStr %@", shareContentStr);
    
    if (!shareContentStr)
        return [super getSharedInfo];
    
    sharedInfo.sharedTitle = shareContentStr;
    return sharedInfo;
}

- (void)commentWillPost:(NSMutableDictionary *)commentData sendType:(SNEditorType)sendType{
    NSString* sendContent = [commentData objectForKey:kCommentDataKeyText];
    
    //分享到阅读圈
    if (sendType == SNEditorTypeShare) {
        if (_shareObj) {
            [[SNTimelinePostService sharedService]timelineShareWithContent:sendContent
                                                             originContent:_shareObj
                                                               fromShareId:nil];
        }
    }
}

- (NSMutableDictionary *)createActionMenuContentContext {
    
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
//    NSString *body = [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//    if (body) [dicShareInfo setObject:body forKey:kShareInfoKeyHtmlContent];
    
    SharedInfo *shareInfo	= [self getSharedInfo];
    NSString *content = shareInfo.sharedTitle;
    if (content) [dicShareInfo setObject:content forKey:kShareInfoKeyContent];

    if (self.title && self.title.length > 0) {
        [dicShareInfo setObject:self.title forKey:kShareInfoKeyTitle];
    }
    
    _shareObj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:SNTimelineContentTypePaper
                                                               contentId:[self.subId length] > 0 ? self.subId : self.termId];
    
    if (self.subId) {
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];

        if (subObj.subName) [dicShareInfo setObject:subObj.subName forKey:kShareInfoKeyTitle];
        if (subObj.subIcon) [dicShareInfo setObject:subObj.subIcon forKey:kShareInfoKeyImageUrl];
        
    }
    
    NSString *screenShotPath = [UIImage screenshotImagePathFromView:self.view];
    if ([screenShotPath length] > 0) {
        [dicShareInfo setObject:screenShotPath forKey:kShareInfoKeyScreenImagePath];
    }
  
    //log
    if ([self.termId length] > 0) {
        [dicShareInfo setObject:self.termId forKey:kShareInfoKeyNewsId];
    }
    if ([content length] > 0) {
        [dicShareInfo setObject:content forKey:kShareInfoKeyShareContent];
    }
    
    return dicShareInfo;
}

#pragma mark -
#pragma mark  SNDatabaseRequestDelegate
- (void)requestDidStartLoad:(NSString*)url {
	self.isDownloading = YES;
}

- (void)requestUpdateProgress:(NSString*)url receivedLen:(NSInteger)receivedLen totalLen:(NSInteger)totalLen {
}

- (void)requestDidFinishLoad:(NSString*)url {
    if (_isVisible) {
        [SNNotificationCenter showMessage:NSLocalizedString(@"download paper sucess", @"")];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"download paper sucess", @"") toUrl:nil mode:SNCenterToastModeSuccess];
    }
	_isDownloading = NO;
	_downloadBtn.enabled = NO;
	_isOffLineMode = YES;
	
    if ([_paperItem.termId length] != 0) {
        //查询本地缓存，是否已经下载该报纸的zip包
        NewspaperItem *localNewspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:_paperItem.termId];
        if (localNewspaper != nil 
            && [localNewspaper.downloadFlag isEqualToString:@"1"] 
            && [localNewspaper.newspaperPath length] != 0) {
            //本地数据库查询到zip包已经下载，判断zip包是否有效
            NSString *realpath = [localNewspaper realNewspaperPath];
            
            NSFileManager *fm	 = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:realpath]) {
                //zip包有效，则从本地加载，取消此次网络请求
                _isOffLineMode = YES;
                _downloadBtn.enabled = NO;
                NSString *currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
                
                NSError *error = nil;
                NSString *htmContent = [NSString stringWithContentsOfFile:realpath encoding:NSUTF8StringEncoding error:&error];
                [self checkPaperTemplateId:htmContent];
                
                if ([currentTheme isEqualToString:kThemeNight]) {
                    htmContent = [self switchMode:htmContent];
                    [_webView loadHTMLString:htmContent baseURL:[NSURL fileURLWithPath:realpath]];
                } else {
                    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:realpath]]];
                }
            }
        }
    }

}

- (void)request:(NSString*)url didFailLoadWithError:(NSError*)error {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"download paper fail", @"") toUrl:nil mode:SNCenterToastModeWarning];
	self.isDownloading = NO;
}

- (void)requestDidCancelLoad:(NSString*)url {
	self.isDownloading = NO;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    initialScrollPosition = [[_webView stringByEvaluatingJavaScriptFromString:@"scrollY"] intValue];
    
	[super viewDidUnload];
    
    [[SNSubscribeCenterService defaultService] removeListener:self];
    
     //(logoView);
     //(_backBtn);
     //(_share);
	 //(_downloadBtn);
	 //(_history);
    
     //(adView);
     //(_myFavouriteBtn);
     //(_pubInfoBtn);
     //(_pubIDsForWangQiAction);
    
    _actionMenuController.delegate = nil;
     //(_actionMenuController);
    
    // 浏览历史要把当前浏览的记录清楚掉 loadview时会重新记录 @jojo
//    [_visitStack pop];
}

#pragma mark -
#pragma mark SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        //如果用户点“继续下载”
        [self doStartDownload];
    }
}


#pragma mark - UIAlerViewDelegate methods implementation

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (_subscribeAlertView == alertView) {
        SNSubscribeAlertView *_subAlertView = (SNSubscribeAlertView *)alertView;
        SCSubscribeObject *object = (SCSubscribeObject *)_subAlertView.snAlertUserData;
        
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
        
        if (buttonIndex == 1) {
            if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:object]) {
                [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_PAPER referId:object.subId referAct:SNReferActSubscribe];
                [SNGuideRegisterManager showGuideWithSubId:object.subId];
                return;
            }
            
            [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:object.subId];
            [opt addBackgroundListenerWithSuccMsg:[object succSubMsg] failMsg:[object failSubMsg]];
            object.from = REFER_PAPER_SUBBTN;
            [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:object];
        } else if (buttonIndex == 0) {
            
        }
        
        if (_subAlertView.isChecked) {
            // save backPromotion
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"1", TB_SUB_CENTER_ALL_SUB_BACK_PROMOTION, nil];
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObjectBySubId:object.subId withValuePairs:dic];
        }

        _subscribeAlertView = nil;
        
        [self.flipboardNavigationController popViewControllerAnimated:YES];
        return;
    }
    else if (_subAddAlertView == alertView) {
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
        
        if (buttonIndex == 1) {
            SCSubscribeObject *object = _subAddAlertView.snAlertUserData;
            
            if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:object]) {
                [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_PAPER referId:object.subId referAct:SNReferActSubscribe];
                [SNGuideRegisterManager showGuideWithSubId:object.subId];
                return;
            }
            
            NSString *succMsg = [object succSubMsg];
            NSString *failMsg = [object failSubMsg];
            
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubsAndSynchPush request:nil refId:object.subId];
            [opt addBackgroundListenerWithSuccMsg:succMsg failMsg:failMsg];
            
            object.from = REFER_PAPER_SUBBTN;
            [[SNSubscribeCenterService defaultService] addMySubsToServer:[NSArray arrayWithObject:object] withPushOpen:_subAddAlertView.isChecked];
            
            logoView.state = Subscribe;
        }
        
        _subAddAlertView = nil;
        return;
    }
    else {
        if (buttonIndex == 1) {
            //如果用户点“继续下载”
            [self doStartDownload];
        }
    }
}

#pragma mark -
#pragma mark Shake gesture to print html to console for test

#ifdef DEBUG_MODE  

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

#endif

#pragma mark - SNSubscribeCenterServiceDelegate

- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
        logoView.state = UnSubcribe;
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        [[SNSubscribeCenterService defaultService] removeListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
        logoView.state = UnSubcribe;
    }
}

- (void)pushNotificationWillCome {
    if (_subscribeAlertView) {
        [_subscribeAlertView dismissWithClickedButtonIndex:0 animated:NO];
        _subscribeAlertView = nil;
    }
    if (_subAddAlertView) {
        [_subAddAlertView dismissWithClickedButtonIndex:0 animated:NO];
        _subAddAlertView = nil;
    }
}

- (void)handleMySubDidChangedNotify:(id)sender {
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:self.subId];
    if (!subObj || ![subObj.isSubscribed boolValue]) {
        logoView.state = UnSubcribe;
    }
    else {
        logoView.state = Subscribe;
    }
}

@end
