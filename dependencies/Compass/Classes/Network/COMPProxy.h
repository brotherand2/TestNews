//
//  COMPProxy.h
//  Compass
//
//  Created by 李耀忠 on 16/10/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COMPProxy : NSProxy <NSURLSessionDelegate>

- (instancetype)initWithDelegate:(id<NSURLSessionDelegate>)delegate;

@end
