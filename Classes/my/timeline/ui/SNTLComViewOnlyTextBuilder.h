//
//  SNTLComViewOnlyTextBuilder.h
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLComViewBuilder.h"

@interface SNTLComViewOnlyTextBuilder : SNTLComViewBuilder

// data source
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *abstract;
@property(nonatomic, copy) NSString *fromString;
@property(nonatomic, copy) NSString *typeString;

@end
