//
//  SHTodayWidgetContentView.m
//  LiteSohuNews
//
//  Created by wangyy on 15/10/28.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//


#import "SNTodayWidgetContentView.h"
#import "SNTodayWidgetContentCollectionTitleViewCell.h"
#import "SNTodayWidgetContentCollectionImgViewCell.h"
#import "SNTodayWidgetContentCollectionGroupPhotoCell.h"
#import "SNMoreCollectionViewCell.h"

@interface SNTodayWidgetContentView ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *newsList;

@end

@implementation SNTodayWidgetContentView

@synthesize collectionView = _collectionView;
@synthesize newsList = _newsList;
@synthesize delegate = _delegate;

- (void)dealloc{
    self.collectionView = nil;
    self.newsList = nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.collectionView registerClass:[SNTodayWidgetContentCollectionTitleViewCell class] forCellWithReuseIdentifier:[self titleCellIdentifier]];
        [self.collectionView registerClass:[SNTodayWidgetContentCollectionImgViewCell class] forCellWithReuseIdentifier:[self imageCellIdentifier]];
        [self.collectionView registerClass:[SNTodayWidgetContentCollectionGroupPhotoCell class] forCellWithReuseIdentifier:[self groupPhotoCellIdentifier]];
        [self.collectionView registerClass:[SNMoreCollectionViewCell class] forCellWithReuseIdentifier:[self moreCollectionViewCell]];
        
        
        [self addSubview:self.collectionView];
    }
    
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark Func

- (void)reload:(NSArray *)newsList{
    self.newsList = [NSArray arrayWithArray:newsList];
    [self.collectionView reloadData];
}

- (CGFloat)heightForNewsList:(NSArray *)newsList {
    CGFloat height = 0.0f;
    //所有cell的总高度
    for (SNTodayWidgetNews *news in newsList) {
        height += [SNTodayWidgetContentCollectionTitleViewCell cellHeightForNews:news width:self.bounds.size.width];
    }
    
    //更多按钮的高度
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        height += kMoreNewsSectionHeight;
    }
    else
    {
        height += 64;
    }
    
    return height;
}

#pragma mark UICollectionViewDataSource

- (NSString *)titleCellIdentifier{
    return @"TodayWidgetContentCollectionTitleViewCellIdentifier";
}

- (NSString *)imageCellIdentifier{
    return @"TodayWidgetContentCollectionImageViewCellIdentifier";
}

- (NSString *)groupPhotoCellIdentifier{
    return @"TodayWidgetContentCollectiongroupPhotoViewCellIdentifier";
}

- (NSString *)moreCollectionViewCell{
    return @"SNMoreCollectionViewCell";
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.newsList.count == 0) {
        return 0;
    }
    return self.newsList.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.newsList.count) {
        SNMoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self moreCollectionViewCell] forIndexPath:indexPath];
        
        return cell;
    }
    
    SNTodayWidgetContentCollectionTitleViewCell *cell = nil;
    SNTodayWidgetNews *news = [self.newsList objectAtIndex:indexPath.row];
    
    if (news.imgURLArray.count >= 3) {//组图新闻
        cell = (SNTodayWidgetContentCollectionGroupPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[self groupPhotoCellIdentifier] forIndexPath:indexPath];
    }
    else if (news.imgURLArray.count == 1) {//图文新闻
        cell = (SNTodayWidgetContentCollectionImgViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[self imageCellIdentifier] forIndexPath:indexPath];
    }
    else {//纯文新闻
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self titleCellIdentifier] forIndexPath:indexPath];
    }
    
    [cell configureCellWithRowNews:news];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (row < self.newsList.count) {
        SNTodayWidgetNews *news = [self.newsList objectAtIndex:indexPath.row];
        if ([self.delegate respondsToSelector:@selector(didSelectNews:)]) {
            [self.delegate didSelectNews:news];
        }
    }
    else{
        if ([_delegate respondsToSelector:@selector(didTapOnMoreNewsBtnInContentView:)]) {
            [_delegate didTapOnMoreNewsBtnInContentView:self];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.newsList.count) {
        SNTodayWidgetNews *news = [self.newsList objectAtIndex:indexPath.row];
        return CGSizeMake(self.bounds.size.width, [SNTodayWidgetContentCollectionTitleViewCell cellHeightForNews:news width:self.bounds.size.width]);
    } else {
        
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            
            return CGSizeMake(self.bounds.size.width, kMoreNewsSectionHeight);
        }
        else
        {
            return CGSizeMake(self.bounds.size.width, 64);
        }
        
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];

    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"vbg.png"]];
    [cell setBackgroundColor:color];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
