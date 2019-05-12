//
//  SNMyMessageTable.h
//  sohunews
//
//  Created by jialei on 14-2-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCommentListTable.h"

typedef void (^SNTableLoadingTapCallback)();

@interface SNMyMessageTable : SNCommentListTable

@property (nonatomic, copy)SNTableLoadingTapCallback tableTapCallback;

@end
