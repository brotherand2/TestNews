//
//  SNWeatherBottomBar.h
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

@protocol SNWeatherBottomBarDelegate <NSObject>

@optional
- (void)barSelectionChangedTo:(NSInteger)index;

@end

@interface SNWeatherBottomBar : UIView {
    UIView *_refreshView;
}

@property(nonatomic, weak)id delegate;
@property(nonatomic, strong)NSArray *weathers;

@end
