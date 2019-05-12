//
//  SNFeedBackTextModel.h
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackModel.h"

typedef NS_ENUM(NSInteger,FeedBackType)
{
    FeedBackTypeMe = 0,
    FeedBackTypeReply
};

@interface SNFeedBackTextModel : SNFeedBackModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fbText;
@property (nonatomic, assign) FeedBackType fbType;


@end
