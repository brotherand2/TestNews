//
//  SNChatFeedbackController.h
//  sohunews
//
//  Created by qi pei on 8/8/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SNChatFeedbackController : SNBaseViewController

@property (nonatomic,strong) NSDictionary *feedbackDict;
@property (nonatomic,strong) UIScrollView *scrollView;

- (void)gotoFeedBackTabWithIndex:(NSInteger)index andAnimated:(BOOL)animated;

@end
