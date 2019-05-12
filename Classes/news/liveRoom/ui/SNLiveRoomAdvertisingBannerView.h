//
//  SNLiveRoomAdvertisingBannerView.h
//  sohunews
//
//  Created by lijian on 15-3-26.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^handleAdvertisingClose)(void);

@interface SNLiveRoomAdvertisingBannerView : SNWebImageView

@property (nonatomic,strong) SNWebImageView *adImgView;
//@property (nonatomic,retain) UILabel *tuiguang;


- (void)closeAdvetising:(handleAdvertisingClose)handle;

@end
