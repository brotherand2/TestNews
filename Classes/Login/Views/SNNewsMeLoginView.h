//
//  SNNewsMeLoginView.h
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsMeLoginViewDelegate;
@interface SNNewsMeLoginView : UIView

@property (nonatomic,weak) id <SNNewsMeLoginViewDelegate> delegate;

@end

@protocol SNNewsMeLoginViewDelegate <NSObject>

- (void)loginSuccess;

- (void)refreshTable;

@end;
