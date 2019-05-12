//
//  SNTodayWidgetNews.h
//  WidgetApp
//
//  Created by WongHandy on 8/4/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTodayWidgetNews : NSObject
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *link2;
@property(nonatomic, copy) NSArray *imgURLArray;
@property(nonatomic, copy) NSString *groupPhotoCount;
@property(nonatomic, copy) NSString *commentCount;

- (id)initWithData:(id)data;
- (NSString *)imgURLs;
@end