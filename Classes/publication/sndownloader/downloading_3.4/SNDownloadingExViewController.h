//
//  SNDownloadingExViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 13-4-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DACircularProgressView.h"

@class DACircularProgressView;
@class SNDownloadingVController;
@interface SNDownloadingExViewController : SNBaseViewController<DACircularProgressViewDelegate>
{
    UILabel* _tipLabel;
    UILabel* _percent;
    UILabel* _percentMark;
    UIView* _guideView;
    UIView* _emptyView;
    UIButton* _tipButton;
    UIButton* _cancelButton;
    UIButton* _setttingButton;
    UIButton* _downloadedButton;
    NSInteger _currentPercent;
    
    UIImageView* _bgView;
    DACircularProgressView* _progressBar;
    SNDownloadingVController* _downloadingViewController;
    
    //如果是从外面进入，或者从设置返回，那么在没有正在离线的情况下，开始下载
    BOOL _referFromDownloaded;
}

@property(nonatomic, strong)UILabel* tipLabel;
@property(nonatomic, strong)UILabel* percent;
@property(nonatomic, strong)UILabel* percentMark;
@property(nonatomic)UIView* guideView;
@property(nonatomic)UIView* emptyView;
@property(nonatomic, strong)UIButton* tipButton;
@property(nonatomic, strong)UIButton* cancelButton;
@property(nonatomic, strong)UIButton* setttingButton;
@property(nonatomic, strong)UIButton* downloadedButton;
@property(nonatomic, assign)NSInteger currentPercent;

@property(nonatomic, strong)UIImageView* bgView;
@property(nonatomic, strong)DACircularProgressView* progressBar;
@property(nonatomic, strong)SNDownloadingVController* downloadingViewController;

+(BOOL)isPresentingNow;
//+(SNDownloadingExViewController*)shareInstance;
//-(void)presentModalView:(UIViewController*)aViewContronller;
-(void)updateProcessLine:(CGFloat)aPercent;
-(void)didFinishedDownloadAllInMainThread;
@end
