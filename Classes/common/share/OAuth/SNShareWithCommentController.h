//
//  SNSharePostController.h
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNShareManager.h"
#import "SNAlert.h"

#import "SNActionSheet.h"
#import "SNSharePostController.h"


@interface SNShareWithCommentController : SNSharePostController {
}

@property(nonatomic, assign) BOOL bPresentFromWindowDelegate;
- (BOOL)startPost;
- (id)initWithShareInfo:(NSDictionary *)shareInfo;
- (void)creatView;
- (void)changeInputInfo;
- (void)setImageClipButton;

@end
