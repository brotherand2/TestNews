//
//  SNMoreAppController.h
//  sohunews
//
//  Created by wangxiang on 3/31/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebController.h"

@interface SNMoreAppController : SNWebController
@property (nonatomic,assign)BOOL isFristURL;

- (void)loadUrl:(NSString *)url;

@end
