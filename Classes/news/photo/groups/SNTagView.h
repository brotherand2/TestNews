//
//  SNTagView.h
//  sohunews
//
//  Created by qi pei on 7/21/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagItem;
@class SNTagButton;

@protocol SNTagViewDelegate <NSObject>
@optional
- (void)selectedTag:(SNTagItem *)tagItem;
- (void)didTouchBeganInTagView;

@end

@interface SNTagView : UIScrollView {
    id<SNTagViewDelegate> __weak tagDelegate;
    NSMutableArray *tags;
    NSMutableArray *_allBtns;
    
    CGFloat _topMargin;
    CGFloat _tagBtnHeight;
    CGFloat _tagFontSize;
}

@property(nonatomic, strong)NSMutableArray *tags;
@property(nonatomic, weak)id<SNTagViewDelegate> tagDelegate;
@property(nonatomic,assign) CGFloat tagMargin;
@property(nonatomic,assign) CGFloat tagBtnHeight;
@property(nonatomic,assign) CGFloat tagFontSize;

- (void)fillTags:(NSMutableArray *)allTag;
- (SNTagButton *)createTagButton:(SNTagItem *)tagItem;
- (void)addTagsToView;
- (void)updateTheme;

@end
