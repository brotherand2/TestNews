//
//  SNSpecialNews.m
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNews.h"

@implementation SNSpecialNews

@synthesize ID = _ID;
@synthesize newsId = _newsId;
@synthesize termName = _termName;
@synthesize newsType = _newsType;
@synthesize title = _title;
@synthesize pic = _pic;
@synthesize picArray = _picArray;
@synthesize abstract = _abstract;
@synthesize isFocusDisp = _isFocusDisp;
@synthesize link = _link;
@synthesize isRead = _isRead;
@synthesize termId = _termId;
@synthesize form = _form;
@synthesize groupName = _groupName;
@synthesize hasVideo = _hasVideo;
@synthesize updateTime = _updateTime;
@synthesize expired = _expired;
@synthesize createAt;
@synthesize isDownloadFinished;
@synthesize type = _type;

- (id)copyWithZone:(NSZone *)zone {
    
	SNSpecialNews *_newObj = [[SNSpecialNews alloc] init];
    
    _newObj.ID          = self.ID;
    _newObj.termId      = self.termId;
    _newObj.termName    = self.termName;
    _newObj.newsId      = self.newsId;
    _newObj.newsType    = self.newsType;
    _newObj.title       = self.title;
    _newObj.pic         = self.pic;
    _newObj.picArray    = self.picArray;
    _newObj.abstract    = self.abstract;
    _newObj.isFocusDisp = self.isFocusDisp;
    _newObj.link        = self.link;
    _newObj.isRead      = self.isRead;
    _newObj.form        = self.form;
    _newObj.groupName   = self.groupName;
    _newObj.updateTime  = self.updateTime;
    _newObj.expired     = self.expired;
    _newObj.type        = self.type;
    
	return _newObj;
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    SNSpecialNews *so = (SNSpecialNews *)object;
    return ([self.termId isEqualToString:so.termId] && [self.newsId isEqualToString:so.newsId]);
}

- (NSUInteger)hash {
    NSString *idstr = [self.termId stringByAppendingFormat:@"_%@", self.newsId];
    return [idstr hash];
}

- (NSString *)description {
    NSMutableString *_desc = [NSMutableString string];
    
    [_desc appendFormat:SN_String("ID:%d | termId:%@ | termName:%@ | newsId:%@ | newsType:%@ | title:%@ | pic:%@ | picArray:%@ | abstract:%@ | isFocusDisp:%@ | link:%@ | isRead:%@ | form:%@ | groupName:%@ | updateTime:%@ | expired:%@"),
    self.ID, self.termId, self.termName, self.newsId, self.newsType, self.title, self.pic, self.picArray, self.abstract, self.isFocusDisp, self.link, self.isRead, self.form, self.groupName, self.updateTime, self.expired];
    
    return _desc;
}


- (void)dealloc {
    
    
    
    
    
    
    
    
    
    
    
    
    
     //(_hasVideo);
    
     //(_updateTime);
    
     //(_expired);

}

@end
