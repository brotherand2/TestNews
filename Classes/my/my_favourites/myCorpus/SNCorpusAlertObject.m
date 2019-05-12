//
//  SNCorpusAlertObject.m
//  sohunews
//
//  Created by 李腾 on 2016/12/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//  收藏新闻时调用此类的方法进行弹窗显示

#import "SNCorpusAlertObject.h"
#import "SNNewAlertView.h"
#import "SNSmallCorpusView.h"
#import "SNSmallCorpusTableViewCell.h"
#import "SNMyFavouriteManager.h"

@interface SNCorpusAlertObject () <SNClickSmallCorpusDelegate,SNNewAlertViewDelegate>

@property (nonatomic, strong) SNNewAlertView *corpusAlert;

@end

@implementation SNCorpusAlertObject

+ (void)showEmptyCorpusAlert {
    UIImage *img = [UIImage imageNamed:@"icotooltip_bj3_v5.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 28, imageView.width - 30, 0)];
    titleLabel.text = @"收藏了这么多文章,乱了吧?建几个文件夹整理下吧!";
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.numberOfLines = 0;
    [titleLabel sizeToFit];
    [imageView addSubview:titleLabel];
    UIImageView *iconV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icotooltip_rightfox_v5.png"]];
    [imageView addSubview:iconV];
    iconV.origin = CGPointMake(imageView.width - iconV.width, 0);
    
    SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithContentView:imageView cancelButtonTitle:@"我知道了" otherButtonTitle:@"新建收藏夹" alertStyle:SNNewAlertViewStyleAlert];
    [alertView show];
    
    [alertView actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
        TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://creatCorpus"] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
    }];
}


- (void)showCorpusAlertMenu:(BOOL)isMove {
    SNSmallCorpusView *corpusView = [[SNSmallCorpusView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, [self calcuCorpusMenuHeightWithIsMove:isMove])];
    corpusView.delegate = self;
    corpusView.corpusListArray = self.corpusListArray;
    corpusView.entry = self.entry;
    [corpusView setInfoWithCorpusName:nil isMove:isMove];
    self.corpusAlert = [[SNNewAlertView alloc] initWithContentView:corpusView cancelButtonTitle:@"取消" otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    self.corpusAlert.delegate = self;
    [self.corpusAlert show];
}

- (CGFloat)calcuCorpusMenuHeightWithIsMove:(BOOL)isMove {
    CGFloat height = 8.0f;
    if (isMove) {
        if (self.corpusListArray.count > 3) {
            height += 4 * kSmallCorpusTabelCellHeight + 28.0;
        } else {
            height += (self.corpusListArray.count + 1) * kSmallCorpusTabelCellHeight + 8.0;
        }
    } else {
        if (self.corpusListArray.count > 2) {
            height += 4 * kSmallCorpusTabelCellHeight + 28.0;
        } else {
            height += (self.corpusListArray.count + 2) * kSmallCorpusTabelCellHeight + 8.0;
        }
    }
    return height;
}


#pragma mark - SNClickSmallCorpusDelegate

- (void)clickSmallItemDelegate:(NSDictionary *)dict {
    if ([self.delegate respondsToSelector:@selector(clikItemOnHalfFloatView:)]) {
        [self.delegate clikItemOnHalfFloatView:dict];
    }
    [self.corpusAlert dismiss];
}

#pragma mark - SNNewAlertViewDelegate
- (void)willDisAppearAlertView:(SNNewAlertView *)alertView withButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 点击了取消按钮或者弹窗外部区域
        [SNMyFavouriteManager shareInstance].isHandleFavorite = NO;
        [SNMyFavouriteManager shareInstance].isFromArticle = NO;
    }
}

- (void)corpusAlertDismiss {
    [self.corpusAlert dismiss];
}


@end
