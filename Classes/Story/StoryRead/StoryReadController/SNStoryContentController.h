//
//  SNStoryContentController.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/9/29.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBookMarkView.h"
#import "SNStoryPage.h"

@class SNStoryContentController;
@class SNStoryContentLabel;
@class SNStoryPageViewController;

@protocol SNStoryContentControllerProtocol <NSObject>

- (void)didRequestFinshed;
- (void)willRequest;
@end

@interface SNStoryContentController : UIViewController
@property (nonatomic, weak)     id<SNStoryContentControllerProtocol>delegate;
@property (nonatomic, strong)   SNBookMarkView * bookMark;
@property (nonatomic, copy)     NSString *content;
@property (nonatomic, assign)   StoryPageType chapterType;
@property (nonatomic, assign)   StoryScrollType storyScrollType;//初始页 向前翻页 向后翻页
@property (nonatomic, assign)   NSUInteger pageNum;//页码
@property (nonatomic, strong)   SNStoryContentLabel *chapterContentLabel;//章节内容
@property (nonatomic, assign)   NSInteger chapterIndex;//章节索引
@property (nonatomic, strong)   NSString *novelId;//小说id
@property (nonatomic, strong)   UIFont *cur_font;
@property (nonatomic, weak)SNStoryPageViewController *pageViewController;
//@property (nonatomic, assign)BOOL isTransitionAnimation;//是否是翻转动画

- (void)autoPurchase;
- (BOOL)canPurchase;
- (void)loginSuccess;
-(void)novelContentWithIsrefresh:(BOOL)isRefresh;
-(void)refreshRequestWithDic:(NSDictionary *)dic;
@end
