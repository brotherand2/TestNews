//
//  SNRollingTrainFocusCell.h
//  sohunews
//
//  Created by HuangZhen on 2017/10/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingBaseCell.h"

@interface SNRollingTrainFocusCell : SNRollingBaseCell

- (void)tableViewWillBeginDragging:(UITableView *)tableView;
- (void)tableViewDidScroll:(UITableView *)tableView;
- (void)tableViewDidEndDraging:(UITableView *)tableView;
- (void)tableViewDidEndScroll:(UITableView *)tableView;

@end
