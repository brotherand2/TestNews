//
//  SNComposeCommentController.h
//  sohunews
//
//  Created by Dan on 6/16/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SNPostController.h"

@protocol SNPostCommentControllerDelegate;
@class NewsCommentItem;
@class SNNewsComment;
//@class ASIFormDataRequest;
@class SNSendCommentObject;

@interface SNPostCommentService : NSObject {
//    ASIFormDataRequest *_postCommentRequest;
	int _refer; // 统计评论来源
}
@property (nonatomic, strong) SNSendCommentObject * commentObj;
//@property (strong, nonatomic) NSOperationQueue *postCommentQueue;
@property (nonatomic, copy)NSString *newsLink;

+ (SNPostCommentService *)shareInstance;
- (void)saveCommentToServer:(SNSendCommentObject *)cmtObj;

@end

@protocol SNPostCommentControllerDelegate <NSObject>

@optional
-(void)commentDidPost:(NewsCommentItem *)newsCommentItem;
-(void)postCommentSucccess;
-(void)postCommentFailure;
@end

