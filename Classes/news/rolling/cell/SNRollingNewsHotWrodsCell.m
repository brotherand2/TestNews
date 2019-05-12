//
//  SNRollingNewsHotWrodsCell.m
//  sohunews
//
//  Created by wangyy on 16/7/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsHotWrodsCell.h"
#import "SNHotWordModel.h"
#import "UIFont+Theme.h"

#define kHotWordButtonHeight 30

@interface SNRollingNewsHotWrodsCell ()
@property (nonatomic, strong) NSMutableArray *buttonList;
@end

@implementation SNRollingNewsHotWrodsCell

@synthesize buttonList = _buttonList;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    int count = newsItem.news.newsHotWordsArray.count;
    switch (count) {
        case 1:
        case 2:
        case 3:
            return 78;
        case 4:
        case 5:
        case 6:
            return 118;
        default:
            return 0;
    }
    
    return 0;
}

- (void)dealloc {
    self.buttonList = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        self.buttonList = [NSMutableArray array];
    }
    return self;
}

- (void)updateNewsContent {
    [super updateNewsContent];
    
    int xValue = 0.0, yValue = CONTENT_IMAGE_TOP + 3;
    int width = (kAppScreenWidth - 8 - CONTENT_LEFT * 2) / 3;
    for (int i = 0; i < self.item.news.newsHotWordsArray.count; i++) {
        if (i % 3 == 0) {
            xValue = CONTENT_LEFT;
        }
        
        if (i / 3 > 0) {
            yValue = CONTENT_IMAGE_TOP + kHotWordButtonHeight + 8;
        }
        SNHotWordModel *hotWords = [self.item.news.newsHotWordsArray objectAtIndex:i];
        CGRect rect = CGRectMake(xValue, yValue, width, kHotWordButtonHeight);
        UIButton *button = [[UIButton alloc] initWithFrame:rect];
        button.tag = i;
        button.font = [UIFont systemFontOfSizeType:UIFontSizeTypeD];
        button.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [button setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBlue1Color]] forState:UIControlStateNormal];
        [button setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
        [button setTitle:hotWords.name forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        xValue += width + 4;
        
        [self.buttonList addObject:button];
    }
}

- (void)updateTheme {
    [super updateTheme];
    
    for (UIButton *button  in self.buttonList) {
        button.backgroundColor = SNUICOLOR(kThemeBg2Color);
        [button setTitleColor:SNUICOLOR(kThemeText2Color) forState:UIControlStateNormal];
    }
}


- (IBAction)onClickButton:(id)sender {
}

@end
