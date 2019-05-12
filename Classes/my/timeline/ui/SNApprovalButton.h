//
//  SNApprovalView.h
//  sohunews
//
//  Created by jialei on 13-12-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDingView.h"


#define kSNTLTrendApprovalWidth (108 / 2)
#define kSNTLTrendApprovalHeight (46 / 2)

@interface SNApprovalButton : SNDingView

@property (nonatomic, assign)int topNumbers;
@property (nonatomic, assign)BOOL hasApproval;
@property (nonatomic, weak)NSString *pid;
@property (nonatomic, weak)NSString *actId;
@property (nonatomic, strong)UIImage *customBgImage;
@property (nonatomic, strong)SNTimelineTrendItem *trendItem;

- (void)updateTheme;

@end
