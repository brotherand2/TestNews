//
//  SNHotPhotoModel.h
//  sohunews
//
//  Created by ivan on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import "SNNewsModel.h"
#import "SNURLRequest.h"

@interface SNPhotoModel : SNNewsModel {
    NSMutableArray *hotPhotos;
    NSMutableArray *allPhotos;
    SNURLRequest *_request;
    BOOL _more;
	
    BOOL localPage;
    
    int _page;
    int pageWhenViewReleased;
    NSString *timelineWhenViewReleased;
    
    BOOL isFirst;
    BOOL isQueryTargetChanged;
    
    
    NSString *targetType;
    NSString *typeId;
    
    NSString *offSet;
    NSString *lastOffset;
    BOOL firstAndNoCache;
    int _minTimelineIndex;
}

@property(nonatomic,strong)NSMutableArray *hotPhotos;
@property(nonatomic,strong)NSMutableArray *allPhotos;
@property(nonatomic,readwrite)BOOL isFirst;
@property(nonatomic,readwrite)BOOL firstAndNoCache;

@property(nonatomic,readwrite)BOOL isQueryTargetChanged;
@property(nonatomic,copy)NSString *targetType;
@property(nonatomic,copy)NSString *typeId;
@property(nonatomic,readwrite)BOOL more;
@property(nonatomic,readwrite)int page;
@property(nonatomic,readwrite)int pageWhenViewReleased;
@property(nonatomic,copy)NSString *offSet;
@property(nonatomic,copy)NSString *lastOffset;
@property(nonatomic,copy)NSString *timelineWhenViewReleased;

- (void)cancelAllRequest;
- (void)requestDidFinishLoadWithResponse:(id)rootData;
@end
