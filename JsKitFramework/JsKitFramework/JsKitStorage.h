//
//  JsKitStorage.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/19.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsKitStorage : NSObject

@property (strong, nonatomic)NSString* webAppName;

-(instancetype)initWithWebAppName:(NSString*)webAppName;

-(void)setItem:(id)item forKey:(NSString*)key;

-(void)setItem:(id)item forKey:(NSString *)key withExpire:(NSNumber*)expire;

/**
 * 查询所有条件匹配的项，可以传例如"article%"则查询所有key以article开头的项。返回格式为[{@"key":key,@"value":value}]
 */
-(id)findItems:(NSString*)likeKey;

-(id)getItem:(NSString*)key;

-(void)removeItem:(NSString*)key;

/**
 * 删除所有匹配条件的项，比如likeKey为"article%"则删除所有以article开头的项。
 */
-(id)removeItems:(NSString*)likeKey;

-(void)clear;

-(void)clearExpireDBItems;

@end
