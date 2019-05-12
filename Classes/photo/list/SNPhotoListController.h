//
//  SNPhotoTextControllerViewController.h
//  sohunews
//
//  Created by jialei on 13-8-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseViewController.h"
#import "SNPhotoListModel.h"
#import "SNCommentListModel.h"
#import "SNPostFollow.h"
#import "SNContentMoreViewController.h"
#import "SNPostCommentController.h"
#import "SNPhotoGallerySlideshowController.h"
#import "SNCommonNewsController.h"
#import "SNArticleRecomService.h"
#import "FGalleryPhotoView.h"

@interface SNPhotoListController : SNBaseViewController<SNPostCommentControllerDelegate,SNPhotoListModelDelegate,PostFollowDelegate,SNContentMoreViewDelegate,SNArticleRecomServiceDelegate,SNPhotoGallerySlideshowControllerDelegate>

@property (nonatomic, retain) SNRollingNewsModel *newsModel;
@property (nonatomic, retain) NSMutableArray *rollingNewsList;
@property (nonatomic, assign) SNCommonNewsController* commonNewsController;
@property (nonatomic, retain) NSDictionary *queryAll;
@property (nonatomic, assign) BOOL isSlideShowMode;
@property(nonatomic,retain) NSString *referFrom;

- (void)setCurrentTableShouldScrollsToTop;
- (UIViewController *)backToViewController;
- (void)updateFontTheme;

@end
