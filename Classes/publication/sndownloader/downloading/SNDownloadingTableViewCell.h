//
//  FKDownloadingTableViewCellCell.h
//  FK
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNDownloadingTableViewCell : UITableViewCell {
    id _downloadingItem;
}

@property (nonatomic, strong)id downloadingItem;

- (void)updateProgress:(NSNumber *)progress;

- (void)requestFailed;

- (void)requestFinished;

- (void)resetProgessBar;


@end
