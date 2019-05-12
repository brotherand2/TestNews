//
//  JKJsKitCoreApi.h
//  sohunews
//
//  Created by sevenshal on 16/3/29.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKJsKitCoreApi : NSObject

-(void)setMemoryItem:(id)val forKey:(NSString*)key;

-(id)memoryItemForKey:(NSString*)key;

@end
