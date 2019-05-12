//
//  SNNormalSearchView.h
//  sohunews
//
//  Created by Scarlett on 15/12/17.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCancelText @"取消"
#define kSearchText @"搜索"
#define kButtonRightDistance 28.0/2

@interface SNNormalSearchView : UIView

- (id)initWithFrame:(CGRect)frame delegate:(id) delegate;
- (void)closeKeyBoard;
- (NSString *)getSearchText;
- (BOOL)isSearching;
- (void)showSearchButton:(BOOL)isShow;
- (void)resetTextView;

@end
