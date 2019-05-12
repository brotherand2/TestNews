//
//  SHTodayWidgetContentView.h
//  LiteSohuNews
//
//  Created by wangyy on 15/10/28.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTodayWidgetNews.h"

@class SNTodayWidgetContentView;

@protocol SNTodayWidgetContentViewCallBack <NSObject>
@optional
- (void)didSelectNews:(SNTodayWidgetNews *)news;
- (void)didTapOnMoreNewsBtnInContentView:(SNTodayWidgetContentView *)contentView;
@end

@interface SNTodayWidgetContentView : UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<SNTodayWidgetContentViewCallBack> delegate;

- (void)reload:(NSArray *)newsList;
- (CGFloat)heightForNewsList:(NSArray *)newsList;

@end
