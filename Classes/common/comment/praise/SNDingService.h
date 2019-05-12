//
//  SNDingService.h
//  sohunews
//
//  Created by qi pei on 6/28/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@protocol SNDingServiceDelegate <NSObject>

-(void)didFinishDingComment;

@end

typedef enum {
    SNCommentDingTypeMenu,
    SNCommentDingTypeImage,
}SNCommentDingType;

@interface SNDingService : SNDefaultParamsRequest

@property(nonatomic, weak)id<SNDingServiceDelegate> delegate;

-(void)asyncDingComment:(NSString *)commentId topicId:(NSString *)topicId;

-(void)cancel;

@end
