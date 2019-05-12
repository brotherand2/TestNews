//
//  SNDefaultRequest.h
//  TT_AllInOne
//
//  Created by tt on 15/5/28.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import "SNNewsRequest.h"

/**
 *  使用 Builder Pattern 提供除了继承实现协议外，另一种使用request的方法
 参考 http://limboy.me/ios/2015/02/07/builder-pattern.html
 http://www.annema.me/the-builder-pattern-in-objective-c
 *  但是在builder中需重复显示声明 request中的属性，可以用runtime来优化一下 ?
 */

@interface SNDefaultRequestBuilder : NSObject

@property (nonatomic) SNRequestMethod requestMethod;
@property (nonatomic) SNResponseType responseType;
@property (strong, nonatomic) id parameters;
@property (copy, nonatomic) NSString *customUrl;

- (id)build;

@end


// 只实现SNRequestProtocol，用来方便请求第三方资源
typedef void (^BuilderBlock)(SNDefaultRequestBuilder *builder);

@interface SNDefaultRequest : SNBaseRequest <SNRequestProtocol>

@property (nonatomic) SNRequestMethod requestMethod;
@property (nonatomic) SNResponseType responseType;
@property (strong, nonatomic) id parameters;
@property (copy, nonatomic) NSString *customUrl;

- (instancetype)initWithBuilder:(SNDefaultRequestBuilder *)builder;

+ (instancetype)createWithBuilder:(BuilderBlock)builderBlock;

@end
