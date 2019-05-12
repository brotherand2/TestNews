//
//  SNCommonNewsController.h
//  sohunews
//
//  Created by Diaochunmeng on 13-2-25.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//即时新闻是否通过push的方式进入下一条，没有此宏，则原地刷新
#define COMMON_NEWS_PUSH_INTO_NEXT

@class SNNewsContentController;
@class SNLiveContentViewController;
@class SNWebController;

@interface SNNewsInfo : NSObject
@property (nonatomic, assign) BOOL parseable;
@property (nonatomic, copy) NSString *trainID;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *isWeather;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *updateTime;
@end


@class SNNewsPaperWebController;
@class SNWeiboDetailViewController;
@class SNRollingNewsTableController;
@interface SNCommonNewsController : TTBaseViewController
{
    NSURL* _URL;
    NSDictionary* _queryAll;
    UIViewController* _currentController;

    NSMutableArray* _rollingNewsListAll;
    NSMutableArray* _specialRollingNewsListAll;
}

@property(nonatomic, strong)NSURL* URL;
@property(nonatomic, strong)NSDictionary* queryAll;
@property(nonatomic, strong)UIViewController* currentController;

@property(nonatomic, strong)NSMutableArray* rollingNewsListAll;
@property(nonatomic, strong)NSMutableArray* specialRollingNewsListAll;
@property(nonatomic, weak)SNNewsPaperWebController* newsPaper;

@property (nonatomic, strong)__block SNRollingNewsTableController *sourceVC;

- (id)initWithParams:(NSDictionary *)dict URL:(NSURL*)URL;
-(NSString*)getTitleById:(NSString*)aNewsId;
-(BOOL)swithController:(NSString*)aNewsId type:(NSNumber*)aType; //在即时新闻里右滑
-(BOOL)swithControllerInNewsPaper:(NSString*)aNextNewsLink current:(id)aCurrent; //在报纸里右滑
-(BOOL)swithControllerInRecommand:(NSString*)aNewsId; //推荐页右滑
-(BOOL)swithControllerInPhotoRecommand:(NSString*)aNewsId; //推荐页右滑
+(BOOL)supportContinuation:(NSString*)aType; //判断是否支持连续阅读
+(BOOL)supportContinuationInSpecial:(NSString*)aType; //判断专题里是否支持连续阅读
@end
