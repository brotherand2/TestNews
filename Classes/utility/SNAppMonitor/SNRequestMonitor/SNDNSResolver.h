//
//  SNDNSResolver.h
//  sohunews
//
//  Created by WongHandy on 8/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDNSResolver : NSObject
@property(nonatomic, strong, readonly) NSURL *url;
@property(nonatomic, copy, readonly) NSString *resolvedIpAddress;

- (id)initWithURL:(NSURL *)url;
- (void)resolve;
@end
