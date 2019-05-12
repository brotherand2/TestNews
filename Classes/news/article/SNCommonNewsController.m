//
//  SNCommonNewsController
//  sohunews
//
//  Created by Diaochunmeng on 13-2-25.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

//#import "SNConsts.h"
#import "SNCommonNewsController.h"
#import "SNRollingNewsTableItem.h"
#import "SNRollingNewsHeadlineItem.h"

#import "SNPromotionTableItem.h"
#import "SNSpecialHeadlineNewsTableCell.h"
#import "SNSpecialNewsTableItem.h"
#import "SNNewsPaperWebController.h"
#import "SNRollingNewsViewController.h"
#import "SNNewsListViewController.h"
#import "SNNewsPaperWebController.h"

#import "SNH5WebController.h"
#import "WSMVSlider.h"
#import "SNRollingNewsPublicManager.h"
#import "SNJSKitWebViewController.h"
#import "SHH5NewsWebViewController.h"

const CGFloat delayTime = 0.5f;

@interface SNCommonNewsController ()
{
    NSString *_statusbarStyle;
}
@end
@implementation SNNewsInfo
@synthesize id = _id;
@synthesize title = _title;
@synthesize type = _type;
@synthesize parseable = _parseable;
@synthesize key = _key;
@synthesize isWeather = _isWeather;

@end

@interface SNCommonNewsController()
-(BOOL)getParseableFromtype:(NSInteger)type;
-(BOOL)specailControllerWithDic:(NSDictionary*)query url:(NSURL*)URL type:(NSString*)aType;
-(BOOL)weiboControllerWithDic:(NSDictionary*)query url:(NSURL*)URL type:(NSString*)aType;
@end

@implementation SNCommonNewsController
@synthesize URL = _URL;
@synthesize currentController = _currentController;
@synthesize queryAll = _queryAll;
@synthesize rollingNewsListAll = _rollingNewsListAll;
@synthesize specialRollingNewsListAll = _specialRollingNewsListAll;

- (SNCCPVPage)currentPage {
    return [self.currentController currentPage];
}

- (NSString *)currentOpenLink2Url {
    return [self.currentController currentOpenLink2Url];
}

-(void)dealloc
{
    self.newsPaper = nil;
    [SNNotificationManager removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)loadView
{
    [super loadView];
    
    if(_queryAll!=nil && _URL!=nil)
    {
        self.newsPaper = [_queryAll objectForKey:kNewsPaperPtr];
        self.rollingNewsListAll = [_queryAll objectForKey:kNewsListAll];
        self.specialRollingNewsListAll = [_queryAll objectForKey:kSpecailNewsListAll];
        
        [self h5PhotoNewsWebViewControllerDic:[_queryAll objectForKey:kContinuityPhoto] url:_URL type:[_queryAll objectForKey:kContinuityType] newsfrome:[_queryAll objectForKey:kNewsFrom]];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[_queryAll objectForKey:kContinuityNews]];
        if ([_queryAll objectForKey:kClickOpenNews]) {
            [dict setObject:[_queryAll objectForKey:kClickOpenNews] forKey:kClickOpenNews];
        }
        if ([_queryAll objectForKey:kRecomInfo]) {
            [dict setObject:[_queryAll objectForKey:kRecomInfo] forKey:kRecomInfo];
        }
        [self h5NewsWebViewControllerDic:dict url:_URL type:[_queryAll objectForKey:kContinuityType] newsfrome:[_queryAll objectForKey:kNewsFrom]];

        [self specailControllerWithDic:[_queryAll objectForKey:kContinuitySpecial] url:_URL type:[_queryAll objectForKey:kContinuityType] newsfrom:[_queryAll objectForKey:kNewsFrom]];
    }
    [SNNotificationManager addObserver:self selector:@selector(updateStatusbarStyle:) name:kStatusBarStyleChangedNotification object:nil];
}

-(void)viewDidUnload
{
    [SNNotificationManager removeObserver:self name:kStatusBarStyleChangedNotification object:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.currentController viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [self.currentController viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.currentController viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.currentController viewDidDisappear:animated];
}

#pragma mark set status bar

- (void)updateStatusbarStyle:(NSNotification *)note
{
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if (![themeManager.currentTheme isEqualToString:@"night"])
    {
        _statusbarStyle = [note object][@"style"];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

//Only works for iOS7 and greater.
- (UIViewController *)subChildViewControllerForStatusBarStyle {
    return self;
}

//Only works for iOS7 and greater.
- (UIStatusBarStyle)preferredStatusBarStyle
{
    SNThemeManager *themeManager = [SNThemeManager sharedThemeManager];
    if ([themeManager.currentTheme isEqualToString:@"night"])
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        if (_statusbarStyle && [_statusbarStyle isEqualToString:@"lightContent"])
        {
            return UIStatusBarStyleLightContent;
        }
        else
        {
            return UIStatusBarStyleDefault;
        }
    }
}

-(BOOL)prefersStatusBarHidden
{
//    if ([_currentController isKindOfClass:[SHH5NewsWebViewController class]]) {
//        return ((SHH5NewsWebViewController *)_currentController).needsHideStatusBar;
//    }
    return NO;
}

- (BOOL)h5PhotoNewsWebViewControllerDic:(NSDictionary *)query url:(NSURL *)URL type:(NSString *)aType newsfrome:(NSString *)newsfrom
{
    if (aType != nil && ([aType isEqualToString:kContinuityPhoto]))
    {
        SHH5NewsWebViewController * h5content = [[SHH5NewsWebViewController alloc] initWithNavigatorURL:URL query:query];
        h5content.commonNewsController = self;
        h5content.queryAll = self.queryAll;
        h5content.newsfrom = newsfrom;
        if (h5content.view.frame.origin.y > 0) {
            [h5content.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }
        [self.view addSubview:h5content.view];
        self.currentController = h5content;
        return YES;
    } else
        return NO;
}

- (BOOL)h5NewsWebViewControllerDic:(NSDictionary *)query url:(NSURL *)URL type:(NSString *)aType newsfrome:(NSString *)newsfrom
{
    if (aType != nil && ([aType isEqualToString:kContinuityNews]))
    {
        SHH5NewsWebViewController * h5content = [[SHH5NewsWebViewController alloc] initWithNavigatorURL:URL query:query];
        h5content.commonNewsController = self;
        h5content.queryAll = self.queryAll;
        h5content.newsfrom = newsfrom;
        if (h5content.view.frame.origin.y > 0) {
            [h5content.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }
        [self.view addSubview:h5content.view];
        self.currentController = h5content;
        return YES;
    } else
        return NO;
}

-(BOOL)specailControllerWithDic:(NSDictionary*)query url:(NSURL*)URL type:(NSString*)aType newsfrom:(NSString *)newsfrom
{
    if(aType!=nil && [aType isEqualToString:kContinuitySpecial])
    {
        NSMutableDictionary *muQuery = [NSMutableDictionary dictionaryWithDictionary:query];
        [muQuery setObject:[NSNumber numberWithInteger:SpecialWebViewType] forKey:kUniversalWebViewType];
        SNJSKitWebViewController *webController = [[SNJSKitWebViewController alloc] initWithNavigatorURL:URL query:muQuery];
        webController.newsfrom = newsfrom;
        [self.view addSubview:webController.view];
        self.currentController = webController;
                
        return YES;
    }
    else
        return NO;
}

-(id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query
{
    self = [super init];
    if(self)
    {
        self.URL = URL;
        self.queryAll = query;
    }
    return self;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)p_switchTrainView:(NSDictionary *)dic {
    //正文页结束时, 如果火车连续阅读需要通知频道流火车卡片做相应滑动
    NSString *_trainID = [dic valueForKey:kTrainId] ? : @"";
    if (_trainID.length > 0) {
        NSString *_channelID = [dic valueForKey:kChannelId] ? : @"";
        NSString *_newsID = [dic valueForKey:kNewsId] ? : @"";
        NSString *_trainIndex = [dic valueForKey:kTrainIndex] ? : @"";
        NSDictionary *dic = @{kChannelId : _channelID, kNewsId : _newsID, kTrainIndex : _trainIndex, kTrainId : _trainID
                              };
        [SNNotificationManager postNotificationName:kRollingNewsTrainViewPositionChangedNotification object:nil userInfo:dic];
    }
}

- (BOOL)swithControllerRolling:(NSString *)aNewsId
                          type:(NSNumber *)aType {
    NSInteger i = 0;
    SNNewsInfo *infoCurrent = nil;
    BOOL findNews = NO;
    
    BOOL isTrainCard = NO;
    NSArray *newsList = _rollingNewsListAll;
    for(; i < [newsList count]; i++) {
        @autoreleasepool {
            id itemObj = [newsList objectAtIndex:i];
            SNNewsInfo *info = [self getInfoFromObject:itemObj];
            
            if ([itemObj isKindOfClass:[SNRollingNewsTableItem class]]) {
                SNRollingNewsTableItem *item = (SNRollingNewsTableItem *)itemObj;
                //全屏焦点图和文字新闻
                if (item.cellType ==
                    SNRollingNewsCellTypeFullScreenFocus) {
                    for (SNRollingNews *news in item.news.newsItemArray) {
                        if ([news.newsId isEqualToString:aNewsId]) {
                            infoCurrent = info;
                            findNews = YES;
                            break;
                        }
                    }

                    if (!findNews) {
                        for (SNRollingNews *news in item.news.newsFocusArray) {
                            if ([news.newsId isEqualToString:aNewsId]) {
                                infoCurrent = info;
                                findNews = YES;
                                break;
                            }
                        }
                    }
                    if (findNews == YES) {
                        break;
                    }
                }
                //焦点图
                if (item.cellType == SNRollingNewsCellTypeMoreFoucs) {
                    for (NSString *newsId in item.focusList) {
                        if ([newsId isEqualToString:aNewsId]) {
                            infoCurrent = info;
                            findNews = YES;
                            break;
                        }
                    }
                    
                    if (findNews == YES) {
                        break;
                    }
                } else if (item.cellType == SNRollingNewsCellTypeTrainCard) {
                    //火车卡片
                    NSInteger isTrainIndex = 0;
                    for (SNRollingNews *news in item.news.newsItemArray) {
                        if ([news.newsId isEqualToString:aNewsId]) {
                            infoCurrent = [self getInfoFromObject:news withType:NEWS_ITEM_TYPE_NORMAL];
                            findNews = YES;
                            break;
                        }
                        isTrainIndex++;
                    }
                    if (findNews == YES) {
                        if (isTrainIndex ==
                            item.news.newsItemArray.count - 1) {
                            //最后一个
                            isTrainCard = NO;
                        } else {
                            isTrainCard = YES;
                            i = isTrainIndex;
                            newsList = item.news.newsItemArray;
                        }
                        break;
                    }
                }
            }
            
            if (info != nil &&
                info.type == (SNRollingNewsItemType)[aType intValue] &&
                [info.id isEqualToString:aNewsId]) {
                infoCurrent = info;
                break;
            }
        }
    }
    
    //需找非直播的下一项
    if (infoCurrent != nil) {
        for (i = i + 1; i < [newsList count]; i++) {
            @autoreleasepool {
                id nextobj = [newsList objectAtIndex:i];
                SNNewsInfo *nextItem = nil;
                if (isTrainCard) {
                    nextItem = [self getInfoFromObject:nextobj withType:NEWS_ITEM_TYPE_NORMAL];
                } else {
                    nextItem = [self getInfoFromObject:nextobj];
                }
                
                if (nextItem != nil && nextItem.parseable &&
                    ![nextItem.isWeather isEqualToString:@"1"] &&
                    ![nextItem.link hasPrefix:kProtocolSNS] &&
                    ![nextItem.link hasPrefix:kSchemeUrlSNS]) {
                    NSMutableDictionary *dic = [_queryAll mutableCopy];
                    if (nextItem.key)  {
                        [dic setObject:nextItem.key forKey:kContinuityType];
                    }
                    [dic setValue:[NSNumber numberWithBool:NO] forKey:kClickOpenNews];
                    
                    NSMutableDictionary *subDic = [dic objectForKey:nextItem.key];
                    
                    if ([kContinuitySpecial isEqualToString:nextItem.key]) {
                        continue;//由于专题使用的是webview,不再支持连续阅读
                    }
                    else if([kContinuityWeibo isEqualToString:nextItem.key])
                    {
                        [subDic removeObjectForKey:@"userId"];
                        [subDic setObject:nextItem.id forKey:kWeiboId];
                    } else
                        [subDic setObject:nextItem.id forKey:kNewsId];
                    
                    if (nextItem.link)
                        [subDic setObject:nextItem.link forKey:kLink];
                    if (nextItem.updateTime)
                        [subDic setObject:nextItem.updateTime forKey:kUpdateTime];
                    
                    if (isTrainCard) {
                        [subDic setObject:[NSNumber numberWithInteger:i] forKey:kTrainIndex];
                        [subDic setObject:nextItem.trainID forKey:kTrainId];
                        [self p_switchTrainView:subDic];
                    }
                    // 4.2统计需求：连续阅读cc
                    SNUserTrack *curPage = [SNUserTrack trackWithPage:[[self class] pageInfoForContentType:(int)infoCurrent.type]
                                                                link2:infoCurrent.link];
                    SNUserTrack *toPage = [SNUserTrack trackWithPage:[[self class] pageInfoForContentType:(int)nextItem.type] link2:nextItem.link];
                    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_slide_reading];
                    [SNNewsReport reportADotGifWithTrack:paramString];
                    [SNUtility shouldUseSpreadAnimation:NO];
                    
                    //设置已读
                    [self setObjectRead:nextobj];
                    [(SNNavigationController *)self.flipboardNavigationController setOnlyAnimation:YES];
                    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
                    [[TTNavigator navigator] openURLAction:urlAction];
                    return YES;
                }
            }
        }
    }
    
    //无法切换或者不需要切换，自身处理就可以了
    return NO;
}

-(BOOL)swithControllerSpecial:(NSString*)aNewsId type:(NSNumber*)aType
{
    NSInteger i=0;
    SNNewsInfo* infoCurrent = nil;
    for(; i<[_specialRollingNewsListAll count]-1; i++) //最后一项没有项了，不查看了
    {
        @autoreleasepool {
            id object = [_specialRollingNewsListAll objectAtIndex:i];
            if([object isKindOfClass:[SNSpecialNews class]])
            {
                SNNewsInfo* info = [self getInfoFromObjectSpecial:object];
                if(info!=nil && info.type==(SNRollingNewsItemType)[aType intValue] && [info.id isEqualToString:aNewsId])
                {
                    infoCurrent = info;
                    break;
                }
            }
            else if([object isKindOfClass:[SNSpecialNewsTableItem class]])
            {
                SNNewsInfo* info = [self getInfoFromObjectSpecial:object];
                if(info!=nil && info.type==(SNRollingNewsItemType)[aType intValue] && [info.id isEqualToString:aNewsId])
                {
                    infoCurrent = info;
                    break;
                }
            }
        }
    }
    
    //需找非直播的下一项
    if(infoCurrent!=nil)
    {
        for(i=i+1; i<[_specialRollingNewsListAll count]; i++)
        {
            @autoreleasepool {
                id object = [_specialRollingNewsListAll objectAtIndex:i];
                SNNewsInfo* nextItem = [self getInfoFromObjectSpecial:object];
                
                if(nextItem!=nil && nextItem.parseable)
                {
                    NSMutableDictionary* dic = [_queryAll mutableCopy];
                    [dic setObject:nextItem.key forKey:kContinuityType];
                    
                    if([kContinuitySpecial isEqualToString:nextItem.key])
                        [[dic objectForKey:nextItem.key] setObject:nextItem.id forKey:kTermId];
                    else
                        [[dic objectForKey:nextItem.key] setObject:nextItem.id forKey:kNewsId];
                    
                    //设置已读
                    [self setObjectReadSpecial:object];
                    //弹出当前页
                    [self.flipboardNavigationController setOnlyAnimation:YES];
                    
                    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
                    [[TTNavigator navigator] openURLAction:urlAction];
                    return YES;
                }
            }
        }
    }
    
    //无法切换或者不需要切换，自身处理就可以了
    return NO;
}

-(BOOL)swithController:(NSString*)aNewsId type:(NSNumber*)aType
{
    if(_rollingNewsListAll!=nil && [_rollingNewsListAll count]>0)
        return [self swithControllerRolling:aNewsId type:aType];
    else if(_specialRollingNewsListAll!=nil && [_specialRollingNewsListAll count]>0)
        return [self swithControllerSpecial:aNewsId type:aType];
    //无法切换或者不需要切换，自身处理就可以了
    return NO;
}

-(BOOL)swithControllerInRecommand:(NSString*)aNewsId
{
//#ifdef COMMON_NEWS_PUSH_INTO_NEXT
    if(_queryAll!=nil)
    {
        NSInteger i=0;
        NSString* current = nil;
        NSArray* array = (NSArray*)[[_queryAll objectForKey:kContinuityNews] objectForKey:kRecommendNewsIDList];
        for(i=0; i<[array count]; i++)
        {
            NSString* item = (NSString*)[array objectAtIndex:i];
            if(item!=nil && [item isEqualToString:aNewsId])
            {
                current = item;
                break;
            }
        }
        
        if(current!=nil && i<=[array count]-2)
        {
            NSString* next = (NSString*)[array objectAtIndex:i+1];
            NSMutableDictionary* dic = [_queryAll mutableCopy];
            [[dic objectForKey:kContinuityNews] setObject:next forKey:kNewsId];
            
            //弹出当前页
            [self.flipboardNavigationController setOnlyAnimation:YES];
            
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:urlAction];
            return YES;
        }
    }
//#endif
    return NO;
}

-(BOOL)swithControllerInPhotoRecommand:(NSString*)aNewsId
{
    if(_queryAll!=nil)
    {
        NSInteger i=0;
        RecommendGallery* current = nil;
        NSArray* array = (NSArray*)[[_queryAll objectForKey:kContinuityPhoto] objectForKey:kRecommendNewsIDList];
        for(i=0; i<[array count]; i++)
        {
            RecommendGallery* item = (RecommendGallery*)[array objectAtIndex:i];
            if(item!=nil && [item isKindOfClass:[RecommendGallery class]] && item.newsId!=nil && [item.newsId isEqualToString:aNewsId])
            {
                current = item;
                break;
            }
        }
        
        if(current!=nil && i<=[array count]-2)
        {
            RecommendGallery* nextitem = (RecommendGallery*)[array objectAtIndex:i+1];
            NSMutableDictionary* dic = [_queryAll mutableCopy];
            [[dic objectForKey:kContinuityPhoto] setObject:nextitem.newsId forKey:kNewsId];
            
            //弹出当前页
            [self.flipboardNavigationController setOnlyAnimation:YES];
            
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:urlAction];
            return YES;
        }
    }
    return NO;
}

-(BOOL)swithControllerInNewsPaper:(NSString*)aNextNewsLink current:(id)aCurrent
{
    if(aNextNewsLink!=nil)
    {
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:aNextNewsLink]];
        self.newsPaper.isContinuous = YES;
        BOOL result = [self.newsPaper webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked];
        if(!result) //如果返回no表示可以处理....
            return YES;
    }
    return NO;
}

//判断是否支持连续阅读
+(BOOL)supportContinuation:(NSString*)aType
{
    if(aType!=nil)
    {
        if([kSNPhotoAndTextNewsType isEqualToString:aType]) //即时
            return YES;
        else if([kNewsTypeSpecialNews isEqualToString:aType]) //专题
            return YES;
        else if([kNewsTypeGroupPhoto isEqualToString:aType]) //组图
            return YES;
        else if([kNewsTypeVoteNews isEqualToString:aType]) //投票
            return YES;
        else if([kSNTextNewsType isEqualToString:aType]) //文本
            return YES;
        else if([kSNVoteWeiwenType isEqualToString:aType]) //微闻
            return YES;
        else if([kSNHeadlineNewsType isEqualToString:aType])
            return YES;
        else if([kNewsTypeRollingFunnyText isEqualToString:aType])
            return YES;
    }
    
    return NO;
}

//判断专题里是否支持连续阅读
+(BOOL)supportContinuationInSpecial:(NSString*)aType
{
    if(aType!=nil)
    {
        if([kSNPhotoAndTextNewsType isEqualToString:aType]) //即时
            return YES;
        else if([kNewsTypeGroupPhoto isEqualToString:aType]) //组图
            return YES;
        else if([kNewsTypeVoteNews isEqualToString:aType]) //投票
            return YES;
        else if([kSNTextNewsType isEqualToString:aType]) //文本
            return YES;
        //else if([kSNVoteWeiwenType isEqualToString:aType]) //微闻
        //    return YES;
        else if([kSNHeadlineNewsType isEqualToString:aType])
            return YES;
    }
    
    return NO;
}

+ (SNCCPVPage)pageInfoForContentType:(SNRollingNewsItemType)type {
    SNCCPVPage page = article_detail_txt;
    
    switch (type) {
        case NEWS_ITEM_TYPE_GROUP_PHOTOS:
            page = article_detail_pic;
            break;
        case NEWS_ITEM_TYPE_SPECIAL_NEWS:
            page = special;
            break;
        case NEWS_ITEM_TYPE_LIVE:
            page = live;
            break;
        case NEWS_ITEM_TYPE_NEWSPAPER:
            page = paper_main;
            break;
        case NEWS_ITEM_TYPE_SUBSCRIBE:
            page = paper_detail;
            break;
            
        default:
            page = article_detail_txt;
            break;
    }
    
    return page;
}

-(BOOL)getParseableFromtype:(NSInteger)type
{
    if(type==NEWS_ITEM_TYPE_GROUP_PHOTOS)
        return YES;
    else if(type==NEWS_ITEM_TYPE_WEIBO)
        return YES;
    else if(type==NEWS_ITEM_TYPE_SPECIAL_NEWS)
        return YES;
    else if(type==NEWS_ITEM_TYPE_NORMAL)
        return YES;
    //下面的不支持连续
    else if(type==NEWS_ITEM_TYPE_SUBSCRIBE)
        return YES;
    else if(type==NEWS_ITEM_TYPE_LIVE)
        return NO;
    else if(type==NEWS_ITEM_TYPE_NEWSPAPER)
        return NO;
    else if(type==NEWS_ITEM_TYPE_APP)
        return NO;
    else
        return NO;
}

-(NSString*)getKeyFromtype:(NSInteger)type
{
    if(type==NEWS_ITEM_TYPE_GROUP_PHOTOS)
       return kContinuityPhoto;
    else if(type==NEWS_ITEM_TYPE_LIVE)
        return nil;
    else if(type==NEWS_ITEM_TYPE_NEWSPAPER)
        return nil;
    else if(type==NEWS_ITEM_TYPE_SPECIAL_NEWS)
       return kContinuitySpecial;
    else if(type==NEWS_ITEM_TYPE_WEIBO)
       return kContinuityWeibo;
    else
       return kContinuityNews;
}

-(void)setIsReadFromObject:(id)object
{
    if(object==nil)
        return;
    else if([object isKindOfClass:[SNPromotionTableItem class]])
    {
        return;
    }
    else if([object isKindOfClass:[SNRollingNewsTableItem class]])
    {
        SNRollingNewsTableItem* item = (SNRollingNewsTableItem*)object;
        item.news.isRead = YES;
    }
    else if([object isKindOfClass:[SNRollingNewsHeadlineItem class]])
    {
        SNRollingNewsHeadlineItem* item = (SNRollingNewsHeadlineItem*)object;
        item.news.isRead = YES;
    }
    else
        return;
}

-(void)setObjectRead:(id)object
{
    if(object==nil)
        return;
    else if([object isKindOfClass:[SNPromotionTableItem class]])
    {
        return;
    }
    else if([object isKindOfClass:[SNRollingNewsTableItem class]])
    {
        SNRollingNewsTableItem* item = (SNRollingNewsTableItem*)object;
        NSString* newsId = item.news.newsId;
        NSString* channel = item.news.channelId;
        //设置数据库已读
        if(channel!=nil && newsId!=nil)
            [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
        //内存已读
        item.news.isRead = YES;
    }
    else if([object isKindOfClass:[SNRollingNewsHeadlineItem class]])
    {
        SNRollingNewsHeadlineItem* item = (SNRollingNewsHeadlineItem*)object;
        NSString* newsId = item.news.newsId;
        NSString* channel = item.news.channelId;
        //设置数据库已读
        if(channel!=nil && newsId!=nil)
            [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
        //内存已读
        item.news.isRead = YES;
    }
    else if([object isKindOfClass:[WeiboHotItem class]])
    {
        WeiboHotItem* item = (WeiboHotItem*)object;
        NSString* newsId = item.weiboId;
        NSString* channel = @"0";
        //设置数据库已读
        if(channel!=nil && newsId!=nil)
//            [[SNDBManager currentDataBase] markRollingNewsListItemAsReadByChannelId:channel newsId:newsId];
            [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
        //内存已读
        item.readMark = @"1";
    }
    else
        return;
}

- (SNNewsInfo *)getInfoFromObject:(SNRollingNews *)news
                         withType:(NSInteger)itemType {
    if (![news isKindOfClass:[SNRollingNews class]]) {
        return nil;
    }
    SNNewsInfo *info = [[SNNewsInfo alloc] init];
    NSInteger type = [news.templateType integerValue];
    if (type == SNRollingNewsCellTypeTopic ||
        type == SNRollingNewsCellTypeAdStock ||
        type == SNRollingNewsCellTypeRefresh ||
        type == SNRollingNewsCellTypeChangeCity ||
        type == SNRollingNewsCellTypeCityScanAndTickets ||
        type == SNRollingNewsCellTypeRedPacketTip ||
        type == SNRollingNewsCellTypeRedPacket ||
        type == SNRollingNewsCellTypeCoupons ||
        type == SNRollingNewsCellTypeSohuLive ||
        type == SNRollingNewsCellTypeRecomendItemTagType ||
        [news isSohuFeed] ||
        type == SNRollingNewsCellTypeHistoryLine ||
        type == SNRollingNewsCellAdIndividuation //本地频道置顶广告
        ) {
        //这些类型的新闻，跳过连续阅读
        return nil;
    }
    
    info.title = news.title;
    info.id = news.newsId;
    info.type = itemType;
    info.trainID = news.trainCardId;
    info.parseable = [self getParseableFromtype:info.type];
    info.key = [self getKeyFromtype:info.type];
    info.isWeather = news.isWeather;
    info.link = news.link;
    info.updateTime = news.updateTime;
    
    //H5的图文新闻不支持连续阅读
    
    if (info.type == NEWS_ITEM_TYPE_NORMAL &&
        [SNAPI isWebURL:news.link]) {
        info.parseable = NO;
    }
    //流内插入的标签频道不支持连续阅读
    if ([news.link hasPrefix:@"channel://"]) {
        info.parseable = NO;
    }
    return info;
}

- (SNNewsInfo *)getInfoFromObject:(id)object {
    if (object == nil)
        return nil;
    else if ([object isKindOfClass:[SNPromotionTableItem class]]) {
        return nil;
    } else if ([object isKindOfClass:[SNRollingNewsTableItem class]]) {
        SNNewsInfo *info = [[SNNewsInfo alloc] init];
        SNRollingNewsTableItem *item = (SNRollingNewsTableItem *)object;
        if (item.cellType == SNRollingNewsCellTypeTopic ||
            item.cellType == SNRollingNewsCellTypeAdStock ||
            item.cellType == SNRollingNewsCellTypeRefresh ||
            item.cellType == SNRollingNewsCellTypeChangeCity ||
            item.cellType == SNRollingNewsCellTypeCityScanAndTickets ||
            item.cellType == SNRollingNewsCellTypeRedPacketTip ||
            item.cellType == SNRollingNewsCellTypeRedPacket ||
            item.cellType == SNRollingNewsCellTypeCoupons ||
            item.cellType == SNRollingNewsCellTypeSohuLive ||
            item.cellType == SNRollingNewsCellTypeRecomendItemTagType ||
            [item.news isSohuFeed] ||
            item.cellType == SNRollingNewsCellTypeHistoryLine ||
            item.cellType == SNRollingNewsCellAdIndividuation //本地频道置顶广告
            ) {
            //这些类型的新闻，跳过连续阅读
            return nil;
        }
        
        SNRollingNews *news = item.news;
        if (item.cellType == SNRollingNewsCellTypeMoreFoucs) {
            if (item.news.newsFocusArray.count > 0) {
                news = [item.news.newsFocusArray objectAtIndex:0];
            } else {
                return nil;
            }
        } else if (item.cellType == SNRollingNewsCellTypeFullScreenFocus) {
            if (item.news.newsFocusArray.count > 0) {
                news = [item.news.newsFocusArray objectAtIndex:0];
            } else if (item.news.newsItemArray.count > 0) {
                news = [item.news.newsItemArray objectAtIndex:0];
            } else {
                return nil;
            }
        } else if (item.cellType == SNRollingNewsCellTypeTrainCard) {
            if (item.news.newsItemArray.count > 0) {
                for (SNRollingNews *tmpNews in item.news.newsItemArray) {
                    SNNewsInfo *tmpInfo = [self getInfoFromObject:tmpNews withType:info.type];
                    //获取合适的火车卡片
                    if (tmpInfo && tmpInfo.parseable) {
                        news = tmpNews;
                        break;
                    }
                }
            } else {
                return nil;
            }
        }
        
        info.title = news.title;
        info.id = news.newsId;
        info.trainID = news.trainCardId;
        info.type = item.type;
        info.parseable = [self getParseableFromtype:info.type];
        info.key = [self getKeyFromtype:info.type];
        info.isWeather = news.isWeather;
        info.link = news.link;
        info.updateTime = news.updateTime;
        
        //h5的图文新闻不支持连续阅读
        if (info.type == NEWS_ITEM_TYPE_NORMAL &&
            [item isH5Link] &&
            [SNAPI isWebURL:news.link]) {
            info.parseable = NO;
        }
        //流内插入的标签频道不支持连续阅读
        if ([item isChannelLink]) {
            info.parseable = NO;
        }
        return info;
    } else if ([object isKindOfClass:[SNRollingNewsHeadlineItem class]]) {
        SNNewsInfo *info = [[SNNewsInfo alloc] init];
        SNRollingNewsHeadlineItem *item = (SNRollingNewsHeadlineItem*)object;
        info.title = item.news.title;
        info.id = item.news.newsId;
        info.type = item.type;
        info.parseable = [self getParseableFromtype:info.type];
        info.key = [self getKeyFromtype:info.type];
        info.link = item.news.link;
        info.updateTime = item.news.updateTime;
        return info;
    } else if ([object isKindOfClass:[WeiboHotItem class]]) {
        SNNewsInfo *info = [[SNNewsInfo alloc] init];
        WeiboHotItem *item = (WeiboHotItem *)object;
        info.title = item.title;
        info.id = item.weiboId;
        info.type = NEWS_ITEM_TYPE_WEIBO;
        info.parseable = [self getParseableFromtype:info.type];
        info.key = [self getKeyFromtype:info.type];
        return info;
    } else
        return nil;
}

- (void)setIsReadFromObjectSpecail:(id)object {
    if(object==nil)
        return;
    else if([object isKindOfClass:[SNSpecialNews class]])
    {
        SNSpecialNews* item = (SNSpecialNews*)object;
        item.isRead = @"1";
    }
    else if([object isKindOfClass:[SNSpecialNewsTableItem class]])
    {
        SNSpecialNewsTableItem* item = (SNSpecialNewsTableItem*)object;
        item.news.isRead = @"1";
    }
    else
        return;
}

-(SNNewsInfo*)getInfoFromObjectSpecial:(id)object
{
    if(object==nil)
        return nil;
    else if([object isKindOfClass:[SNSpecialNews class]])
    {
        SNSpecialNews* item = (SNSpecialNews*)object;
        SNNewsInfo* info = [[SNNewsInfo alloc] init];
        info.id = item.newsId;
        info.type = item.type;
        info.parseable = [self getParseableFromtype:info.type];
        info.key = [self getKeyFromtype:info.type];
        return info;
    }
    else if([object isKindOfClass:[SNSpecialNewsTableItem class]])
    {
        SNSpecialNewsTableItem* item = (SNSpecialNewsTableItem*)object;
        SNNewsInfo* info = [[SNNewsInfo alloc] init];
        info.id = item.news.newsId;
        info.type = item.type;
        info.parseable = [self getParseableFromtype:info.type];
        info.key = [self getKeyFromtype:info.type];
        return info;
    }
    else
        return nil;
}

-(void)setObjectReadSpecial:(id)object
{
    if(object==nil)
        return;
    else if([object isKindOfClass:[SNSpecialNews class]])
    {
        SNSpecialNews* item = (SNSpecialNews*)object;
        NSString* newsId = item.newsId;
        NSString* term = item.termId;
        //设置数据库已读
        if(term!=nil && newsId!=nil)
        {
            NSDictionary* _dicData = [NSDictionary dictionaryWithObject:kSNSpecialNewsIsRead_YES forKey:@"isRead"];
            [[SNDBManager currentDataBase] updateSpecialNewsListByTermId:term newsId:newsId withValuePairs:_dicData];
        }
        //内存已读
        item.isRead = kSNSpecialNewsIsRead_YES;
    }
    else if([object isKindOfClass:[SNSpecialNewsTableItem class]])
    {
        SNSpecialNewsTableItem* item = (SNSpecialNewsTableItem*)object;
        NSString* newsId = item.news.newsId;
        NSString* term = item.termId;
        //设置数据库已读
        if(term!=nil && newsId!=nil)
        {
            NSDictionary* _dicData = [NSDictionary dictionaryWithObject:kSNSpecialNewsIsRead_YES forKey:@"isRead"];
            [[SNDBManager currentDataBase] updateSpecialNewsListByTermId:term newsId:newsId withValuePairs:_dicData];
        }
        //内存已读
        item.news.isRead = kSNSpecialNewsIsRead_YES;
    }
}

-(NSString*)getTitleById:(NSString*)aNewsId
{
    NSString* title = nil;
    for(int i=0; i<[_rollingNewsListAll count]; i++)
    {
        SNNewsInfo* info = [self getInfoFromObject:[_rollingNewsListAll objectAtIndex:i]];
        title = info.title;
        break;
    }
    return title;
}

#pragma mark - SNNavigationController
- (UIViewController *)backToViewController
{
   return nil;
}

- (BOOL)panGestureEnable
{
    if ([self.currentController isKindOfClass:[SHH5NewsWebViewController class]]) {
        SHH5NewsWebViewController *vc = (SHH5NewsWebViewController *)self.currentController;
        if (vc.slideShowMode || vc.isSlideShowMode) {
            return NO;
        }
    }
    return YES;
}

- (void)enableScrollToTop
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    //有隐患, 负责人注意方法调用
    if ([self.currentController respondsToSelector:@selector(setCurrentTableShouldScrollsToTop)]) {
        [self.currentController performSelector:@selector(setCurrentTableShouldScrollsToTop)];
    }
#pragma clang diagnostic pop
}

- (BOOL)shouldRecognizeGesture:(UIGestureRecognizer *)gestureRecognizer withTouch:(UITouch *)touch {
    UIView *touchView = touch.view;
    return !([touchView isKindOfClass:[WSMVSlider class]]);
}

- (void)popFromControllerClass:(Class)class
{
//    if ([class isSubclassOfClass:SNH5WebController.class]) {
//        
//        if ([_currentController isKindOfClass:SNNewsContentController.class]) {
//            SNNewsContentController *newsVC = (SNNewsContentController *)_currentController;
//            
//            SNArticle *article = newsVC.currentNewsWeb.article;
//            
//            if (article.termId) {
//                [[SNDBManager currentDataBase] deleteNewsArticlebyTermId:article.termId newsId:article.newsId];
//            } else {
//                [[SNDBManager currentDataBase] deleteNewsArticlebyChannelId:article.channelId newsId:article.newsId];
//            }
//            
//            [newsVC performSelector:@selector(refreshNews) withObject:nil afterDelay:0.1];            
//        }        
//    }
}

//预览页面初始化
- (id)initWithParams:(NSDictionary *)dict URL:(NSURL*)URL{
    self = [super init];
    if(self)
    {
        self.URL = URL;
        self.queryAll = dict;
    }
    return self;
}

//预览页面 底部Action Items
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"进入" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [self.sourceVC openNewsFrom3DTouch];
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"关闭" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {

    }];
    
    [arr addObject:action1];
    [arr addObject:action2];
    
    return arr;
}

@end
