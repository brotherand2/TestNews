//
//  SNShareCollectionViewLayout.m
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareCollectionViewLayout.h"

static CGFloat itemSpacing = 0.0f;
static CGFloat lineSpacing = 0.0f;
static long    pageNumber  = 1;
@interface SNShareCollectionViewLayout()

@property (nonatomic, strong) NSMutableArray * attributes;

@end


@implementation SNShareCollectionViewLayout
{
    int _row;
    int _col;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.attributes = [NSMutableArray new];
    }
    return self;
}


- (void)prepareLayout {
    [super prepareLayout];
    
    CGFloat itemWidth  = self.itemSize.width;
    CGFloat itemHeight = self.itemSize.height;
    
    CGFloat width  = self.collectionView.frame.size.width;
    CGFloat height = self.collectionView.frame.size.height;
    
    CGFloat contentWidth = (width - self.sectionInset.left - self.sectionInset.right);
    
    // 如果列数大于 2 行
    if (contentWidth >= (2 * itemWidth + self.minimumInteritemSpacing)) {
        NSInteger m = (contentWidth - itemWidth) / (itemWidth + self.minimumInteritemSpacing);
        _col = m + 1;
        NSInteger n = (NSInteger)(contentWidth - itemWidth) % (NSInteger)(itemWidth + self.minimumInteritemSpacing);
        if (n > 0) {
            double offset = ((contentWidth - itemWidth) - m * (itemWidth + self.minimumInteritemSpacing)) / m;
            itemSpacing = self.minimumInteritemSpacing + offset;
        } else if (n == 0) {
            itemSpacing = self.minimumInteritemSpacing;
        }
        // 如果列数为 1 行
    } else {
        _col = 1;  // 注意不为0 10.0后模拟器会崩，真机没问题
        itemSpacing = 0;
    }
    CGFloat contentHeight = (height - self.sectionInset.top - self.sectionInset.bottom);
    // 如果行数大于 2 行
    if (contentHeight >= (2 * itemHeight + self.minimumLineSpacing)) {
        NSInteger m = (contentHeight - itemHeight) / (itemHeight + self.minimumLineSpacing);
        _row = m + 1;
        NSInteger n = (NSInteger)(contentHeight - itemHeight) % (NSInteger)(itemHeight + self.minimumLineSpacing);
        if (n > 0) {
            double offset = ((contentHeight - itemHeight) - m * (itemHeight + self.minimumLineSpacing)) / m;
            lineSpacing = self.minimumLineSpacing + offset;
        } else if (n == 0) {
            lineSpacing = self.minimumInteritemSpacing;
        }
        // 如果行数数为 1 行
    } else {
        _row = 1; // 注意不为0 10.0后模拟器会崩，真机没问题
        lineSpacing = 0;
    }
    NSInteger itemNumber = 0;
    itemNumber = itemNumber + (NSInteger)[self.collectionView numberOfItemsInSection:0];
    // 注意不为0 10.0后模拟器会崩，真机没问题
    pageNumber = itemNumber == 1 ? 1 : (itemNumber - 1) / (_row * _col) + 1;
}


#pragma mark - collectionView 的整体滚动区域
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width * pageNumber, self.collectionView.bounds.size.height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes * attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGRect frame;
    frame.size = self.itemSize;
    long number = _row * _col;
    long m = 0;
    long p = 0;
    if (indexPath.item >= number) {
        p = indexPath.item / number;
        m = (indexPath.item % number) / _col;
    } else {
        m = indexPath.item / _col;
    }
    
    long n = indexPath.item % _col;
    frame.origin = CGPointMake(n * self.itemSize.width + n * itemSpacing + self.sectionInset.left + (indexPath.section + p) * self.collectionView.frame.size.width, m * self.itemSize.height + m * lineSpacing + self.sectionInset.top);
    
    attribute.frame = frame;
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray * tmpAttributes = [NSMutableArray new];
    for (int j = 0; j < self.collectionView.numberOfSections; j ++) {
        NSInteger count = [self.collectionView numberOfItemsInSection:j];
        for (NSInteger i = 0; i < count; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:j];
            [tmpAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    self.attributes = tmpAttributes;
    return self.attributes;
}

@end
