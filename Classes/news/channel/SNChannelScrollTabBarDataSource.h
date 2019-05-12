//
//  SNChannelScrollTabBarDataSource.h
//  sohunews
//
//  Created by wang yanchen on 13-1-5.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNScrollTabBarDataSourceWrapper.h"
#import "SNChannelModel.h"

@interface SNChannelScrollTabBarDataSource : SNScrollTabBarDataSourceWrapper 
@property (nonatomic, strong) SNChannelModel *model;
@property (nonatomic, strong) NSString *savedIDString;

- (id)initWithController:(id)controller;
- (BOOL)shouldReload;

/**
 init方法会addObserve，用此方法来remove

 @param controller init中的controller是谁这里就传谁
 */
- (void)removeObservers:(id)controller;
@end
