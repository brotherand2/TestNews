//
//  SNMyCommenViewController.h
//  sohunews
//
//  Created by jialei on 13-4-23.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//


#import "SNNewsComment.h"


@interface SNMessageCenterViewController : SNBaseViewController<UIScrollViewDelegate>
{
    NSString *_userId;
    NSString *_topicId;
    NSString *_pid;
}

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSString *pid;

@property (nonatomic, strong) SNNewsComment *replyComment;

@end
