//
//  SNLiveBannerViewWithMatchInfo.h
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerView.h"

@interface SNLiveBannerViewWithMatchInfo : SNLiveBannerView {
    UILabel *_onlineCountLabel;
    UILabel *_liveStatusLabel;
    UILabel *_dotsLabel;
    UILabel *_pubTypeLabel;
    //UIImageView *_worldCupIcon;
    
    // host
    UILabel *_hostNameLabel;
    UILabel *_hostScoreLabel;
    
    UIView *_hostIconView;
    SNWebImageView *_hostIcon;
    UIImageView *_hostIconMaskView;
    
    UIView *_hostUpView;
    UIImageView *_hostUpIcon;
    UILabel *_hostUpLabel;
    
    // visit
    UILabel *_visitNameLabel;
    UILabel *_visitScoreLabel;
    
    UIView *_visitIconView;
    SNWebImageView *_visitIcon;
    UIImageView *_visitIconMaskView;
    
    UIView *_visitUpView;
    UIImageView *_visitUpIcon;
    UILabel *_visitUpLabel;
}

@property(nonatomic, copy) NSString *hostName;
@property(nonatomic, copy) NSString *hostIconUrl;
@property(nonatomic, copy) NSString *hostUp;
@property(nonatomic, copy) NSString *hostScore;

@property(nonatomic, copy) NSString *visitName;
@property(nonatomic, copy) NSString *visitIconUrl;
@property(nonatomic, copy) NSString *visitUp;
@property(nonatomic, copy) NSString *visitScore;

@end
