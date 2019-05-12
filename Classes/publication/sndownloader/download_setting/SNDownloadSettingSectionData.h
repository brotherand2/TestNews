//
//  SNDownloadSettingSectionData.h
//  sohunews
//
//  Created by handy wang on 1/21/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDownloadSettingSectionData : NSObject {
    NSMutableArray *_arrayData;
    NSString *_tag;
}
@property(nonatomic, strong)NSMutableArray *arrayData;
@property(nonatomic, copy)NSString *tag;
@end
