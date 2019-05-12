//
//  SNActionMenu.h
//  sohunews
//
//  Created by Dan Cong on 2/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNActionMenuItem.h"
#import "SNNavigationBar.h"
#import "SNPageControl.h"

#define kSNActionMenuViewTag (604)

typedef enum {
    SNActionMenuButtonTypeLike,
    SNActionMenuButtonTypeLoadingPage,
    SNActionMenuButtonTypeH5Share
} SNActionMenuButtonType;

@class SNActionMenu;

@protocol SNActionMenuDelegate <NSObject>

- (void)actionMenu:(SNActionMenu *)actionMenu didSelectAtIndex:(int)buttonIndex;

@end

@interface SNActionMenu : UIView <UIScrollViewDelegate, SNPageControlDelegate>
{
    
//    NSTimeInterval _actionMenuDate;
    
@private
    id<SNActionMenuDelegate>  __weak _delegate;
    NSMutableArray        *_items;
    SNActionMenuItem *__weak _selectedItem;
    UIColor               *_tintColor;
    //analyze: never used
//    NSInteger              _pages;
    SNNavigationBar       *_containerBgView;
    UIScrollView          *_containerView;
    SNPageControl         *_pageControl;
    NSMutableArray        *_containerScrollViews;
    //analyze: never used
//    CGSize                 _originalSize;
    //analyze: never used
//    CGSize                 _halfOriginalSize;
    
    UIButton              *_cancelButton;
}

@property (nonatomic, weak) id<SNActionMenuDelegate> delegate;     // weak reference. default is nil
@property (nonatomic, strong)   NSMutableArray                *items;
@property (nonatomic, weak) SNActionMenuItem         *selectedItem; // will show feedback based on mode. default is nil
@property (nonatomic, strong) UIColor                       *tintColor;    // Default is black.
@property (nonatomic, strong) UIView                        *presentFromView;    // Default is key window.

@property (nonatomic, strong) UIButton *cancelButton;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;
- (void)setItems:(NSMutableArray *)items;
- (void)show;
- (void)dismiss;

@end
