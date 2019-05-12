//
//  SNChannelLayoutManager.m
//  sohunews
//
//  Created by jojo on 13-10-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNChannelLayoutManager.h"
#import "SNChannelManageContants.h"
#import "SNChannelView.h"

@implementation SNChannelLayoutHolder
@synthesize isDull;
@synthesize guestCenter;
@synthesize guestView = _guestView;

- (void)dealloc {
}

- (void)letitgo {
    self.guestView.center = self.guestCenter;
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface SNChannelLayoutManager ()

@property (nonatomic, strong) SNChannelLayoutHolder *blankOutlineHolder;
@property (nonatomic, strong) UIImageView *outlineView;

@end

@implementation SNChannelLayoutManager
@synthesize maxColumnSize;
@synthesize startY = _startY;
@synthesize totalHeight;
@synthesize sideMargin;
@synthesize topMargin;
@synthesize bottomMargin;
@synthesize spacingHorizen;
@synthesize spacingVertical;
@synthesize guestViewSize;
@synthesize guestExpandSize;
@synthesize guests = _guests;
@synthesize blankOutlineHolder = _blankOutlineHolder;
@synthesize outlineView = _outlineView;
@synthesize channelsContainer;

- (id)init {
    self = [super init];
    if (self) {
        self.maxColumnSize = kChannelMaxRowCount;
        self.sideMargin = kChannelAreaLeftDistance;
        self.topMargin = kIconNormalSettingMyChannelTextTopDistance + kIconNormalSettingMyChannelTextBellowDistance + kThemeFontSizeC + 10;
        self.bottomMargin = kIconNormalSettingMyChannelTextTopDistance;
        self.spacingHorizen = 0 / 2;
        self.spacingVertical = kVerticalDistanceBetweenChannels;
        self.guestViewSize = CGSizeMake(kChannelTitleWidth, kChannelTitleHeight);
        self.guestExpandSize = CGSizeMake(140 / 2, 86 / 2);
        self.isChannelMoveOut = YES;
    }
    return self;
}

- (void)dealloc {
    self.channelsContainer = nil;    
}

- (NSMutableArray *)guests {
    if (!_guests) {
        _guests = [[NSMutableArray alloc] init];
    }
    return _guests;
}

- (SNChannelLayoutHolder *)blankOutlineHolder {
    if (!_blankOutlineHolder) {
        _blankOutlineHolder = [[SNChannelLayoutHolder alloc] init];
    }
    return _blankOutlineHolder;
}

- (UIImageView *)outlineView {
    if (!_outlineView) {
        UIImage *image = [UIImage imageNamed:@"channel_manage_outline.png"];
        _outlineView = [[UIImageView alloc] initWithImage:image];
        _outlineView.alpha = 0.0;
    }
    return _outlineView;
}

- (SNChannelView *)buildChannelViewWithChannelObj:(SNChannelManageObject *)chObj {
    SNChannelView *chView = nil;
    Class cls = NULL;
    if (chObj.channelViewClassString.length > 0 &&
        (cls = NSClassFromString(chObj.channelViewClassString)) &&
        [[cls new] isKindOfClass:[SNChannelView class]]) {
        chView = [[cls alloc] initWithFrame:CGRectMake(0, 0,
                                                       self.guestViewSize.width + 15,
                                                       self.guestViewSize.height + 15)];
    } else {
        chView = [[SNChannelView alloc] initWithFrame:CGRectMake(0, 0,
                                                                 self.guestViewSize.width,
                                                                 self.guestViewSize.height)];
    }
    
    chView.chObj = chObj;
    
    return chView;
}

- (SNChannelLayoutHolder *)appendAGuestView:(UIView *)guestView {
    SNChannelLayoutHolder *aHd = [[SNChannelLayoutHolder alloc] init];
    aHd.guestView = guestView;
    if ([guestView isKindOfClass:[SNChannelView class]]) {
        aHd.isDull = [(SNChannelView *)guestView isDull];
    }
    
    [self.guests addObject:aHd];
    return aHd;
}

- (void)appendAGuestViewHolder:(SNChannelLayoutHolder *)hd {
    if (hd) {
        if (self.isMyChannelManager) {
            [self.guests removeObject:hd];
            [self.guests addObject:hd];
        }
        else {
            NSInteger insertIndex = 0;
            if (self.tempChannelIndex != 0) {
                insertIndex = self.tempChannelIndex - 1;
                self.tempChannelIndex = 0;
            }
            else {
                insertIndex = [self getHolderIndex:hd];
            }
            [self.guests removeObject:hd];
            if (insertIndex < [self.guests count]) {
                [self.guests insertObject:hd atIndex:insertIndex];
            }
            else {
                [self.guests addObject:hd];
            }
        }
    }
    
    [self clearBlankOutline];
}

- (void)insertAGuestViewHolder:(SNChannelLayoutHolder *)hd atIndex:(NSInteger)index {
    if (hd) {
        __block NSInteger lastDullIndex = -1;
        [self.guests enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNChannelLayoutHolder *hd = obj;
            if (hd.isDull) {
                lastDullIndex = idx;
                *stop = YES;
            }
        }];
        
        // 需要考虑强制置顶的情况
        if (lastDullIndex != -1 && index <= lastDullIndex) {
            // 这种情况 添加到强制置顶的后面
            index = lastDullIndex + 1;
        }
        
        if (index >= 0 && index < self.guests.count) {
            if (self.isMyChannelManager) {
                [self.guests insertObject:hd atIndex:index];
            }
            else {
                NSInteger insertIndex = [self getHolderIndex:hd];
                if (insertIndex < [self.guests count]) {
                    [self.guests insertObject:hd atIndex:insertIndex];
                }
                else {
                    [self.guests addObject:hd];
                }
            }
        }
        else {
            if (self.isMyChannelManager) {
                [self.guests addObject:hd];
            }
            else {
                NSInteger insertIndex = [self getHolderIndex:hd];
                if (insertIndex < [self.guests count]) {
                    [self.guests insertObject:hd atIndex:insertIndex];
                }
                else {
                    [self.guests addObject:hd];
                }
            }
        }
    }
    
    [self clearBlankOutline];
}

- (void)clearBlankOutline {
    [self.guests removeObject:self.blankOutlineHolder];
}

- (SNChannelLayoutHolder *)removeAGuestView:(UIView *)guestView {
    SNChannelLayoutHolder *hdFound = nil;
    for (SNChannelLayoutHolder *hd in self.guests) {
        if (hd.guestView == guestView) {
            hdFound = hd;
            break;
        }
    }
    
    if (hdFound) {
        SNChannelView *channelView = (SNChannelView *)hdFound.guestView;
        if ([channelView.chObj.isSubed isEqualToString:@"1"]) {
            self.tempChannelIndex = 0;
        }
        else {
            self.tempChannelIndex = [self getHolderIndex:hdFound];
        }
        [self.guests removeObject:hdFound];
    }
    
    return hdFound;
}

- (CGPoint)centerPointForGuestViewIndex:(int)index {
    if (index > 0 && index < self.guests.count) {
        SNChannelLayoutHolder *holder = [self.guests objectAtIndex:index];
        return holder.guestCenter;
    }
    // 扔到屏幕外面
    return CGPointMake(-100, -100);
}

- (void)calculateAllGuestViews {
    if (!self.isMyChannelManager) {
        [self updateChannelsArray];
    }
    CGFloat x = 0, y = 0;
    for (int index = 0; index < self.guests.count; ++index) {
        SNChannelLayoutHolder *hd = [self.guests objectAtIndex:index];
        if (self.isMyChannelManager) {
            x = self.sideMargin;
            x += (index % self.maxColumnSize) * (self.guestViewSize.width + kHorizenDistanceBetweenChannels);
            y = self.topMargin + self.startY;
            y += (index / self.maxColumnSize) * (self.guestViewSize.height + self.spacingVertical);
            hd.guestCenter = CGPointMake(x + self.guestViewSize.width / 2 , y + self.guestViewSize.height / 2);
        }
        else {
            NSString *nextCategoryID = nil;
            if (index + 1 < self.guests.count) {
                SNChannelLayoutHolder *nextHd = [self.guests objectAtIndex:index + 1];
                SNChannelView *nextChannelView = (SNChannelView *)nextHd.guestView;
                nextCategoryID = nextChannelView.chObj.channelCategoryID;
            }
            SNChannelView *channelView = (SNChannelView *)hd.guestView;
            CGPoint point = [self resetPoint:channelView.chObj.channelCategoryID nextCategoryID:nextCategoryID categoryName:channelView.chObj.channelCategoryName];
            hd.guestCenter = CGPointMake(point.x + self.guestViewSize.width / 2 , point.y + self.guestViewSize.height / 2);
        }
    }
    
    if (self.guests.count > 0) {
        SNChannelLayoutHolder *lastHd = self.guests.lastObject;
        self.totalHeight = lastHd.guestCenter.y + self.guestViewSize.height / 2 + self.bottomMargin - self.startY;
    }
    else {
        self.totalHeight = kChannelEmptyHeight + self.bottomMargin;
    }
    
    [self resetTempVariable];
}

- (void)layoutAllGuestViews {
    for (SNChannelLayoutHolder *hd in self.guests) {
        [hd letitgo];
    }
}

- (int)receiveHitAtPoint:(CGPoint)pt {
    NSInteger insertIndex = [self getHolderIndex:self.blankOutlineHolder];
    
    [self.guests removeObject:self.blankOutlineHolder];
    
    __block NSInteger lastDullIndex = -1;
    [self.guests enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SNChannelLayoutHolder *hd = obj;
        if (hd.isDull) {
            lastDullIndex = idx;
            *stop = YES;
        }
    }];
    
    int index = [self indexForPoint:pt];
    
    // 需要考虑强制置顶的情况
    if (lastDullIndex != -1 && index != -1 && index <= lastDullIndex) {
        // 这种情况我们什么也不做
        index = -1;
    }
    else {
        if (index >= 0) {
            if (index < self.guests.count) {
                if (self.isMyChannelManager) {
                    [self.guests insertObject:self.blankOutlineHolder atIndex:index];
                }
                else {
                    if (insertIndex< [self.guests count]) {
                        [self.guests insertObject:self.blankOutlineHolder atIndex:insertIndex];
                    }
                    else {
                        [self.guests addObject:self.blankOutlineHolder];
                    }
                }
            }
            else {
                if (self.isMyChannelManager) {
                    [self.guests addObject:self.blankOutlineHolder];
                }
                else {
                    if (insertIndex < [self.guests count]) {
                        [self.guests insertObject:self.blankOutlineHolder atIndex:insertIndex];
                    }
                    else {
                        [self.guests addObject:self.blankOutlineHolder];
                    }
                }
            }
        }
    }
    
    [self calculateAllGuestViews];
    return index;
}

- (void)showPositionOutLine:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        if (show) {
            self.outlineView.center = self.blankOutlineHolder.guestCenter;
            if (!self.outlineView.superview) {
                [self.channelsContainer addSubview:self.outlineView];
            }
            if (self.outlineView.alpha != 1) {
                [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
                    self.outlineView.alpha = 0;
                } completion:^(BOOL finished) {
                    ;
                }];
            }
        } else {
            [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
                self.outlineView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.outlineView removeFromSuperview];
            }];
        }
    } else {
        if (show) {
            self.outlineView.alpha = 0;
            self.outlineView.center = self.blankOutlineHolder.guestCenter;
            [self.outlineView removeFromSuperview];
            [self.channelsContainer addSubview:self.outlineView];
        } else {
            self.outlineView.alpha = 0;
            [self.outlineView removeFromSuperview];
        }
    }
}

- (int)totalCountOfChannelView {
    if ([self.guests containsObject:self.blankOutlineHolder]) {
        return (int)(self.guests.count - 1);
    }
    else {
        return (int)self.guests.count;
    }
}

#pragma mark - private

- (int)indexForPoint:(CGPoint)pos {
    
    int index = -1;
    int xIndex = 0;
    int yIndex = 0;
    BOOL isLineTail = NO;
    
    CGFloat dx = self.guestViewSize.width + self.spacingHorizen;
    CGFloat dy = self.guestViewSize.height + self.spacingVertical;
    CGFloat originY = self.startY + self.topMargin;
    
    CGFloat originX = self.sideMargin;
    CGFloat xOffset = pos.x - originX;
    CGFloat yOffset = pos.y - originY;
    
    if (xOffset < dx) {
        xIndex = 0;
    }
    else if (xOffset < (originX + self.maxColumnSize * dx)) {
        xIndex = (int)xOffset / (int)dx;
    }
    else {
        xIndex = 0;
        isLineTail = YES;
    }
    
    if (yOffset < dy) {
        yIndex = 0;
    }
    else {
        yIndex = (int)yOffset / (int)dy;
    }
    
    if (isLineTail) {
        yIndex++;
    }
    
    index = yIndex * self.maxColumnSize + xIndex;
    
    return index;
}

- (CGPoint)resetPoint:(NSString *)categoryID nextCategoryID:(NSString *)nextCategoryID categoryName:(NSString *)categoryName {
    CGPoint point = CGPointZero;
    BOOL tempB = NO;
    if ([categoryID isEqualToString:nextCategoryID]) {
        if (!_isReturnLine) {
            tempB = YES;
            _isReturnLine = YES;
            self.tempCategoryID = categoryID;
            _channelIndex = 0;
        }
        else {
            tempB = NO;
        }
    }
    else {
        if (![self.tempCategoryID isEqualToString:categoryID]) {
            tempB = YES;
            _isReturnLine = NO;
            _channelIndex = 0;
        }
        else {
            tempB = NO;
            _isReturnLine = NO;
        }
    }
    
    point = [self getPoint:tempB categoryName:categoryName categoryID:categoryID];
    return point;
}

- (CGPoint)getPoint:(BOOL)isCategoryHead categoryName:(NSString *)categoryName categoryID:(NSString *)categoryID {
    CGFloat cDistance = 50.0;
    CGPoint point = CGPointZero;
    _recordX = self.sideMargin;
    if (isCategoryHead) {
        if (_channelIndex > 0) {
            _channelIndex ++;
            _tailRecordY = _recordY + self.guestViewSize.height + 11;
            _recordY = cDistance + _tailRecordY;
            _tempRecordY = cDistance + _tailRecordY;
        }
        else {
            if (_tailRecordY == 0) {
                _recordY = self.topMargin + self.startY + cDistance;
            }
            else {
                _recordY += cDistance + self.guestViewSize.height + 11.0;
            }
            
            CGFloat categoryLabelY = _recordY - cDistance;
            [self setCategoryTitle:categoryName categoryID:categoryID pointY:categoryLabelY];
        
            _tailRecordY = _recordY;
            _tempRecordY = _recordY;
        }
        _channelIndex = 0;
    }
    else {
        _recordY = _tempRecordY;
        _channelIndex ++;
        _recordX += (_channelIndex % self.maxColumnSize) * (self.guestViewSize.width + kHorizenDistanceBetweenChannels);
        _recordY += (_channelIndex / self.maxColumnSize) * (self.guestViewSize.height + self.spacingVertical);
    }
    point = CGPointMake(_recordX, _recordY);
    return point;
}

- (NSInteger)getHolderIndex:(SNChannelLayoutHolder *)hd {
    if ([self.guests count] == 0) {
        return 0;
    }
    SNChannelView *channelView = (SNChannelView *)hd.guestView;
    NSString *selectCategoryID = channelView.chObj.channelCategoryID;
    NSInteger tailSameCategoryIDIndex = 0;
    //先判定有无对应的分类
    BOOL haveCategory = NO;
    for (int index = 0; index < [self.guests count]; index ++) {
        SNChannelLayoutHolder *newHd = [self.guests objectAtIndex:index];
        SNChannelView *newChannelView = (SNChannelView *)newHd.guestView;
        if ([newChannelView.chObj.channelCategoryID isEqualToString:selectCategoryID]) {
            haveCategory = YES;
            break;
        }
    }
    
    SNChannelLayoutHolder *firstHd = [self.guests objectAtIndex:0];
    SNChannelView *firstChannelView = (SNChannelView *)firstHd.guestView;
    NSString *firstCategoryID = firstChannelView.chObj.channelCategoryID;
    
    if (!haveCategory || [firstCategoryID isEqualToString:selectCategoryID]) {//没有此分类，则添加至第一个分类的末尾
        for (int index = 0; index < [self.guests count]; index ++) {
            SNChannelLayoutHolder *newHd = [self.guests objectAtIndex:index];
            SNChannelView *newChannelView = (SNChannelView *)newHd.guestView;
            if ([firstCategoryID isEqualToString:newChannelView.chObj.channelCategoryID]) {
                tailSameCategoryIDIndex ++;
            }
        }
    }
    else {
        NSInteger beginIndex = 0;
        for (int index = 0; index < [self.guests count]; index ++) {
            SNChannelLayoutHolder *newHd = [self.guests objectAtIndex:index];
            SNChannelView *newChannelView = (SNChannelView *)newHd.guestView;
            if ([newChannelView.chObj.channelCategoryID isEqualToString:selectCategoryID]) {
                if (beginIndex == 0) {
                    beginIndex = index;
                }
                tailSameCategoryIDIndex ++;
            }
        }
        tailSameCategoryIDIndex += beginIndex;
    }
    return tailSameCategoryIDIndex;
}

- (void)setCategoryTitle:(NSString *)title categoryID:(NSString *)categoryID pointY:(CGFloat)pointY {
    if (!self.isMyChannelManager && !self.isChannelMoveOut) {
        return;
    }
    for (UIView *view in self.channelsContainer.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if (label.tag == [[NSString stringWithFormat:@"10000%@", categoryID] integerValue]) {
                label.top = pointY + 17.0;
                return;
            }
        }
    }
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = SNUICOLOR(kThemeText2Color);
    label.text = title;
    label.font = [UIFont systemFontOfSize:kThemeFontSizeG];
    [label sizeToFit];
    label.top = pointY + 17.0;
    label.left = 14.0;
    label.tag = [[NSString stringWithFormat:@"10000%@", categoryID] integerValue];
    [self.channelsContainer addSubview:label];
}

- (void)removeEmptyCategoryLabel {//移除空category
    for (UIView *view in self.channelsContainer.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            BOOL isRemoveLabel = YES;
            NSString *labelTag = [NSString stringWithFormat:@"%d", label.tag];
            if (![labelTag hasPrefix:@"10000"]) {
                continue;
            }
            for (SNChannelLayoutHolder *hd in self.guests) {
                SNChannelView *channelView = (SNChannelView *)hd.guestView;
                if ([labelTag isEqualToString:[NSString stringWithFormat:@"10000%@", channelView.chObj.channelCategoryID]]) {
                    isRemoveLabel = NO;
                    break;
                }
            }
            if (isRemoveLabel) {
                [label removeFromSuperview];
            }
        }
    }
}

- (void)resetTempVariable {
    _isReturnLine = NO;
    _tempCategoryID = nil;
    _recordX = 0;
    _recordY = 0;
    _tailRecordY = 0;
    _channelIndex = 0;
    _tempRecordY = 0;
    _tempChannelIndex = 0;
}

- (NSMutableArray *)updateChannelsArray {
    //时间复杂度过大，待优化？？？
    NSString *categoryNames = [SNUserDefaults objectForKey:kSavedChannelCategoryKey];
    if (!categoryNames) {
        return self.guests;
    }
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *categoryArray = [categoryNames componentsSeparatedByString:@","];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.guests];
    for (NSString *name in categoryArray) {
        for (int i = 0; i < [tempArray count]; i ++) {
            SNChannelLayoutHolder *hd = [tempArray objectAtIndex:i];
            SNChannelView *channelView = (SNChannelView *)hd.guestView;
            if ([channelView.chObj.channelCategoryName isEqualToString:name]) {
                [newArray addObject:hd];
                [self.guests removeObject:hd];
            }
        }
    }
    
    if ([self.guests count] > 0) {
        [newArray addObjectsFromArray:self.guests];
        [self.guests removeAllObjects];
    }
    
    self.guests = [NSMutableArray arrayWithArray:newArray];
    
    [newArray removeAllObjects];
    [tempArray removeAllObjects];
    
    return self.guests;
}

- (void)updateTheme {
    for (UIView *view in self.channelsContainer.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            NSString *labelTag = [NSString stringWithFormat:@"%d", label.tag];
            if ([labelTag hasPrefix:@"10000"]) {
                label.textColor = SNUICOLOR(kThemeText2Color);
            }
        }
    }
}

@end
