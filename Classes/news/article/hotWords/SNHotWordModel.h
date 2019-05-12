//
//  SNHotWordModel.h
//  sohunews
//
//  Created by weibin cheng on 14-7-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "JSONModel.h"

@interface SNHotWordModel : JSONModel

@property (nonatomic, assign) NSInteger uiqueId;
@property (nonatomic, assign) BOOL isSpread;
@property (nonatomic, strong) NSString<Optional>* name;
@property (nonatomic, strong) NSString<Optional>* url;

@end
