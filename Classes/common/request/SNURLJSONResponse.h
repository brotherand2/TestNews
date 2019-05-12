//
//  SNURLJSONResponse.h
//  sohunews
//
//  Created by kuanxi zhu on 8/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTURLJSONResponse.h"

@interface SNURLJSONResponse : TTURLJSONResponse {
    NSData *requestData;
    NSDictionary* _responceHeader;
}

@property(nonatomic,strong)NSData *requestData;
@property(nonatomic, strong) NSDictionary* responceHeader;
@end
