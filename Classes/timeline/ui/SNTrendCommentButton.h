//
//  SNTrendCommentButton.h
//  sohunews
//
//  Created by jialei on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNTrendCommentButton : UIView

@property(nonatomic, retain)NSString *actId;
@property(nonatomic, retain)NSString *pid;
@property(nonatomic, retain)NSString *fPid;
@property(nonatomic, assign) int referFrom;

- (void)updateTheme;

@end
