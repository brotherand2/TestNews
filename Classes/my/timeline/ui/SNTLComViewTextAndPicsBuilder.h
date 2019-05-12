//
//  SNTLComViewTextAndPicsBuilder.h
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLComViewBuilder.h"

@interface SNTLComViewTextAndPicsBuilder : SNTLComViewBuilder

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *abstract;
@property(nonatomic, copy) NSString *imageUrl;
@property(nonatomic, copy) NSString *imagePath;
@property(nonatomic, copy) UIImage *image;
@property(nonatomic, copy) NSString *fromString;
@property(nonatomic, copy) NSString *typeString;
@property(nonatomic, assign) BOOL hasVideo;
@property(nonatomic, assign) BOOL isChannelPreview;

@end
