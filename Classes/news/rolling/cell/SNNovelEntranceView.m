//
//  SNNovelEntranceView.m
//  sohunews
//
//  Created by qz on 14/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNNovelEntranceView.h"
#import "SNNovelShelfController.h"
#import "SNStoryUtility.h"
#import "SNBookShelf.h"

@interface SNNovelEntranceView () {
    CGFloat  _viewHeight;
    UIButton *catBtn;
    UIButton *bangBtn;
    UIButton *shelfBtn;
    BOOL     _showDot;
}

@property (nonatomic, strong) UIView *redDot;
@end

@implementation SNNovelEntranceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _viewHeight = frame.size.height;
        _showDot = NO;
        [self initViews];
        [self fetchShelfBooks];
    }
    
    return self;
}

- (void)initViews {
    CGFloat width = [UIScreen mainScreen].bounds.size.width/3;
    catBtn = [self buttonModelWithFrame:CGRectMake(0, 0, width, _viewHeight) imageArray:@[[UIImage imageNamed:@"icofiction_fl_v5.png"],[UIImage imageNamed:@"icofiction_flpress_v5.png"]] text:@"分类"];
    bangBtn = [self buttonModelWithFrame:CGRectMake(width, 0, width, _viewHeight) imageArray:@[[UIImage imageNamed:@"icofiction_bd_v5.png"],[UIImage imageNamed:@"icofiction_bdpress_v5.png"]] text:@"榜单"];
    shelfBtn = [self buttonModelWithFrame:CGRectMake(width * 2, 0, width, _viewHeight) imageArray:@[[UIImage imageNamed:@"icofiction_sj_v5.png"],[UIImage imageNamed:@"icofiction_sjpress_v5.png"]] text:@"书架"];

    self.redDot = [[UIView alloc]initWithFrame:CGRectMake(shelfBtn.center.x + 10, 10, 6, 6)];
    _redDot.backgroundColor = SNUICOLOR(kThemeRed1Color);
    _redDot.layer.cornerRadius = 3;
    _redDot.hidden = YES;
    [self addSubview:_redDot];
    
    [self addSubview:catBtn];
    [self addSubview:bangBtn];
    [self addSubview:shelfBtn];
}

- (void)fetchShelfBooks {
    __weak typeof(self)weakSelf = self;
    [SNBookShelf getBooks:@"" count:@""
                 complete:^(BOOL success, NSArray *books) {
        for (NSDictionary * bookDic in books) {
            @autoreleasepool {
                SNBook * book = [SNRollingNews createBookWithDictionary:bookDic];
                if (book.showDot) {
                    weakSelf.redDot.hidden = NO;
                    break;
                }
            }
        }
    }];
}

- (UIButton *)buttonModelWithFrame:(CGRect)btnFrame
                        imageArray:(NSArray *)array
                              text:(NSString *)text {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
    btn.frame = btnFrame;
    
    UIImage *image = array[0];
    if (array.count == 2) {
        [btn setImage:image forState:0];
        [btn setImage:array[1] forState:UIControlStateHighlighted];
    }
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];

    CGSize titleSize = [text boundingRectWithSize:CGSizeMake(9999, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
    btn.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + 9), titleSize.width, 0.0, 0.0);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width, - (image.size.height + 9), 0);
    
    return btn;
}

- (void)buttonClick:(UIButton *)sender {
    if (sender.frame.origin.x < [UIScreen mainScreen].bounds.size.width/3) {
        NSDictionary *dic = @{@"novelH5PageType":@"0",@"tagId":@"1",@"type":@"2"};
        [SNStoryUtility openUrlPath:@"tt://storyWebView" applyQuery:dic applyAnimated:YES];
        [SNStoryUtility storyReportADotGif:@"objType=fic_category&fromObjType=channel&statType=clk"];
    } else if (sender.frame.origin.x < [UIScreen mainScreen].bounds.size.width / 3 * 2) {
        NSDictionary *dic = @{@"novelH5PageType":@"0",@"tagId":@"1",@"type":@"1"};
        [SNStoryUtility openUrlPath:@"tt://storyWebView" applyQuery:dic applyAnimated:YES];
        [SNStoryUtility storyReportADotGif:@"objType=fic_list&fromObjType=channel&statType=clk"];
    } else {
        [self jumpToShelf];
        [SNStoryUtility storyReportADotGif:@"objType=fic_shelf&fromObjType=channel&statType=clk"];
    }
}

- (void)jumpToShelf {
    [SNUtility shouldUseSpreadAnimation:NO];
    SNNovelShelfController *shelfVC = [[SNNovelShelfController alloc]init];
    if (_novelItem) {
        shelfVC.dataItem = _novelItem;
    }
    [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:shelfVC animated:YES];
    self.redDot.hidden = YES;
}

- (void)updateTheme {
    [catBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
    [catBtn setImage:[UIImage imageNamed:@"icofiction_fl_v5.png"] forState:UIControlStateNormal];
    [catBtn setImage:[UIImage imageNamed:@"icofiction_flpress_v5.png"] forState:UIControlStateHighlighted];
    
    [bangBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
    [bangBtn setImage:[UIImage imageNamed:@"icofiction_bd_v5.png"] forState:UIControlStateNormal];
    [bangBtn setImage:[UIImage imageNamed:@"icofiction_bdpress_v5.png"] forState:UIControlStateHighlighted];
    
    [shelfBtn setTitleColor:SNUICOLOR(kThemeText2Color) forState:0];
    [shelfBtn setImage:[UIImage imageNamed:@"icofiction_sj_v5.png"] forState:UIControlStateNormal];
    [shelfBtn setImage:[UIImage imageNamed:@"icofiction_sjpress_v5.png"] forState:UIControlStateHighlighted];
    _redDot.backgroundColor = SNUICOLOR(kThemeRed1Color);
}

+ (CGPoint)popOverPoint {
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 3;
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        return CGPointMake(width * 2 + width / 2, 54 + 40 + 82 + 24);
    }
    return CGPointMake(width * 2 + width / 2, 54 + 40 + 82);
}

@end
