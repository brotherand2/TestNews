//
//  SNLiveWebController.h
//  sohunews
//
//  Created by chenhong on 14-5-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNWebController.h"

@interface SNLiveWebController : SNWebController

@property(nonatomic,copy)NSString *originalUrl;

- (void)refreshInSilence;
- (void)openWithUrl:(NSString *)url;
- (UIScrollView *)scrollView;

@end
