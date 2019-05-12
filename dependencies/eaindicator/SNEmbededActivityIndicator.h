//
//  SNEmbededActivityIndicator.h
//  sohunewsipad
//
//  Created by handy wang on 12/4/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

typedef enum {
    SNEmbededActivityIndicatorStatusInit = 0,
    SNEmbededActivityIndicatorStatusStartLoading = 1,
    SNEmbededActivityIndicatorStatusStopLoading = 2,
    SNEmbededActivityIndicatorStatusUnstableNetwork = 3,
    SNEmbededActivityIndicatorStatusLocalChannelError = 4
} SNEmbededActivityIndicatorStatus;


@protocol SNEmbededActivityIndicatorDelegate

- (void)didTapRetry;

@end


@interface SNEmbededActivityIndicator : UIControl {
    id __weak _delegate;
    
    UIImageView *_quarterCircleView;
    UIImageView *_circleBgView;
    UIImageView *_circleBgShadowView;
    UIButton *_tapActionBtn;
    UIButton *_networkErrorBtn;
    UIButton *_localChannelBtn;
    UIImageView *_logoImageView;
    
    UILabel *_zhMsgLabel;
    UILabel *_enMsgLabel;
    
    NSString *_zhReadyToRefreshMsg;
    NSString *_enReadyToRefreshMsg;
    
    NSString *_zhLoadingMsg;
    NSString *_enLoadingMsg;
    
    NSString *_zhNetworkErrorMsg;
    NSString *_enNetworkErrorMsg;
    
    SNEmbededActivityIndicatorStatus _status;
    BOOL    _animating;
    BOOL    _hidesWhenStopped;    
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, strong, readonly)UIImageView *quarterCircleView;
@property(nonatomic, strong, readonly)UIImageView *circleBgView;
@property(nonatomic, strong, readonly)UIImageView *circleBgShadowView;
@property(nonatomic, strong, readonly)UIButton *tapActionBtn;
@property(nonatomic, strong, readonly)UIButton *networkErrorBtn;
@property(nonatomic, strong, readonly)UIImageView *logoImageView;

@property(nonatomic, strong, readonly)UILabel *zhMsgLabel;
@property(nonatomic, strong, readonly)UILabel *enMsgLabel;

@property(nonatomic, strong)NSString *zhReadyToRefreshMsg;
@property(nonatomic, strong)NSString *enReadyToRefreshMsg;

@property(nonatomic, strong)NSString *zhLoadingMsg;
@property(nonatomic, strong)NSString *enLoadingMsg;

@property(nonatomic, strong)NSString *zhNetworkErrorMsg;
@property(nonatomic, strong)NSString *enNetworkErrorMsg;

@property(nonatomic, assign)SNEmbededActivityIndicatorStatus status;
@property(nonatomic, readonly)BOOL animating;
@property(nonatomic, assign)BOOL hidesWhenStopped;

@property(nonatomic, assign, readonly)BOOL isNetworkAvailable;

- (id)initWithDelegate:(id)delegateParam;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegateParam;

- (void)startAnimating;

- (void)stopAnimating;

- (void)setStatus:(SNEmbededActivityIndicatorStatus)status;

- (BOOL)isAnimating;

- (void)updateTheme;

@end

@interface SNEmbededActivityIndicatorEx : SNEmbededActivityIndicator
{
}
@end
