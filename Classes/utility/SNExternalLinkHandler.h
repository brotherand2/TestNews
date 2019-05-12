//
//  SNExternalLinkHandler.h
//  sohunews
//
//  Created by Xiang WeiJia on 12/25/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
  外链有2种情况：
 1、从配置文件里读取
     这种情况只适用于第一次启动时
 2、由外部传入
    外部传入有两种情况：
       程序没启动时，由外部传入
       程序启动之后，由外部传入
 */

@interface SNExternalLinkHandler : NSObject

@property (nonatomic) BOOL isAppLoad;

+ (SNExternalLinkHandler *)sharedInstance;

// 从配置文件里获取外链
- (NSURL *)loadExternalLinkFromConfigFile;

- (void)setExternalLink:(NSURL *)externalLink;

// 处理外链
- (BOOL)handleExternalLinker;

- (BOOL)isLoadFromTag;

@end
