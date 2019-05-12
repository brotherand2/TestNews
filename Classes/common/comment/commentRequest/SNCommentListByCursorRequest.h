//
//  SNCommentListByCursorRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNCommentListByCursorRequest : SNDefaultParamsRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict needNetSafeParameters:(BOOL)needNetSafe;

@end
