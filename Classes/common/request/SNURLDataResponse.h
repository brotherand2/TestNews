//
//  SNURLDataResponse.h
//  sohunews
//
//  Created by kuanxi zhu on 8/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNURLDataResponse : NSObject <TTURLResponse> {
	NSData* _data;
    NSDictionary* _responceHeader;
}

@property (nonatomic, readonly) NSData* data;
@property (nonatomic, strong) NSDictionary* responceHeader;
@end
