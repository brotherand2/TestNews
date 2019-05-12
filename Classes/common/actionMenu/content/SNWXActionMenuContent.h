//
//  SNWXActionMenuContent.h
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTitleActionMenuContent.h"

@interface SNWXActionMenuContent : SNTitleActionMenuContent

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSString *webUrl;
@property (nonatomic, strong) NSString *mediaUrl;
@property (nonatomic, strong) NSString *newsLink;
@property (nonatomic, strong) NSMutableDictionary *shareInfoDic;

- (BOOL)isVideo;
- (BOOL)isOnlyImage;

@end
