//
//  SNMultiColumnTableView.h
//  sohunews
//
//  Created by jojo on 13-9-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNMultiColumnTableView;

@protocol SNMultiColumnTableViewReuseViewProvider <NSObject>

@required
- (UIView *)reusableViewForIndexPath:(NSIndexPath *)indexPath;
- (void)clearAllReusableViews;
- (void)clearReusableViewForIndexPath:(NSIndexPath *)indexPath;

@end

@protocol SNMultiColumnTableViewDelegate <NSObject>

@required

- (NSInteger)mcTableView:(SNMultiColumnTableView *)tableview numberOfItemsInSeciont:(NSInteger)section;
- (UIView *)mcTableView:(SNMultiColumnTableView *)tableView viewForIndexPath:(NSIndexPath *)indexPath fromProvider:(id<SNMultiColumnTableViewReuseViewProvider>)provider;

@optional

// default is 1
- (NSInteger)numberOfSectionInMCTableView:(SNMultiColumnTableView *)tableView;

// default value is 1
- (NSInteger)mcTableView:(SNMultiColumnTableView *)tableView numberOfColumnInSection:(NSInteger)section;

// default nil
- (UITableViewCell *)mcTableView:(SNMultiColumnTableView *)tableview cellAtIndexPath:(NSIndexPath *)indexPath;

// default NO
- (BOOL)mcTableView:(SNMultiColumnTableView *)tableview shouldUseCustomCellInSection:(NSInteger)section;

// for custom view frame
- (CGRect)mcTableView:(SNMultiColumnTableView *)tableview viewFrameAtIndexPath:(NSIndexPath *)indexPath andViewIndex:(NSInteger)index;

// default is default table cell height
- (CGFloat)mcTableView:(SNMultiColumnTableView *)tableview heightForRowInSection:(NSInteger)section;

- (void)mcTableView:(SNMultiColumnTableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// section head view

// default is nil
- (UIView *)mcTableView:(SNMultiColumnTableView *)tableView viewForHeaderInSection:(NSInteger)section;

// default is 0
- (CGFloat)mcTableView:(SNMultiColumnTableView *)tableView heightForHeaderInSection:(NSInteger)section;

@end

@interface SNMultiColumnTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

// multi column table delegate
@property (nonatomic, weak) id<SNMultiColumnTableViewDelegate> mcDelegate;

@end


