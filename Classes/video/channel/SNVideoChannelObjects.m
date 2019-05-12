//
//  SNVideoChannelObjects.m
//  sohunews
//
//  Created by jojo on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelObjects.h"
#import "NSDictionaryExtend.h"

@implementation SNVideoHotChannelCategoriSectionObj
@synthesize categoryId = _categoryId;
@synthesize categoryType = _categoryType;
@synthesize categoryStatus = _categoryStatus;
@synthesize sort = _sort;
@synthesize categoryTitle = _categoryTitle;
@synthesize categories = _categories;
@synthesize utime = _utime, ctime = _ctime;
@synthesize descn = _descn;
@synthesize textAlignment;

+ (SNVideoHotChannelCategoriSectionObj *)sectionObjWithDataObject:(id)obj {
    SNVideoHotChannelCategoriSectionObj *aSectionObj = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dicInfo = obj;
        aSectionObj = [[SNVideoHotChannelCategoriSectionObj alloc] init];
        aSectionObj.categoryId = [dicInfo stringValueForKey:@"id" defaultValue:nil];
        aSectionObj.categoryType = [dicInfo stringValueForKey:@"type" defaultValue:nil];
        aSectionObj.categoryStatus = [dicInfo stringValueForKey:@"status" defaultValue:nil];
        aSectionObj.sort = [dicInfo stringValueForKey:@"sort" defaultValue:nil];
        aSectionObj.categoryTitle = [dicInfo stringValueForKey:@"title" defaultValue:nil];
        aSectionObj.ctime = [dicInfo stringValueForKey:@"ctime" defaultValue:nil];
        aSectionObj.utime = [dicInfo stringValueForKey:@"utime" defaultValue:nil];
        aSectionObj.descn = [dicInfo stringValueForKey:@"descn" defaultValue:nil];
        NSArray *columns = [dicInfo arrayValueForKey:@"columns" defaultValue:nil];
        if (columns) {
            [aSectionObj parseSectionObjs:columns];
        }
    }
    return aSectionObj;
}

- (void)dealloc {
     //(_categoryId);
     //(_categoryType);
     //(_categoryStatus);
     //(_sort);
     //(_categoryTitle);
     //(_categories);
     //(_utime);
     //(_ctime);
     //(_descn);
}

- (NSMutableArray *)categories {
    if (!_categories) {
        _categories = [[NSMutableArray alloc] init];
    }
    return _categories;
}

- (void)parseSectionObjs:(NSArray *)sectionObjs {
    [self.categories removeAllObjects];
    for (id obj in sectionObjs) {
        SNVideoChannelCategoryObject *cgObj = [SNVideoChannelCategoryObject categoryObjFromDataObj:obj];
        if (cgObj) {
            [self.categories addObject:cgObj];
        }
    }
}

@end

#pragma mark -

@implementation SNVideoChannelCategoryObjectAuthor
@synthesize name = _name;
@synthesize ID = _ID;
@synthesize type = _type;
@synthesize icon = _icon;

+ (SNVideoChannelCategoryObjectAuthor *)authorObjFromDataInfo:(NSDictionary *)infoDic {
    SNVideoChannelCategoryObjectAuthor *anAuthor = nil;
    if (infoDic && [infoDic isKindOfClass:[NSDictionary class]]) {
        anAuthor = [[SNVideoChannelCategoryObjectAuthor alloc] init];
        anAuthor.name = [infoDic stringValueForKey:@"name" defaultValue:nil];
        anAuthor.ID = [infoDic stringValueForKey:@"id" defaultValue:nil];
        anAuthor.type = [infoDic stringValueForKey:@"type" defaultValue:nil];
        anAuthor.icon = [infoDic stringValueForKey:@"icon" defaultValue:nil];
    }
    return anAuthor;
}

- (void)dealloc {
     //(_name);
     //(_ID);
     //(_type);
     //(_icon);
}

@end

@implementation SNVideoChannelCategoryObject
@synthesize type = _type;
@synthesize owner = _owner;
@synthesize title = _title;
@synthesize categoryId = _categoryId;
@synthesize status = _status;
@synthesize ctime = _ctime;
@synthesize utime = _utime;
@synthesize binding = _binding;
@synthesize sub = _sub;
@synthesize author = _author;

- (void)dealloc {
     //(_type);
     //(_owner);
     //(_title);
     //(_categoryId);
     //(_status);
     //(_ctime);
     //(_utime);
     //(_binding);
     //(_sub);
     //(_author);
}

+ (SNVideoChannelCategoryObject *)categoryObjFromDataObj:(id)obj {
    SNVideoChannelCategoryObject *aCGObj = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDic = obj;
        aCGObj = [SNVideoChannelCategoryObject new];
        aCGObj.type = [jsonDic stringValueForKey:@"type" defaultValue:nil];
        aCGObj.owner = [jsonDic stringValueForKey:@"owner" defaultValue:nil];
        aCGObj.title = [jsonDic stringValueForKey:@"title" defaultValue:nil];
        aCGObj.categoryId = [jsonDic stringValueForKey:@"id" defaultValue:nil];
        aCGObj.status = [jsonDic stringValueForKey:@"status" defaultValue:nil];
        aCGObj.ctime = [jsonDic stringValueForKey:@"ctime" defaultValue:nil];
        aCGObj.utime = [jsonDic stringValueForKey:@"utime" defaultValue:nil];
        aCGObj.binding = [jsonDic stringValueForKey:@"binding" defaultValue:nil];
        aCGObj.sub = [jsonDic stringValueForKey:@"sub" defaultValue:nil];
        NSDictionary *authorDic = [jsonDic dictionaryValueForKey:@"author" defalutValue:nil];
        aCGObj.author = [SNVideoChannelCategoryObjectAuthor authorObjFromDataInfo:authorDic];
    }
    return aCGObj;
}

- (SNVideoColumnCacheObj *)toVideoColumnObj {
    SNVideoColumnCacheObj *cacheObj = [[SNVideoColumnCacheObj alloc] init];
    cacheObj.columnId = self.categoryId;
    cacheObj.columnTitle = self.title;
    cacheObj.isSubed = self.sub;
    return cacheObj;
}

@end

@implementation SNVideoColumnCacheObj

- (id)init {
    self = [super init];
    if (self) {
        self.columnId = @"";
        self.columnTitle = @"";
        self.isSubed = @"0";
    }
    return self;
}

- (void)dealloc {
     //(_columnId);
     //(_columnTitle);
     //(_isSubed);
     //(_readCount);
}

@end

#pragma mark - 

@implementation SNVideoChannelObject

+ (SNVideoChannelObject *)chennelObjectFromDataObj:(id)obj {
    SNVideoChannelObject *aChannelObj = nil;
    // parse json dic
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDic = (NSDictionary *)obj;
        aChannelObj = [[SNVideoChannelObject alloc] init];
        aChannelObj.channelId = [jsonDic stringValueForKey:@"id" defaultValue:nil];
        aChannelObj.descn = [jsonDic stringValueForKey:@"descn" defaultValue:nil];
        aChannelObj.title = [jsonDic stringValueForKey:@"title" defaultValue:nil];
        aChannelObj.status = [jsonDic stringValueForKey:@"status" defaultValue:nil];
        aChannelObj.sort = [jsonDic stringValueForKey:@"sort" defaultValue:nil];
        aChannelObj.ctime = [jsonDic stringValueForKey:@"ctime" defaultValue:nil];
        aChannelObj.utime = [jsonDic stringValueForKey:@"utime" defaultValue:nil];
        aChannelObj.sortable = [jsonDic stringValueForKey:@"changeable" defaultValue:nil];
        aChannelObj.up = [jsonDic stringValueForKey:@"up" defaultValue:nil];
    }
    return aChannelObj;
}

- (void)dealloc {
     //(_sort);
     //(_status);
     //(_title);
     //(_descn);
     //(_channelId);
     //(_ctime);
     //(_utime);
     //(_sortable);
     //(_up);
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [[(SNVideoChannelObject *)object channelId] isEqualToString:self.channelId] &&
            [[(SNVideoChannelObject *)object title] isEqualToString:self.title];
}

- (NSUInteger)hash {
    return [self.channelId integerValue];
}

- (NSString *)json {
    return [NSString stringWithFormat:@"{\"id\":%@,\"sort\":%@,\"up\":%@}", _channelId, _sort, _up];
}

@end
