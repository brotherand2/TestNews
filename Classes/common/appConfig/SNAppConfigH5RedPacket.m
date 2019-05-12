//
//  SNAppConfigH5RedPacket.m
//  sohunews
//
//  Created by yangln on 2017/1/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNAppConfigH5RedPacket.h"
#import "SNAppConfigConst.h"
#import <JsKitFramework/JsKitFramework.h>

@implementation SNAppConfigH5RedPacket

- (void)updateWithDict:(NSDictionary *)dict {
    NSDictionary *packetDict = [dict objectForKey:kH5RedPacket];
    self.redPacketUrl = [packetDict stringValueForKey:@"url" defaultValue:nil];
    
    /*-----------正文页红包相关------------*/
    //是否显示浮层按钮
    self.redPacketFloatBtnIsShow = [[dict stringValueForKey:kH5ArticleShowRedPacket defaultValue:@""] boolValue];

    JsKitStorage *jsKitStorageMange  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    //告知H5什么时候请求红包数据
    [jsKitStorageMange setItem:[NSNumber numberWithBool:self.redPacketFloatBtnIsShow] forKey:@"isShowH5PicTextRedPacket"];
    
    //红包详情
    self.redPacketDict = [[dict objectForKey:kH5ArticleRedPacketInfo defalutObj:nil] copy];
    if (self.redPacketDict && [self.redPacketDict isKindOfClass:[NSDictionary class]]) {
        self.redPacketType = [self.redPacketDict stringValueForKey:kType defaultValue:@""];
        self.redPacketPicUrl = [self.redPacketDict stringValueForKey:kPicUrl defaultValue:@""];
        self.redPacketDetailUrl = [self.redPacketDict stringValueForKey:kUrl defaultValue:@""];
        self.redPacketPosition = [self.redPacketDict stringValueForKey:kPosition defaultValue:@""];
        self.redPacketIsShow = [[self.redPacketDict stringValueForKey:kIsShow defaultValue:@""] boolValue];
        self.redPacketStartTime = [self.redPacketDict stringValueForKey:kStartTime defaultValue:@""];
        self.redPacketEndTime = [self.redPacketDict stringValueForKey:kEndTime defaultValue:@""];
    }
}

@end
