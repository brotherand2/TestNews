//
//  SNUgradeInfo.h
//  sohunews
//
//  Created by TengLi on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNUpgradeInfo : NSObject <NSCoding>
{
    BOOL		_bNeedUpgrade;
    int			_upgradeType;
    int			_packageSize;
    NSString	*_description;
    NSString	*_downloadUrl;
    NSString	*_latestVer;
    NSString	*_serverRtnError;
    NSError		*_netWorkError;
}

@property (nonatomic,assign)BOOL bNeedUpgrade;
@property (nonatomic,assign)int upgradeType;//升级类型 1 可选升级，2 重要升级 3强制升级
@property (nonatomic,assign)int packageSize;
@property (nonatomic,copy) NSString *description;
@property (nonatomic,copy) NSString *downloadUrl;
@property (nonatomic,copy) NSString *latestVer;
@property (nonatomic,copy) NSString *serverRtnError;
@property (nonatomic,copy) NSError *networkError;

-(BOOL)hadError;
-(NSData*)getData;

+(id)upgradeInfoWithData:(NSData*)data;

@end
