//
//  SNSubCenterTableHelper.h
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubscribeCenterService.h"

@interface SNSubCenterTableHelper : NSObject<UITableViewDataSource, UITableViewDelegate, SNSubscribeCenterServiceDelegate> {
    UITableView *_tableView;
    
    id __weak _delegate;
    
    BOOL _bDataInvalidate;
}

@property(nonatomic, weak) id delegate;
@property(assign) BOOL bDataInvalidate;

- (id)initWithTableView:(UITableView *)tableView delegate:(id)delegate;
- (void)startListen;
- (void)stopListen;
- (void)setNeedsReload;
- (void)reloadData;

@end
