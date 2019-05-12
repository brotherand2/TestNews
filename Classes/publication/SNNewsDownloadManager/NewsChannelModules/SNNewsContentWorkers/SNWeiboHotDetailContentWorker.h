//
//  SNWeiboHotDetailContentWorker.h
//  sohunews
//
//  Created by handy wang on 2/5/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsContentWorker.h"

@interface SNWeiboHotDetailContentWorker : SNNewsContentWorker

- (void)fetchWeiboHotDetailContentWithWeiboId:(NSString *)weiboId;

@end
