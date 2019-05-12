//
//  SNNotificationCell.h
//  sohunews
//
//  Created by weibin cheng on 13-6-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"

@class SNNotificationItem;

@interface SNNotificationCell : UITableViewCell
{
    UIImageView *_cellSelectedBg;
    SNWebImageView* _headImageView;
    UILabel* _titleLabel;
    UILabel* _contentLabel;
    UILabel* _timeLabel;
}

-(void)updateContent:(SNNotificationItem*)item;
-(void)updateTheme;
-(void)cancelAllImageLoading;
@end


@interface SNNotificationUpgradeCell : UITableViewCell
-(void)updateTheme;
@end


@interface SNSimpleNotificationCell : UITableViewCell
{
    UILabel* _contentLabel;
    UILabel* _timeLabel;
}

-(void)updateContent:(SNNotificationItem*)item;

@end
