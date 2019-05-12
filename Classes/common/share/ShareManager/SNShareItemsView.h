//
//  SNShareFirstView.h
//  sohunews
//
//  Created by TengLi on 2017/6/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SNShareItemsViewHandler)(NSString *title);

@interface SNShareItemsView : UIView

- (instancetype)initWithFrame:(CGRect)frame shareItems:(NSArray *)shareItems handler:(SNShareItemsViewHandler )handler;
@end
