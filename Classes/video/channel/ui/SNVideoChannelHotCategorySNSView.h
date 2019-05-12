//
//  SNVideoChannelHotCategorySNSView.h
//  sohunews
//
//  Created by jojo on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelHotCategoryView.h"

@interface SNVideoChannelHotCategorySNSView : SNVideoChannelHotCategoryView <SNShareManagerDelegate> {
    UIButton *_bindBtn;
}

@property (nonatomic, copy) NSString *appId;

@end
