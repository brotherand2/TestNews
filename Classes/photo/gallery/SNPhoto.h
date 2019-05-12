//
//  SNPhoto.h
//  sohunews
//
//  Created by Dan on 6/23/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

//图片新闻
@interface SNPhoto : NSObject <TTPhoto> {
	
	id<TTPhotoSource> _photoSource;
	NSString *title;
	NSString *url;  //图所在的URL
	NSString *info; //摘要（简介）
	NSString *link; //分享用的链接
	CGSize    _size;
	NSInteger _index;
	
    NSString *_termId;
    NSString *_newsId;
}

@property(nonatomic, retain)NSString *url;
@property(nonatomic, retain)NSString *serverUrl; // 图片在服务器上的url
@property(nonatomic, retain)NSString *info;
@property(nonatomic, retain)NSString *link;
@property(nonatomic, retain)NSString *termId;
@property(nonatomic, retain)NSString *newsId;
@property(nonatomic, assign)id<TTPhotoSource> photoSource;
@end
