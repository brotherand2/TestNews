//
//  SNArticleSearchService.h
//  sohunews
//
//  Created by lhp on 6/17/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//  

#import <UIKit/UIKit.h>

@protocol SNArticleSearchServiceDelegate <NSObject>

- (void)requestDidFinishLoad;

@end

@interface SNArticleSearchService : NSObject
{
    NSString *html;
    id<SNArticleSearchServiceDelegate> __weak delegate;
}
@property(nonatomic,strong)NSString *html;
@property(nonatomic,weak)id<SNArticleSearchServiceDelegate> delegate;

+ (SNArticleSearchService *)sharedInstance;
- (void)requestArticleSearchWithText:(NSString *) searchText;

@end
