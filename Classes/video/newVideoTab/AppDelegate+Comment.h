//
//  AppDelegate+Comment.h
//  iPhoneVideo
//
//  Created by LHL on 15/12/14.
//  Copyright © 2015年 SOHU. All rights reserved.
//

#import <SVVideoForNews/SVVideoForNews.h>
#import <objc/runtime.h>

@interface sohunewsAppDelegate (Comment)<SHVideoCommentProtocol>

@property (nonatomic, copy)   CommentGetCommpletionBlock commentGetCommpletionBlock;
@property (nonatomic, copy)   CommentPostCommpletionBlock commentPostCommpletionBlock;
@property (nonatomic, copy)   CommentGetFailtureBlock commentGetFailtureBlock;
@property (nonatomic, copy)   CommentPostFailtureBlock commentPostFailtureBlock;

@property (nonatomic, assign) NSInteger commentCurrentPage;

@end
