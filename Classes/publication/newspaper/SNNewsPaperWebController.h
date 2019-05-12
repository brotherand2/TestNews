//
//  SNNewsPaperWebController.h
//  Three20Learning
//
//  Created by zhukx on 5/15/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SmsSupport.h"
#import "CacheObjects.h"
#import "SNWebController.h"
#import "SNGuideMaskController.h"
#import "SNPaperLogoView.h"
#import "SNStack.h"
#import "SNDatabase.h"

@class SNPaperItem;
@class SNSubItem;

@interface SNNewsPaperWebController : SNWebController <UIGestureRecognizerDelegate,SmsDelegate,SNDatabaseRequestDelegate,SNActionSheetDelegate> {
@protected
	BOOL _isOffLineMode;
	BOOL _isFirstLoad;
	SNPaperItem *_paperItem;
	id _subItem;
    UIButton *_backBtn;
	UIButton *_history;
	UIButton *_downloadBtn;
	UIButton *_downloadBtnCancel;
    
    UIButton *_pubInfoBtn;
    
	UINavigationController *_backController;
	BOOL _isDownloading;
	BOOL _isNavigatedFromWangqi;
	BOOL _isNotification;
    BOOL _isFromMySubList;
    BOOL _isFromSubDetail;
    BOOL _isVisible;
	NSString *_linkType;
	
	int initialScrollPosition;
	NSMutableURLRequest *_webRequest;
	NSURLConnection *_webConnection;
	NSMutableData *_htmlData;
    NSURL *_redirectToURL;
    
//    SNGuideMaskController *_guide;
//    SNSubscribeHomeTableViewCell *_backTableViewCell;
    
    BOOL isAnimating;
    BOOL  adViewShown;
    BOOL  adViewClosed;
    
    int   adRefreshCount;
    
    UIButton *_myFavouriteBtn;
    
    SEL _myFavouriteSelector;
    
    BOOL _shouldUseSlidershow;
    
    SNPaperLogoView *logoView;
    
    NSString *_pubIDsForWangQiAction;
    
    SNStack *_visitStack;
    
    BOOL _refreshFromDrag;
    
    //---
    BOOL _didTriggerBack;
    BOOL isContinuous;  //连续阅读
    
    NSString *_protoParamsFeedbackStr;
}

- (void)enableOrDisableDownloadBtn;


#pragma mark - Public methods called by SNDownloadManager

- (void)didFailStartDownload;

- (void)didFailSingleDownload:(SubscribeHomeMySubscribePO *)mySubPO;

- (void)didSucceedSingleDownload:(SubscribeHomeMySubscribePO *)mySubPO;

@property (nonatomic, strong) SNPaperItem *paperItem;
@property (nonatomic, strong) id subItem;
@property (nonatomic, assign) BOOL isContinuous;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSURLConnection *webConnection;
@property (nonatomic, strong) NSMutableData *htmlData;
@property (nonatomic, strong) NSMutableURLRequest *webRequest;
@property (nonatomic, strong, readwrite) NSString *pubId;
@property (nonatomic, strong, readwrite) NSString *pubName;
@property (nonatomic, strong, readwrite) NSString *pubTime;
@property (nonatomic, strong) SNStack *visitStack;
@property (nonatomic, strong) NSString *linkType;
@property (nonatomic, strong) NSURL *redirectToURL;
@property (nonatomic, strong) NSMutableDictionary *queryDic;

@end
