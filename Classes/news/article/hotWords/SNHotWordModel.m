//
//  SNHotWordModel.m
//  sohunews
//
//  Created by weibin cheng on 14-7-29.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNHotWordModel.h"

@implementation SNHotWordModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"adId":@"uiqueId"}];
}
@end
