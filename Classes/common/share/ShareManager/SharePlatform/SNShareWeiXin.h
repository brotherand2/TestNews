//
//  SNShareWeiXin.h
//  sohunews
//
//  Created by wang shun on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSharePlatformBase.h"

@interface SNShareWeiXin : SNSharePlatformBase

@property (nonatomic,strong) NSString* wxType;// WXSession(好友)/WXTimeline(朋友圈)

-(instancetype)initWithOption:(NSInteger)option;

+ (BOOL)isInstalledWeiXin;

@end
