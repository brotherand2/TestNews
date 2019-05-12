//
//  TextConfig.h
//  tangyuanReader
//
//  Created by 王 强 on 13-6-8.
//  Copyright (c) 2013年 中文在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttributeConfig : NSObject
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSDictionary *attributes;

- (void)setFontSize:(NSInteger)fontType;
- (void)setReadStyle:(NSInteger)readStyle;
@end
