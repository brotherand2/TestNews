//
//  STADZipArchiveForwarder.h
//  SCADCore
//
//  Created by acorld on 2017/10/23.
//  Copyright © 2017年 acorld. All rights reserved.
//

#import <Foundation/Foundation.h>

/********使用方法********/
//step1
/*
 #import "STADZipArchiveForwarder.h"
 [STADZipArchiveForwarder registerForwarder:[DemoForZipClass class]];
 */

//step2
/*
 #import "STADZipArchiveForwarder.h"
 
 @interface DemoForZipClass : NSObject<STADZipArchiveForwarderProtocol>
 
 @end
 
 
 #import "ZipArchive.h"
 
 @implementation DemoForZipClass
 
 + (BOOL)canUnzipFileAtPath:(nonnull NSString *)path
 {
 ZipArchive *archive = [[ZipArchive alloc] init];
 return [archive UnzipOpenFile:path];
 }
 
 + (BOOL)unzipFileAtPath:(nonnull NSString *)path toDestination:(nonnull NSString *)destination
 {
 ZipArchive *archive = [[ZipArchive alloc] init];
 if ([archive UnzipOpenFile:path]) {
 return [archive UnzipFileTo:destination overWrite:YES];
 }
 
 return NO;
 }
 
 @end
 
 */

/**
 zip功能的适配协议
 */
@protocol STADZipArchiveForwarderProtocol<NSObject>


/**
 zip是否能解压
 
 @param path zip路径
 @return 是否能解压
 */
+ (BOOL)canUnzipFileAtPath:(nonnull NSString *)path;

/**
 将zip解压到指定路径
 
 @param path zip路径
 @param destination 指定路径
 @return 是否解压成功
 */
+ (BOOL)unzipFileAtPath:(nonnull NSString *)path toDestination:(nonnull NSString *)destination;

@end

/**
 zip和unzip的实现托管类
 */
@interface STADZipArchiveForwarder : NSObject


/**
 注册负责zip功能的类
 
 @param protocolClass 实现了<STADZipArchiveForwarderProtocol>的类
 */
+ (void)registerForwarder:(nonnull Class)protocolClass;


/**
 取消注册负责zip功能的类
 
 @param protocolClass 实现了<STADZipArchiveForwarderProtocol>的类
 */
+ (void)unregisterForwarder:(nonnull Class)protocolClass;



@end

