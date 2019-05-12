//
//  SNRollingAddSubscribeCell.m
//  sohunews
//
//  Created by lhp on 10/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingAddSubscribeCell.h"
#import "SNNewsReport.h"
#import "SNUserManager.h"

@interface SNRollingAddSubscribeCell() {
    UIImageView *addImageView;
    UILabel *titleLabel;
    UIView *lineView;
}

@end

#define kAddSubscribeCellHeight     (70 / 2)

@implementation SNRollingAddSubscribeCell
@synthesize subscribeItem;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kAddSubscribeCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = YES;
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAppScreenWidth / 2 - 40, 8, 18, 18)];
    addImageView.image = [UIImage imageNamed:@"icobooking_add_v5.png"];
    addImageView.highlightedImage = [UIImage themeImageNamed:@"icobooking_addpress_v5.png"];
    [self addSubview:addImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, kThemeFontSizeC + 1)];
    titleLabel.left = addImageView.right + 6;
    titleLabel.text = @"添加关注";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    [self addSubview:titleLabel];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kAddSubscribeCellHeight - 0.5f, kAppScreenWidth, 0.5f)];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    lineView.clipsToBounds = NO;
    [self addSubview:lineView];
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    if (self.subscribeItem != object) {
        self.subscribeItem = object;
        self.subscribeItem.delegate = self;
        self.subscribeItem.selector = @selector(addSubscribe);
    }
}

- (void)drawBackgroundColorWithRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *grayColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    CGContextSetFillColorWithColor(context, grayColor.CGColor);
    CGContextFillRect(context, rect);
}

- (void)drawRect:(CGRect)rect {
    [self drawBackgroundColorWithRect:rect];
    [UIView drawCellSeperateLine:rect margin:0];
}

- (void)addSubscribe {
    SNAppConfigMPLink *confifMPLink = [SNAppConfigManager sharedInstance].configMPLink;
    NSString *stat = nil;
    if (confifMPLink.mpLink.length > 0) {
        stat = confifMPLink.mpLink;
    } else {
        stat = [NSString stringWithFormat:FixedUrl_Subscribe];
    }
    if ([stat length] > 0 && [SNAPI isWebURL:stat]) {
        [SNNewsReport reportADotGif:@"_act=moresub&_tp=pv"];
        
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        [query setObject:stat forKey:kLink];
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://subscribeWebBrowser"] applyAnimated:YES] applyQuery:query];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
}

- (void)updateTheme {
    [super updateTheme];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    addImageView.image = [UIImage imageNamed:@"icobooking_add_v5.png"];
    addImageView.highlightedImage = [UIImage themeImageNamed:@"icobooking_addpress_v5.png"];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    addImageView.highlighted = highlighted;
    if (highlighted) {
        titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kPostTextViewBgColor];
    } else {
        titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    }
    
}

@end
