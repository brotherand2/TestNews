//
//  JKGlobalSettings.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/14.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JKImageLoadMode) {
    JKImageLoadAlways,
    JKImageLoadCachedOnly,
    JKImageLoadNoImage
};


typedef void(^Logger)(NSString* log);

@protocol JKZipArchiveDelegate <NSObject>

-(BOOL)unzipFileAtPath:zipPath toDestination: unzipPath;

@end

@protocol JKAuthDelegate <NSObject>

-(BOOL)shouldUrlUseJsKit:(NSURL*)url;

@end

@interface JKGlobalSettings : NSObject

@property(copy, nonatomic)Logger logger;

@property(assign, nonatomic) JKImageLoadMode imageLoadMode;


/**
 * 开启deubg模式，YES开启，NO不开启
 */
@property(assign, nonatomic) BOOL debugMode;

/**
 * zip包资源所在目录
 * 默认是@"shwebapp" 即资源需要放到工程资源目录的shwebapp目录下，可以设置为其他相对路径。
 */
@property(strong, nonatomic) NSString* webAppResourcePath;

/**
 * 解压，默认通过SSZipArchive完成解压。如果工程中没有SSZipArchive需要通过该delegate实现解压功能。
 */
@property(strong, nonatomic) id<JKZipArchiveDelegate> zipArchiveDelegate;

/**
 * 判断一个URL是不是在白名单里面，如果在白名单里面，则改URL可以使用jskit框架提供的native接口。
 */
@property(strong, nonatomic) id<JKAuthDelegate> authDelegate;

+(JKGlobalSettings*)defaultSettings;

@end
