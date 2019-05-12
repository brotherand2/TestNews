//
//  SNChannelListCell.h
//  sohunews
//
//  Created by lhp on 4/1/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNChannelListCell : UITableViewCell
- (void)localChannelWithCity:(NSString *)cityName;
- (void)localChannelWithLocalCity:(NSString *)cityName;
- (void)localChannelWithCity:(NSString *)cityName
                     keyWord:(NSString *)keyWord;
- (void)localIntelligentSearchWithString:(NSString *)string;
- (void)drawSeperateLine;
- (void)removeRefreshButton;
@end
