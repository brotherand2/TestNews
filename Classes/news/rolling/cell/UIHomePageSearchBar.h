//
//  UIHomePageSearchBar.h
//  sohunews
//
//  Created by wangyy on 15/11/13.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIHomePageSearchBar : UISearchBar

@property (nonatomic, strong) NSArray *hotWords;
@property (nonatomic, strong) NSString *channelId;
- (NSString *)getCurrentHotWords;
- (void)addSearchButtonWithTarget:(id)target action:(SEL)action;
- (void)updateTheme;
- (void)refreshHotWord:(NSString *)hotWord;

- (void)hideQrCodeBtn:(BOOL)hidden;
- (void)setSearchbarHeight:(CGFloat)value;
@end
