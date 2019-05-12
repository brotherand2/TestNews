//
//  FKDownloadViewController.h
//  FK
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#if kNeedDownloadRollingNews
#import "SNDownloadingVController.h"
#else
#import "SNDownloadingViewController.h"
#endif

#import "SNEditDownloadedBottomMenu.h"


@class SNDownloadedViewController;

/*
typedef enum {
    FKDownloadListViewDownloadingMode,
    FKDownloadListViewDownloadedMode
} FKDownloadListViewMode;*/

@interface SNDownloadViewController : SNBaseViewController<UIScrollViewDelegate> {
    //FKDownloadListViewMode _currentViewMode;
    
//    UIScrollView *_scrollViewContainer;
    
//    #if kNeedDownloadRollingNews
//    SNDownloadingVController *_downloadingViewController;
//    #else
//    SNDownloadingViewController *_downloadingViewController;
//    #endif
    
    SNDownloadedViewController *_downloadedViewController;
    
    UIButton *_rightEditBtn;
    UIButton *_rightDoneBtn;
    //UIButton *_rightCancelAllDownloadingBtn;
    //UIButton *_rightDownloadSettingBtn;
    
    SNEditDownloadedBottomMenu *_bottomMenu;
    NSString* _referFrom;
}

#pragma mark - Public methods implementation

//- (void)setDownloadListViewMode:(FKDownloadListViewMode)downloadListViewMode;

@end
