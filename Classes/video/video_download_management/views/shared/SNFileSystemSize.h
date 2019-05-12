//
//  SNFileSystemSize.h
//  sohunews
//
//  Created by handy wang on 10/12/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNFileSystemSize : NSObject
@property (nonatomic, assign)unsigned long long totalFileSystemSizeInBytes;
@property (nonatomic, assign)unsigned long long freeFileSystemSizeInBytes;
@end