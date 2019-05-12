//
//  SNMultiRowsButtonView.h
//  sohunews
//
//  Created by guoyalun on 3/21/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNMultiRowsButtonViewDelegate;

@interface SNMultiRowsButtonView : UIView
{
    NSInteger    rows;
    id<SNMultiRowsButtonViewDelegate> __weak _delegate;
}
@property (nonatomic,weak) id<SNMultiRowsButtonViewDelegate> delegate;

- (void)setButtonTitles:(NSArray *)titles;

- (void)updateTheme;

@end


@protocol SNMultiRowsButtonViewDelegate <NSObject>

- (void)tapButton:(UIButton *)button atIndex:(NSInteger)index;

@end
