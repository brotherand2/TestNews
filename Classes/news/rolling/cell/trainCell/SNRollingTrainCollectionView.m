//
//  SNRollingTrainCollectionView.m
//  sohunews
//
//  Created by HuangZhen on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainCollectionView.h"

@interface SNRollingTrainCollectionView ()

@end

@implementation SNRollingTrainCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self registAllCells];
    }
    return self;
}
- (void)registAllCells {
    [self registerClass:[SNRollingTrainCollectionBaseCell class]
            forCellWithReuseIdentifier:kSNRollingTrainCollectionBaseCellIdentifier];
    [self registerClass:[SNRollingTrainImageTextCell class]
            forCellWithReuseIdentifier:kSNRollingTrainImageTextCellIdentifier];
    [self registerClass:[SNRollingTrainPGCVideoCell class]
            forCellWithReuseIdentifier:kSNRollingTrainPGCVideoCellIdentifier];
    
    [self registerClass:[SNTrainLoadMoreViewCell class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
            withReuseIdentifier:kSNTrainLoadMoreViewCellIdentifier];
}

@end
