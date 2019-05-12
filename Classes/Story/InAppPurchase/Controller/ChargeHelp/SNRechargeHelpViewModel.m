//
//  SNVoucherCenterViewModel.m
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRechargeHelpViewModel.h"
#import "SNRechargeHelpTableViewCell.h"

@implementation SNRechargeHelpViewModel

#pragma mark - TableView
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kAppScreenHeight - kToolbarHeight - kHeaderTotalHeight;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"RechargeHelpTableViewCell";
    SNRechargeHelpTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[SNRechargeHelpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

@end
