//
//  SNNewsDataSource.h
//  sohunews
//
//  Created by chenhong on 14-3-6.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "Three20UI.h"
@class SNRollingNewsTableController;

@protocol SNNewsDataSource <NSObject>

- (BOOL)isModelEmpty;

@end


@interface SNNewsDataSource : TTSectionedDataSource<SNNewsDataSource>

@property (nonatomic, weak) SNRollingNewsTableController *controller;//byhqz

@end
