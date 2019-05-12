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
	
	id<TTPhotoSource> __weak _photoSource;
	NSString *title;
	NSString *url;  //图所在的URL
	NSString *info; //摘要（简介）
	NSString *link; //分享用的链接
	CGSize    _size;
	NSInteger _index;
	
    NSString *_termId;
    NSString *_newsId;
}

@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *serverUrl; // 图片在服务器上的url
@property(nonatomic, strong)NSString *info;
@property(nonatomic, strong)NSString *link;
@property(nonatomic, strong)NSString *termId;
@property(nonatomic, strong)NSString *newsId;
@property(nonatomic, weak)id<TTPhotoSource> photoSource;

@end
