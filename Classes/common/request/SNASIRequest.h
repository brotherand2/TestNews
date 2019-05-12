//
//  SNASIRequest.h
//  sohunewsipad
//
//  Created by ivan on 9/25/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

#import "ASIHTTPRequest.h"

@interface SNASIRequest : ASIHTTPRequest {
    BOOL isShowNoNetWorkMessage;
}
@property(nonatomic,readwrite)BOOL isShowNoNetWorkMessage;

@end
