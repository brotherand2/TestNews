//
//  SNSpecialNewsListContentWorker.h
//  sohunews
//
//  Created by handy wang on 1/11/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsContentWorker.h"

@interface SNSpecialNewsListContentWorker : SNNewsContentWorker {
    NSMutableArray *_specialNewsArray;
    SNNewsContentWorkerNews *_runningWorkerNews;
}

@end
