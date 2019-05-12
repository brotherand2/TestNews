//
//  SNShareFirstView.m
//  sohunews
//
//  Created by TengLi on 2017/6/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareItemsView.h"
#import "SNShareItemView.h"
#import "SNNewsShareParamsHeader.h"
#import "SNNewsShareManager.h"
@interface SNShareItemsView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy) SNShareItemsViewHandler handler;
@end

@implementation SNShareItemsView

- (instancetype)initWithFrame:(CGRect)frame
                   shareItems:(NSArray *)shareItems
                      handler:(SNShareItemsViewHandler )handler
{
    self = [super initWithFrame:frame];
    if (self) {
        self.handler = handler;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height)];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        [self setupItemsWithShareItems:shareItems];
    }
    return self;
}

- (void)setupItemsWithShareItems:(NSArray *)shareItems {
    CGFloat leftMargin = 0;
    CGFloat itemW = (kAppScreenWidth/3.0);
    CGFloat itemH = self.frame.size.height;
    
    [shareItems enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull shareItem, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *title = [shareItem stringValueForKey:kShareIconTitle defaultValue:@""];
        NSString *iconName = [shareItem stringValueForKey:kShareIconImage defaultValue:@""];
        SNShareItemView *itemView = [[SNShareItemView alloc] initWithFrame:CGRectMake(itemW*idx, 0, itemW, itemH) title:title iconName:iconName];
        
        [itemView addTarget:self action:@selector(shareItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:itemView];
        if (idx == shareItems.count - 1) {
            [self.scrollView setContentSize:CGSizeMake(CGRectGetMaxX(itemView.frame) + leftMargin, 0)];
        }
    }];
}

- (void)shareItemClick:(SNShareItemView *)itemView {
    if (self.handler) {
        self.handler(itemView.currentTitle);
    }
}

@end
