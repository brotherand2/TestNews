//
//  SNUgradeInfo.m
//  sohunews
//
//  Created by TengLi on 2017/6/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUpgradeInfo.h"

@implementation SNUpgradeInfo

@synthesize bNeedUpgrade = _bNeedUpgrade;
@synthesize upgradeType	= _upgradeType;
@synthesize packageSize	= _packageSize;
@synthesize description = _description;
@synthesize downloadUrl = _downloadUrl;
@synthesize latestVer	= _latestVer;
@synthesize serverRtnError	= _serverRtnError;
@synthesize networkError= _networkError;


-(BOOL)hadError
{
    return ([_serverRtnError length] != 0) || (_networkError != nil);
}

-(NSData*)getData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+(id)upgradeInfoWithData:(NSData*)data
{
    if (data == nil) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

-(id)initWithCoder:(NSCoder*)coder
{
    if (self = [super init]) {
        self.bNeedUpgrade	= [coder decodeBoolForKey:@"_bNeedUpgrade"];
        self.upgradeType	= [coder decodeIntForKey:@"_upgradeType"];
        self.packageSize	= [coder decodeIntForKey:@"_packageSize"];
        self.description	= [coder decodeObjectForKey:@"_description"];
        self.downloadUrl	= [coder decodeObjectForKey:@"_downloadUrl"];
        self.latestVer		= [coder decodeObjectForKey:@"_latestVer"];
        self.serverRtnError	= [coder decodeObjectForKey:@"_serverRtnError"];
        self.networkError	= [coder decodeObjectForKey:@"_networkError"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeBool:self.bNeedUpgrade forKey:@"_bNeedUpgrade"];
    [coder encodeInt:self.upgradeType forKey:@"_upgradeType"];
    [coder encodeInt:self.packageSize forKey:@"_packageSize"];
    [coder encodeObject:self.description forKey:@"_description"];
    [coder encodeObject:self.downloadUrl forKey:@"_downloadUrl"];
    [coder encodeObject:self.latestVer forKey:@"_latestVer"];
    [coder encodeObject:self.serverRtnError forKey:@"_serverRtnError"];
    [coder encodeObject:self.networkError forKey:@"_networkError"];
}

@end
