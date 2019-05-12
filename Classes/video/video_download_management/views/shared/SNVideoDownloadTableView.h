//
//  SNVideoDownloadTableView.h
//  sohunews
//
//  Created by handy wang on 8/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNVideoDownloadTableView : UITableView
- (void)beginEdit;
- (void)finishEdit;

- (void)selectAll;
- (void)deselectAll;
@end
