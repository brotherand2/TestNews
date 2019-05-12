//
//  SNUserSearchable.m
//  LiteSohuNews
//
//  Created by iEvil on 9/14/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import "SNUserSearchable.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SNSpotlightRequest.h"
#import "SNUserManager.h"

@implementation SNUserSearchable
#pragma mark - Singleton
+ (instancetype)sharedInstance {
    static SNUserSearchable *_sharedUserSearchable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUserSearchable = [[self alloc] init];
    });
    
    return _sharedUserSearchable;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)requestSpotlightData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *nDefaults = [NSUserDefaults standardUserDefaults];
        NSDate *date = [nDefaults valueForKey:SpotlightRefreshdate];
        if (date) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.hour = 8;
            NSDate *expriedDate = [calendar dateByAddingComponents:components toDate:date options:0];
            //超过8小时再请求更新
            if ([expriedDate compare:[NSDate date]] == NSOrderedDescending) {
                return;
            }
        }
        
        //请求数据
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setValue:[[SNUtility getApplicationDelegate] currentNetworkStatusString] forKey:@"net"];
        [params setValue:[SNUserManager getCookie] forKey:@"scookie"];
        [[[SNSpotlightRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
            NSDictionary *data = [(NSDictionary *)responseObject valueForKey:kSpotlightData];
            if (data.count == 0) {
                return;
            }
            NSArray *contents = [data valueForKey:kSpotlightContents];
            if (contents.count == 0) {
                return;
            }
            
            //存储当前时间
            NSDate *refreshDate = [NSDate date];
            [nDefaults setObject:refreshDate forKey:SpotlightRefreshdate];
            
            NSMutableArray *searchItems = [[NSMutableArray alloc] initWithCapacity:contents.count];
            for (NSDictionary *content in contents) {
                CSSearchableItem *item = [self addSearchForArticle:content];
                [searchItems addObject:item];
            }
            
            if (searchItems.count > 0) {
                //添加索引
                [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchItems completionHandler:^(NSError * _Nullable error) {
                }];
            }
            
        } failure:nil];
    });
}

- (CSSearchableItem *)addSearchForArticle:(id)article {
    NSDictionary *_article = (NSDictionary *)article;
    
    //Core SpotLight
    CSSearchableItemAttributeSet *searchSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeItem];
    //名称
    searchSet.title = [_article valueForKey:kSpotlightTitle];
    //详情
    searchSet.contentDescription = [NSString stringWithFormat:@"%@", [_article valueForKey:kSpotlightContent]];
    
    CSSearchableItem *searchItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:[NSString stringWithFormat:@"sohunews://pr/%@", [_article valueForKey:kSpotlightLink]] domainIdentifier:SearchActivityType attributeSet:searchSet];
    
    //计算过期时间
    NSDate *expriedDate = [NSDate dateWithTimeIntervalSinceNow:[[_article valueForKey:kSpotlightContentExpireTime] doubleValue]];
    //过期时间
    searchItem.expirationDate = expriedDate;
    
    return searchItem;
}

- (void)removeSearchForArticle {
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
    }];
}

@end
