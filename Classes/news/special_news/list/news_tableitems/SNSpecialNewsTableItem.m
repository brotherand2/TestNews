//
//  SNSpecialNewsTableItem.m
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNewsTableItem.h"

@interface SNSpecialNewsTableItem()

- (void)fillDataToTableItem;

@end


@implementation SNSpecialNewsTableItem

@synthesize termId = _termId;
@synthesize news = _news;
@synthesize excludePhotoNewsIds = _excludePhotoNewsIds;
@synthesize photoNewsIds = _photoNewsIds;
@synthesize allNews = _allNews;
@synthesize cellHeight;
@synthesize type = _type;
@synthesize snModel = _snModel;
@synthesize dataSource = _dataSource;

#pragma mark - Lifecycle methods

- (void)setNews:(SNSpecialNews *)newsParam {
	if (_news != newsParam) {
		 //(_news);
		_news = newsParam;
        
		[self fillDataToTableItem];
	} 
}

- (void)dealloc {
    _news = nil;
    
    
    
    
    
    
}

#pragma mark - Public methods implementations

#pragma mark - Override

- (NSString *)description {
    NSMutableString *_desc = [NSMutableString string];
    [_desc appendFormat:SN_String("text:%@ | subtitle:%@ | %@"), self.text, self.subtitle, [self.news description]];
    return _desc;
}


#pragma mark - Private methods implementation

- (void)fillDataToTableItem {
    self.text = _news.title;
    self.subtitle = _news.abstract;
    
    if (_news.pic && ![@"" isEqualToString:_news.pic]) {
        self.imageURL = _news.pic;
    }
}

@end
