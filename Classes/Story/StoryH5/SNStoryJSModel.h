//
//  SNStoryJSModel.h
//  sohunews
//
//  Created by iOS_D on 2016/11/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNStoryWebViewController.h"
//#import "JsKitFramework.h"
//wangshun
#import <JsKitFramework/JsKitFramework.h>
#import "SHHomePageArticleViewJSModel.h"

//@interface SNStoryJSModel : NSObject 
@interface SNStoryJSModel : SHHomePageArticleViewJSModel

@property (nonatomic,weak) SNStoryWebViewController* storyVC;
@property (nonatomic,strong) NSMutableDictionary* queryDict;

- (void)jsInterface_jsCallCopy:(JsKitClient *)client jsonObject:(NSString *)content;
- (void)jsInterface_gotoCommentSofa:(JsKitClient *)client;
- (void)jsInterface_showLoadingView:(JsKitClient *)client isLoading:(BOOL)isLoading;

//运营标签H5要使用，重写该方法，直接调用父类
- (void)jsInterface_showTitle:(JsKitClient *)client show:(NSNumber *)show title:(NSString *)title;
- (void)jsInterface_showShareBtn:(JsKitClient *)client show:(NSNumber *)show;
/**
 *  通用浏览器 newsApi.showMaskView(false) 控制蒙层
 */
- (void)jsInterface_showMaskView:(JsKitClient *)client close:(NSNumber *)close;
@end
