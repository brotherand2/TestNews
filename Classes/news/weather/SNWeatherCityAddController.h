//
//  SNWeatherCityAddController.h
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//
#import "SNWeatherCityAddCell.h"

@interface SNWeatherCityAddController : TTViewController<UITableViewDataSource, UITableViewDelegate, SNWeatherCityAddCellDelegate>
{
    
}

-(NSDictionary*)cityInfoDicByIndexpath:(NSIndexPath*)indexPath;
@end
