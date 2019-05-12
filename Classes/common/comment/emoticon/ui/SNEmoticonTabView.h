//
//  SNEmoticonTabView.h
//  sohunews
//
//  Created by jialei on 14-5-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNEmoticonManager.h"

typedef NS_ENUM(NSUInteger, SNEmoticonConfigType) {
    SNEmoticonConfigNews = 1,
    SNEmoticonConfigLive = 2
};

@interface SNEmoticonTabView : UIView<SNEmoticonScrollViewDelegate>

@property (nonatomic, weak) id <SNEmoticonScrollViewDelegate>delegate;
@property (nonatomic, assign) SNEmoticonType currentType;

- (id)initWithType:(SNEmoticonConfigType)type frame:(CGRect)frame;

@end
