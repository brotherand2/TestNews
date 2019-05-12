//
//  SNWeatherCityAddCell.h
//  sohunews
//
//  Created by yanchen wang on 12-7-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNWeatherCityAddCell : SNTableViewCell {
    UIButton *_editBtn;
    NSDictionary *_cityInfoDic;
    UIImage *_addImage;
    UIImage *_delImage;
    id __weak _delegate;
    BOOL _bSubed;
}

@property(nonatomic, strong)UIButton *editBtn;
@property(nonatomic, strong)NSDictionary *cityInfoDic;
@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)BOOL bSubed;

@end

@protocol SNWeatherCityAddCellDelegate <NSObject>

@required
- (void)delAction:(SNWeatherCityAddCell *)cell;
- (void)addAction:(SNWeatherCityAddCell *)cell;

@end
