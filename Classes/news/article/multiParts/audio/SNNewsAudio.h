//
//  SNNewsAudio.h
//  sohunews
//
//  Created by chenhong on 13-5-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsAudio : NSObject
@property(nonatomic,assign) NSInteger ID;
@property(nonatomic,copy)NSString *termId;
@property(nonatomic,copy)NSString *newsId;
@property(nonatomic,copy)NSString *audioId;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *playTime;
@property(nonatomic,copy)NSString *size;

@end
