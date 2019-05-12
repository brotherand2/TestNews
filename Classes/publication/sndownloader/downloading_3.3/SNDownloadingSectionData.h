//
//  SNDownloadingSectionData.h
//  sohunews
//
//  Created by handy wang on 1/21/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDownloadingSectionData : NSObject {
    NSString *_tag;
    NSMutableArray *_arrayData;
}

@property(nonatomic, copy)NSString *tag;
@property(nonatomic, strong)NSMutableArray *arrayData;
@end
