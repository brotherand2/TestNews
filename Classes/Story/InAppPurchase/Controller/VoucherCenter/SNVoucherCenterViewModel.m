//
//  SNVoucherCenterViewModel.m
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNVoucherCenterViewModel.h"
#import "SNProductCell.h"
#import "SNAccountBalanceView.h"
#import "SNPayButtonView.h"
#import "SNVoucherCenter.h"

#define SNProductCellReuseIdentifier @"SNProductCellReuseIdentifier"
#define SNAccountBalanceViewReuseIdentifier @"SNAccountBalanceViewReuseIdentifier"
#define SNPayButtonViewReuseIdentifier @"SNPayButtonViewReuseIdentifier"

@interface SNVoucherCenterViewModel ()<SNPayButtonViewDelegate> {
    BOOL _defaultSelect;//用于设置默认选择的充值金额
}

@property (nonatomic, strong) SNProductCell * lastSelectedCell;

@end

@implementation SNVoucherCenterViewModel

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)registAllCell {
    
    [self.controller.collectionView registerClass:[SNProductCell class] forCellWithReuseIdentifier:SNProductCellReuseIdentifier];
    [self.controller.collectionView registerClass:[SNAccountBalanceView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SNAccountBalanceViewReuseIdentifier];
    [self.controller.collectionView registerClass:[SNPayButtonView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SNPayButtonViewReuseIdentifier];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SNAccountBalanceViewReuseIdentifier forIndexPath:indexPath];
        return header;
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        SNPayButtonView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SNPayButtonViewReuseIdentifier forIndexPath:indexPath];
        footer.delegate = self;
        return footer;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SNProductCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SNProductCellReuseIdentifier forIndexPath:indexPath];
    NSDictionary * info = [_products objectAtIndex:indexPath.row];
    [cell update:info];
    ///设置默认选中的金额
    if (indexPath.row == 0 && !_defaultSelect) {
        _defaultSelect = YES;
        cell.selected = YES;
        self.lastSelectedCell = cell;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _products.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SNProductCell * selectCell = (SNProductCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (selectCell != self.lastSelectedCell) {
        selectCell.selected = YES;
        self.lastSelectedCell.selected = NO;
        self.lastSelectedCell = selectCell;
    }
}

- (void)payButtonClicked:(UIButton *)sender {
    [SNVoucherCenter rechargeWithProductId:_lastSelectedCell.productId quantity:_lastSelectedCell.quantity completed:^(BOOL successed) {
        [self.controller rechargeDidFinished:successed];
    }];
}

@end
