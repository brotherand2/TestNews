//
//  SNDownloadUtil.h
//  sohunews
//
//  Created by handy wang on 6/14/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDownloadUtil : NSObject

+ (id)makeUncompressedJsonToObject:(NSData *)data;
+ (void)downloadImageWithUrl:(NSString *)url;

@end