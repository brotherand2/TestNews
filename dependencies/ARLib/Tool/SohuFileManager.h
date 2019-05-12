//
//  SohuFileManager.h
//  SohuAR
//
//  Created by sun on 2016/11/29.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SohuFileManager : NSObject

+(NSURL *)readSceneSourceFromCachesWithRelativePath:(NSString *)relativePath;

+(UIImage *)readImageFromCachesWithRelativePath:(NSString *)relativePath;

+(NSData *)readDataFromCachesWithRelativePath:(NSString *)relativePath;

+(NSURL *)loadMusicFromCachesWithRelativePath:(NSString *)relativePath;

+(NSString *)loadAbsolutePathWithRelativePath:(NSString *)relativePath;

+(NSDictionary *)loadSohuConfigurations;

+(BOOL)zipResourcesAvailable;

+(BOOL)zipFileTimeOut;

@end
