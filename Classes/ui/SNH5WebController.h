//
//  SNH5WebController.h
//  sohunews
//
//  Created by chenhong on 13-8-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNWebController.h"

@interface SNH5WebController : SNWebController
{
    BOOL _isNaviInHistory;
    int _currentHistoryIndex;
    NSMutableArray *_historyRequests;
}

@property(nonatomic,strong)NSURLRequest *failedRequest;
@property(nonatomic,strong)NSMutableArray *historyRequests;

@end
