//
//  SNEmoticonObject.m
//  sohunews
//
//  Created by jialei on 14-5-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNEmoticonObject.h"

static NSString *const SNEmoticonPlistKeyCHName = @"chi";
static NSString *const SNEmoticonPlistKeyENName = @"eng";
static NSString *const SNEmoticonPlistKeyPNGName = @"png";
static NSString *const SNEmoticonPlistKeyDescription = @"des";

@implementation SNEmoticonConfig

- (void)dealloc
{
     //(_emoticonClassName);
     //(_emoticonPlistName);
     //(_emoticonType);
    
}

@end

@implementation SNEmoticonObject
@synthesize description=_description;
+ (NSMutableArray *)objectsWithJSONArray:(NSArray *)array
{
	if (array == nil || ![array isKindOfClass:[NSArray class]]) {
		return [NSMutableArray array];
	}
	
	NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[array count]];
	
	for (NSDictionary *dict in array) {
        SNEmoticonObject *object = [[self alloc] initWithJSONDictionary:dict];
        
        if (object) {
            [objects addObject:object];
        }
         //(object);
	}
	
	return objects;
}

- (SNEmoticonObject *)initWithJSONDictionary:(NSDictionary *)dic
{
    if (dic == nil || ![dic isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
    
    if (self = [super init]) {
        self.chineseName = dic[SNEmoticonPlistKeyCHName];
        self.englishName = dic[SNEmoticonPlistKeyENName];
        self.pngName     = dic[SNEmoticonPlistKeyPNGName];
        self.description = dic[SNEmoticonPlistKeyDescription];
        if (self.description.length > 0) {
            self.type = SNEmoticonDynamic;
        }
        else {
            self.type = SNEmoticonStatic;
        }
    }
    return self;
}

- (void)dealloc
{
     //(_chineseName);
     //(_englishName);
     //(_pngName);
     //(_description);

}

- (UIImage *)emoticonImage
{
    if (!_pngName) {
        return nil;
    }
    
    return [UIImage imageNamed:_pngName];
}

@end
