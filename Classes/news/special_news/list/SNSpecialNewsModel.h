//
//  SNSpecialNewsModel.h
//  sohunews
//
//  Created by handy wang on 7/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDragRefreshURLRequestModel.h"

@interface SNSpecialNewsModel : SNDragRefreshURLRequestModel {
    NSString *_termId;
    NSString *_pubId;
    NSString *_termName;
    NSString *_shareContent;
    
    NSMutableArray *_headlineNews;
    
    NSMutableArray *_listNews;
    
    NSMutableArray *_tmpNewsGroupNames;
    NSMutableArray *_newsGroupNames;
    
    SNURLRequest *_snRequest;
}

@property(nonatomic, copy)NSString *termId;
@property(nonatomic, copy)NSString *pubId;
@property(nonatomic, copy)NSString *termName;
@property(nonatomic, copy)NSString *shareContent;

@property(nonatomic, strong)NSMutableArray *headlineNews;
@property(nonatomic, strong)NSMutableArray *listNews;
@property(nonatomic, strong)NSMutableArray *newsGroupNames;

- (id)initWithTermId:(NSString *)termIdParam;
- (void)setNewsAsRead:(NSString *)newsId;
@end
