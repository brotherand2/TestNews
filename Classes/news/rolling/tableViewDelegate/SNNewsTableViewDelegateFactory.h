//
//  SNNewsTableViewDelegateFactory.h
//  sohunews
//
//  Created by chenhong on 14-3-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsChannelType.h"
#import "SNTableHeaderDragRefreshView.h"

@class SNNewsTableViewDelegate;

@interface SNNewsTableViewDelegateFactory : NSObject

+ (SNNewsTableViewDelegate *)tableViewDelegateWithNewsChannelType:(SNNewsChannelType)type
                                                        channelId:(NSString *)channelId
                                                       controller:(TTTableViewController *)controller
                                                         headView:(SNDragRefreshView *)header;

@end
