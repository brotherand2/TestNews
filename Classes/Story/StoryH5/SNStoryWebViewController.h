//
//  SNStoryWebViewController.h
//  sohunews
//
//  Created by chuanwenwang on 16/10/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNStoryWebViewController : SNBaseViewController

- (void)shareContent:(NSString *)content;
- (void)copyComment:(NSString*)content;
- (void)replyComment:(NSDictionary *)comment;
- (void)enterUserCenter:(NSMutableDictionary *)dic;
- (void)setCommentNum:(NSString *)count;
- (void)emptyCommentListClicked;
@end
