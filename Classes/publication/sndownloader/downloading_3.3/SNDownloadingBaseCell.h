//
//  SNDownloadingBaseCell.h
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDownloadingVController.h"
#import "SNDBManager.h"
#import "SNDownloadingArrowIndicator.h"
#import "SNDownloadScheduler.h"
#import "SNTableViewCell.h"

@protocol SNDownloadingBaseCellDelegate;

@interface SNDownloadingBaseCell : SNTableViewCell {
    id __weak _delegate;
    id _data;
    UILabel *_titleLabel;
    UIImageView *_finishMark;
    UIButton *_cancelBtn;
    SNDownloadingArrowIndicator *_downloadingIndicator;
    UIButton *_retryBtn;
}
@property(nonatomic, weak)id delegate;
@property(nonatomic, strong)id data;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UIImageView *finishMark;
@property(nonatomic, strong)UIButton *cancelBtn;
@property(nonatomic, strong)SNDownloadingArrowIndicator *downloadingIndicator;
@property(nonatomic, assign)SNDownloadingCellOrder order;
@property(nonatomic, strong)UIButton *retryBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegateParam;
- (void)cancelDownload;
- (void)retryDownload;
@end

@protocol SNDownloadingBaseCellDelegate
@end
