
//
//  SohuARMacro.h
//  SohuAR
//
//  Created by sun on 2016/11/29.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#ifndef SohuARMacro_h
#define SohuARMacro_h

//path
#define karCacheDocument @"/com.Sohu-inc.SohuARSDK"
#define KWS(weakSelf)  __weak __typeof(&*self)weakSelf = self

#define khost @"https://ar.daxiangvr.tv/"
#define kZipURLString @"file:///Users/sun/Desktop/Resources.zip"
//size
#define kscreenHeight     [UIScreen mainScreen].bounds.size.height
#define kscreenWidth      [UIScreen mainScreen].bounds.size.width
//notification
#define kgoHTMLNotification @"goHTMLNotification"
#define kBackgroundMusic @"BackgroundMusic"
#define kconfigurations @"Configurations.plist"
#define kTimeInterval  @"TimeInterval"

#define kconfigurationsPath [NSString stringWithFormat:@"%@%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,karCacheDocument,@"Resources/Configurations.plist"]


#endif /* SohuARMacro_h */
