//
//  SNNewsScreenShareItemsView.h
//  sohunews
//
//  Created by wang shun on 2017/8/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsScreenShareItemsViewDelegate;
@interface SNNewsScreenShareItemsView : UIView

@property (nonatomic,weak) id <SNNewsScreenShareItemsViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame WithData:(NSArray*)shareIconsArr;


@end

@protocol SNNewsScreenShareItemsViewDelegate <NSObject>

- (void)shareTo:(NSString*)title;

@end
