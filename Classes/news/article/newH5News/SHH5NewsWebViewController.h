//
//  SHH5NewsWebViewController.h
//  sohunews
//
//  Created by 赵青 on 16/1/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNCommentEditorViewController.h"
#import "SNRollingNewsModel.h"
#import "SNArticleRecomService.h"
#import "SNPopoverView.h"
#import "SNPostFollow.h"

@class SNCommonNewsController;

@interface SHH5NewsWebViewController : SNBaseViewController<UIWebViewDelegate, UIScrollViewDelegate, SNArticleRecomServiceDelegate>

@property (nonatomic, assign) BOOL isFavour;
@property (nonatomic, weak) SNCommonNewsController *commonNewsController;
@property (nonatomic, strong) NSDictionary *queryAll;
@property(nonatomic, strong) SNPostFollow* postFollow;
@property (nonatomic, strong) SNRollingNewsModel *newsModel;
@property (nonatomic, strong) NSMutableArray *rollingNewsList;
@property (nonatomic, strong) NSString *lastNewsId;
@property (nonatomic, strong) NSString *newsPaperDir;
@property (nonatomic) BOOL slideShowMode;
@property (nonatomic) BOOL isSlideShowMode;
@property (nonatomic, assign) BOOL isNavView; //记录操作栏是否滑动隐藏了
@property (nonatomic, strong) UIView *nightModeView;

- (void)addOfficialAccountViewWithInfo:(NSDictionary *)subInfo;
- (void)onClickReport;
- (void)setCommentNum:(NSString *)count;
- (void)replyComment:(NSDictionary *)comment;
- (void)emptyCommentListClicked;
- (void)clickImage:(NSString *)imageUrl title:(NSString *)title rect:(CGRect)rect;
- (void)copyComment:(NSString *)content;
- (void)longTouchImage:(NSString*)url;
- (void)shareContent:(NSString *)content;
- (void)enterUserCenter:(id)jsonData;
- (void)showImageWithUrl:(NSString *)urlPath;
- (void)onClickVideo:(CGRect)rect;
- (void)playVideo:(CGRect)rect tvInfo:(NSDictionary *)tvInfo;
- (void)soundPlay:(NSString *)soundUrl commentId:(NSString *)commentId;
- (void)shareFastTo:(SNActionMenuOption)menuOption;
- (void)stopProgress:(NSInteger)isLonging;
- (void)dealSlideAds:(NSDictionary *)adInfo;
- (void)setCollectionNum:(int)count;
- (void)setCollectionCount:(int)count;
- (void)setWebviewNightModeView:(BOOL)isNight;
- (void)backViewController;
//- (BOOL)needsHideStatusBar;
- (void)hideOrShowCollection:(NSNumber *)showType;
- (void)scrollViewDidEndScrolling;
- (void)setH5Type:(NSString *)h5Type h5Link:(NSString *)h5WebLink;
- (void)addSubscribeWithInfo:(NSDictionary *)subInfo;

- (NSMutableDictionary *)mainBodyShareData;

@end
