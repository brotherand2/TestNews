//
//  SNMultiColumnTableView.m
//  sohunews
//
//  Created by jojo on 13-9-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMultiColumnTableView.h"

#define kMultiColumnViewTagStart            (100)

NSIndexPath * cellIndexPathToViewIndexPath(NSIndexPath *cellIndexpath, NSInteger numberOfCol, NSInteger viewIndex) {
    return [NSIndexPath indexPathForRow:cellIndexpath.row * numberOfCol + viewIndex inSection:cellIndexpath.section];
}

NSIndexPath * viewIndexPathToCellIndexPath(NSIndexPath *viewIndexPath, NSInteger numberOfCol) {
    return [NSIndexPath indexPathForRow:viewIndexPath.row / numberOfCol inSection:viewIndexPath.section];
}

NSInteger viewTagIndex(NSIndexPath *viewIndexPath, NSInteger numberOfCol) {
    return viewIndexPath.row % numberOfCol + kMultiColumnViewTagStart;
}

#pragma mark - SNMultiColumnTableViewCell

@interface SNMultiColumnTableViewCell : UITableViewCell <SNMultiColumnTableViewReuseViewProvider>

@property (nonatomic, assign) NSInteger numberOfColumn;
@property (nonatomic, strong) NSMutableArray *reusableViews;

- (void)addSubview:(UIView *)view atIndex:(NSInteger)index;

@end

@implementation SNMultiColumnTableViewCell
@synthesize numberOfColumn;
@synthesize reusableViews = _reusableViews;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
     //(_reusableViews);
}

- (NSMutableArray *)reusableViews {
    if (!_reusableViews) {
        _reusableViews = [[NSMutableArray alloc] init];
    }
    return _reusableViews;
}

- (void)addSubview:(UIView *)view atIndex:(NSInteger)index {
#pragma unused(index)
    
    [view removeFromSuperview];
    [self addSubview:view];
    
    [self.reusableViews removeObject:view];
    [self.reusableViews addObject:view];
}

- (UIView *)reusableViewForIndexPath:(NSIndexPath *)indexPath {
    return [self viewWithTag:viewTagIndex(indexPath, self.numberOfColumn)];
}

- (void)clearAllReusableViews {
    for (UIView *aView in self.reusableViews) {
        [aView removeFromSuperview];
    }
    [self.reusableViews removeAllObjects];
}

- (void)clearReusableViewForIndexPath:(NSIndexPath *)indexPath {
    UIView *viewToClear = [self reusableViewForIndexPath:indexPath];
    [viewToClear removeFromSuperview];
    [self.reusableViews removeObject:viewToClear];
}

@end

#pragma mark - SNMultiColumnTableView

@implementation SNMultiColumnTableView
@synthesize mcDelegate = _mcDelegate;

- (void)dealloc {
    self.mcDelegate = nil;
}

#pragma mark - public methods

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
#pragma unused(style)
    // ignore style
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    
    if (self) {
        // remove cell separator
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (NSInteger)numberOfColumnInSection:(NSInteger)section {
    NSInteger numberOfColumn = 1;
    BOOL shouldUseCustomCell = NO;
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:shouldUseCustomCellInSection:)])
        shouldUseCustomCell = [self.mcDelegate mcTableView:self shouldUseCustomCellInSection:section];
    
    if (!shouldUseCustomCell &&
        (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:numberOfColumnInSection:)]))
        numberOfColumn = [self.mcDelegate mcTableView:self numberOfColumnInSection:section];
    
    return numberOfColumn;
}

- (CGFloat)defaultCellHeight {
    return 50;
}

#pragma mark - UITableView datasource & delegate

// default return 1;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(numberOfSectionInMCTableView:)])
        return [self.mcDelegate numberOfSectionInMCTableView:self];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:numberOfItemsInSeciont:)]) {
        NSInteger rowsInSection = [self.mcDelegate mcTableView:self numberOfItemsInSeciont:section];
        NSInteger numberOfColumn = [self numberOfColumnInSection:section];
        return (rowsInSection % numberOfColumn == 0) ? rowsInSection / numberOfColumn : rowsInSection / numberOfColumn + 1;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:heightForRowInSection:)])
        cellHeight = [self.mcDelegate mcTableView:self heightForRowInSection:indexPath.section];
    
    if (cellHeight == 0)
        cellHeight = [self defaultCellHeight];
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:heightForHeaderInSection:)])
        return [self.mcDelegate mcTableView:self heightForHeaderInSection:section];
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:viewForHeaderInSection:)])
        return [self.mcDelegate mcTableView:self viewForHeaderInSection:section];
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:willDisplayCell:forRowAtIndexPath:)])
        [self.mcDelegate mcTableView:self willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *customCell = nil;
    BOOL shouldUseCustomCell = NO;
    
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:cellAtIndexPath:)])
        customCell = [self.mcDelegate mcTableView:self cellAtIndexPath:indexPath];
    
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:shouldUseCustomCellInSection:)])
        shouldUseCustomCell = [self.mcDelegate mcTableView:self shouldUseCustomCellInSection:indexPath.section];
    
    if (customCell && shouldUseCustomCell) return customCell;
    
    NSString *cellIdty = [NSString stringWithFormat:@"cellInSection%ld", (long)indexPath.section];
    SNMultiColumnTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:cellIdty];
    if (!aCell) {
        aCell = [[SNMultiColumnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdty];
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSInteger itemsInSection = 0;
    NSInteger numberOfColumn = [self numberOfColumnInSection:indexPath.section];
    CGFloat cellHeight = 0;
    
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:heightForRowInSection:)])
        cellHeight = [self.mcDelegate mcTableView:self heightForRowInSection:indexPath.section];
    
    if (0 == cellHeight)
        cellHeight = [self defaultCellHeight];
    
    aCell.numberOfColumn = numberOfColumn;
    // hide all custom views
    for (UIView *aView in aCell.reusableViews) {
        aView.hidden = YES;
    }
    
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:numberOfItemsInSeciont:)])
        itemsInSection = [self.mcDelegate mcTableView:self numberOfItemsInSeciont:indexPath.section];
    
    if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:viewForIndexPath:fromProvider:)]) {
        for (int index = 0; index < numberOfColumn; ++index) {
            
            NSIndexPath *viewIndexPath = cellIndexPathToViewIndexPath(indexPath, numberOfColumn, index);
            if (viewIndexPath.row < itemsInSection) {
                NSIndexPath *viewIndexPath = cellIndexPathToViewIndexPath(indexPath, numberOfColumn, index);
                
                UIView *colView = [self.mcDelegate mcTableView:self
                                              viewForIndexPath:viewIndexPath
                                                  fromProvider:aCell];
                // 设置tag
                if (!colView.superview) colView.tag = kMultiColumnViewTagStart + index;
                
                CGRect viewFrame = CGRectZero;
                if (self.mcDelegate && [self.mcDelegate respondsToSelector:@selector(mcTableView:viewFrameAtIndexPath:andViewIndex:)])
                    viewFrame = [self.mcDelegate mcTableView:self viewFrameAtIndexPath:viewIndexPath andViewIndex:index];
                
                if (!CGRectIsEmpty(viewFrame)) {
                    colView.frame = viewFrame;
                }
                // 按每个列的宽度 居中在每个列
                else {
                    int sectionWidth = tableView.width / numberOfColumn;
                    colView.centerY = cellHeight / 2;
                    colView.centerX = sectionWidth * index + sectionWidth / 2;
                }
                
                [aCell addSubview:colView atIndex:index];
                colView.hidden = NO;
            }
        }
    }
    
    return aCell;
}

@end

