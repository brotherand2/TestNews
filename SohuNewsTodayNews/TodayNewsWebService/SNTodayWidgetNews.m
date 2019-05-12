//
//  SNTodayWidgetNews.m
//  WidgetApp
//
//  Created by WongHandy on 8/4/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import "SNTodayWidgetNews.h"

@implementation SNTodayWidgetNews

- (id)initWithData:(id)data {
    if (self = [super init]) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *articleDic = (NSDictionary *)data;
            int newsType = [articleDic[@"newsType"] intValue];
            if (newsType == 21 || newsType == 18 || newsType == 23) {
                return nil;
            }
            else {
                //link2
                NSString *link2 = nil;
                id link2Data = articleDic[@"link"];
                if ([link2Data isKindOfClass:[NSString class]]) {
                    link2 = (NSString *)link2Data;
                }
                //---pic url
                NSArray *imgURLArray = nil;
                id picsData = articleDic[@"pics"];
                if ([picsData isKindOfClass:[NSArray class]]) {
                    imgURLArray = (NSArray *)picsData;
                }
                //---groupPhotoCount
                NSString *groupPhotoCount = @"0";
                id groupPhotoCountData = articleDic[@"listPicsNumber"];
                if ([groupPhotoCountData isKindOfClass:[NSNumber class]]) {
                    groupPhotoCount = [NSString stringWithFormat:@"%ld", (long)[((NSNumber *)groupPhotoCountData) integerValue]];
                }
                //---title
                NSString *title = nil;
                id titleData = articleDic[@"title"];
                if ([titleData isKindOfClass:[NSString class]]) {
                    title = (NSString *)titleData;
                }
                //---commentCount
                NSString *commentCount = @"0";
                id commentCountData = articleDic[@"commentNum"];
                if ([commentCountData isKindOfClass:[NSNumber class]]) {
                    commentCount = [NSString stringWithFormat:@"%ld", (long)[((NSNumber *)commentCountData) integerValue]];
                }
                
                _link2 = [link2 copy];
                _title = [title copy];
                _imgURLArray = [imgURLArray copy];
                _groupPhotoCount = [groupPhotoCount copy];
                _commentCount = [commentCount copy];
            }
        }
    }
    return self;
}

- (NSString *)title {
    return _title.length > 0 ? _title : @"";
}

- (NSString *)groupPhotoCount {
    return _groupPhotoCount.length > 0 ? _groupPhotoCount : @"0";
}

- (NSString *)imgURLs {
    if (_imgURLArray.count > 0) {
        return [_imgURLArray componentsJoinedByString:@","];
    }
    else {
        return @"";
    }
}

- (NSString *)commentCount {
    return _commentCount.length > 0 ? _commentCount : @"0";
}

- (NSString *)description {
    NSDictionary *desc = @{@"title":self.title, @"imgURLs":[self imgURLs], @"commentCount":self.commentCount};
    return [desc description];
}

@end