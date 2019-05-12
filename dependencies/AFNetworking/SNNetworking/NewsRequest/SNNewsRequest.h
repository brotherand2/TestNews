//
//  SNNewsRequest.h
//  TT_AllInOne
//
//  Created by tt on 15/6/2.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import "SNBaseRequest.h"

@protocol SNNewsRequestProtocol <NSObject>

@required
/**
 *  是否需要P1参数
 *
 *  @return YES or NO
 */
- (BOOL)sn_needP1;

/**
 *  是否需要做返回值检查
 *
 *  @return YES or NO
 */
- (BOOL)sn_needCheckResponse;

@end

@interface SNNewsRequest : SNBaseRequest
@property (weak, nonatomic) id<SNNewsRequestProtocol> newsDelegate;
@end
