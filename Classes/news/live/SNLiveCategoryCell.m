//
//  SNLiveCategoryCell.m
//  sohunews
//
//  Created by chenhong on 13-11-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveCategoryCell.h"
#import "SNLiveCategoryTableItem.h"

#define kBtnW   65
#define kBtnH   30
#define kLeft   10
#undef kTop
#define kTop    13
#define kBottom 5
#define kGapX   13.33
#define kGapY   11

@interface SNLiveCategoryCell () {
    NSMutableArray *_btnArray;
}

@end

@implementation SNLiveCategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        _btnArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)setObject:(id)object {
    self.liveItem = object;
    
    for (UIButton *btn in _btnArray) {
        [btn removeFromSuperview];
    }
    [_btnArray removeAllObjects];

    NSString *textColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameInfoTextColor];
    UIColor *btnTextColor = [UIColor colorFromString:textColorStr];

    int index = 0;
    UIImage *bgImage = [UIImage imageNamed:@"channelview_bg.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width / 2 topCapHeight:bgImage.size.height / 2];
    UIFont *font = [UIFont systemFontOfSize:14];
    
    for (LiveCategoryItem *subItem in self.liveItem.categoryItems) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kBtnW, kBtnH)];
        [btn setBackgroundImage:bgImage forState:UIControlStateNormal];
        [_btnArray addObject:btn];
        [btn setTitle:subItem.name forState:UIControlStateNormal];
        [btn setTitleColor:btnTextColor forState:UIControlStateNormal];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(2.5, 0, 0, 0)];
        [btn.titleLabel setFont:font];
        [btn addTarget:self action:@selector(clickCategoryBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = index++;
        [self addSubview:btn];
    }
}

- (void)layoutSubviews {
    float x,y;
    for (int index = 0; index<_btnArray.count; ++index) {
        UIButton *btn = [_btnArray objectAtIndex:index];
        int row = index / 4;
        int col = index % 4;
        x = kLeft + col * (kBtnW + kGapX);
        y = kTop + row * (kBtnH + kGapY);
        btn.frame = CGRectMake(x, y, kBtnW, kBtnH);
    }
}

- (void)updateTheme {
    [self setObject:self.liveItem];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

// TT的tableView调用
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	SNLiveCategoryTableItem *liveItem = object;
    NSInteger row = (liveItem.categoryItems.count + 3) / 4;
    return kTop + row * kBtnH + (row - 1) * kGapY + kBottom;
}

// 非TT的tableView使用
+ (CGFloat)cellHeight:(NSArray *)categoryItems {
    NSInteger row = (categoryItems.count + 3) / 4;
    return kTop + row * kBtnH + (row - 1) * kGapY + kBottom;
}

- (void)clickCategoryBtn:(id)sender {
    UIButton *btn = sender;
    LiveCategoryItem *item = [self.liveItem.categoryItems objectAtIndex:btn.tag];
    if (item.link.length) {
        SNDebugLog(@"%@", item.link);
        //NSString *link = [item.link stringByReplacingOccurrencesOfString:kProtocolSub withString:kProtocolLiveChannel];
        
        [SNUtility openProtocolUrl:item.link context:@{@"subName":item.name}];
    }
}

@end
