//
//  SNDownloadedViewController.h
//  sohunews
//
//  Created by handy wang on 6/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDownloaderAlert.h"
#import "SNDownloadViewController.h"
#import "SNLoadingOverlay.h"


@protocol SNDownloadedViewControllerDelegate <NSObject>

//- (void)setReferOfDownloader:(FKDownloadListViewMode)mode;
@optional
- (void)disableRightBtn;
- (void)enableRightBtn;
- (void)doneAction;
@end


@interface SNDownloadedViewController : UITableViewController <SNActionSheetDelegate>{
    
    NSString* __weak _referFrom;
    
    SNDownloaderAlert *_confirmAlertView;
    
    NSMutableArray *_localDownloadedData;
    BOOL _isEditMode;
    
    SNLoadingOverlay *_loadingOverlay;
    
    NSInteger   _selectNum;
    
    SNEditDownloadedBottomMenu *__weak _bottomMenu;
}

@property(nonatomic, assign)BOOL isEditMode;
@property(nonatomic, weak) SNEditDownloadedBottomMenu *bottomMenu;
@property(nonatomic, weak) NSString *referFrom;
@property(nonatomic, weak) id <SNDownloadedViewControllerDelegate>delegate;

- (id)initWithIDelegate:(id)delegateParam;

- (void)loadLocalDownloadedDataFromDB;

- (void)reloadDownloadedTableView;

- (void)selectAll;

- (void)deselectAll;

- (void)deleteSelected;

- (void)enableOrDisableRightBtn;

@end
