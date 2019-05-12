//
//  SNAppConfigFloatingLayer.h
//  sohunews
//
//  Created by wangyy on 16/3/10.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SNAppConfigFloatingLayer : CAEmitterLayer

@property (nonatomic, assign) int layerType;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *H5Url;

- (void)updateWithDic:(NSDictionary *)appSettingDic ;

@end
