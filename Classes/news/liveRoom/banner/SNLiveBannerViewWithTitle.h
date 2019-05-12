//
//  SNLiveBannerViewWithTitle.h
//  sohunews
//
//  Created by wang yanchen on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveBannerView.h"

@interface SNLiveBannerViewWithTitle : SNLiveBannerView {
    UILabel *_titleLabel;
    UILabel *_liveStatusLabel;
    UILabel *_pubTypeLabel; // 独家
}

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong)UILabel *liveStatusLabel;

@end
