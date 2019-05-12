//
//  SNDingManager.h
//  sohunews
//
//  Created by lhp on 7/24/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNDingManager : NSObject{
    
    NSMutableDictionary *dingCommentsDic;
}

+ (SNDingManager *)sharedInstance;
- (void)addCommentId:(NSString *) commentId;
- (BOOL)isDingForCommentId:(NSString *) commentId;

@end
