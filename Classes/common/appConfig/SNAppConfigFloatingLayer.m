//
//  SNAppConfigFloatingLayer.m
//  sohunews
//
//  Created by wangyy on 16/3/10.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAppConfigFloatingLayer.h"
#import "SNAppConfigConst.h"

@implementation SNAppConfigFloatingLayer

@synthesize layerType = _layerType;
@synthesize picUrl = _picUrl;
@synthesize H5Url = _H5Url;

- (void)dealloc{
    
}

- (void)updateWithDic:(NSDictionary *)appSettingDic {
    NSArray *array = [appSettingDic objectForKey:kFloatingLayer defalutObj:nil];
    if (array.count > 0) {
        NSDictionary *dic = [array objectAtIndex:0];
        if (dic != nil && [dic count] > 0) {
            self.layerType = [[dic objectForKey:@"type"] intValue];
            self.picUrl = [dic objectForKey:@"picUrl" defalutObj:nil];
            self.H5Url = [dic objectForKey:@"url" defalutObj:nil];
        }
    }
    
}


@end
