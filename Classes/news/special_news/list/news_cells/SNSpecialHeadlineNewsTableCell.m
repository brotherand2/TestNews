//
//  sohunews
//
//  Created by Handy Wang on 7/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNConsts.h"

#import "SNSpecialNews.h"
#import "SNSpecialHeadlineNewsTableCell.h"
#import "SNCommonNewsController.h"
#import "SNCommonNewsDatasource.h"
#import "NSCellLayout.h"
#import "SNSpecialNews.h"

#define kRowHeight (106/2)

#define horizontalPadding                           (10)
#define textWidth                                   (300)
#define fontSize                                    (13)
#define kHeadlineAbstractLineHeight                 (40/2)
#define kCellContentColor                           RGBCOLOR(75, 75, 70)

#define kCellTopInset                   (8)
#define kImageTopMargin                 ((18 / 2) + kCellTopInset)
#define kImageSideMargin                (20 / 2)

@implementation SNSpecialHeadlineNewsTableCell

- (SNLabel *)abstractLabel {
    if (!_abstractLabel) {
        _abstractLabel = [[SNLabel alloc] initWithFrame:CGRectMake(horizontalPadding,
                                                                   self.headlineView.bottom + horizontalPadding,
                                                                   TTScreenBounds().size.width - kTableCellMargin * 2,                                                0)];
        _abstractLabel.font = [UIFont systemFontOfSize:fontSize];
        _abstractLabel.backgroundColor = [UIColor clearColor];
        _abstractLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
        [_abstractLabel setLineHeight:kHeadlineAbstractLineHeight];
        [self addSubview:_abstractLabel];
    }
    return _abstractLabel;
}

#pragma mark - Lifecycle methods

-(void)dealloc {
     //(_abstractLabel);
     //(_specialItem);
    
}

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    
    SNSpecialHeadlineNewsTableItem *specialItem = (SNSpecialHeadlineNewsTableItem *)object;
    
    int cellHeight = kImageTopMargin + FOCUS_IMAGE_HEIGHT + kCellTopInset - 5;
    
    if (specialItem.headlines.count > 0) {
        SNSpecialNews *news = [specialItem.headlines objectAtIndex:0];
        
        CGFloat textHeight = [SNLabel heightForContent:news.abstract
                                              maxWidth:TTScreenBounds().size.width - kTableCellMargin * 2
                                                  font:fontSize
                                            lineHeight:kHeadlineAbstractLineHeight];

        if ([[SNDevice sharedInstance] isPhone6] ) {
            return cellHeight + textHeight + horizontalPadding + 20;
        }
        if ([[SNDevice sharedInstance] isPlus]) {
            return cellHeight + textHeight + horizontalPadding + 40;
        }
        return cellHeight + textHeight + horizontalPadding ;
    }
    
    return cellHeight;
}

+ (CGFloat)cellHeight {
    return kImageTopMargin + FOCUS_IMAGE_HEIGHT + kCellTopInset - 5;
}

- (void)setObject:(id)object {
    self.specialItem = object;
    [self updateNews];
}

#pragma mark ---------- methods to override for subclass

- (void)updateNews {
    
    if (_specialItem.headlines.count > 0) {
        SNSpecialNews *news = [_specialItem.headlines objectAtIndex:0];
        if (news.abstract.length) {
            self.abstractLabel.text = news.abstract;
            
            // 动态算text长度
            CGFloat textHeight = [SNLabel heightForContent:news.abstract
                                                  maxWidth:TTScreenBounds().size.width - kTableCellMargin * 2
                                                      font:fontSize
                                                lineHeight:kHeadlineAbstractLineHeight];
            
            self.abstractLabel.height = textHeight;
        }
    }
    
    [super updateNews];
}

- (NSString *)headlinePicUrl {
    if (_specialItem.headlines.count > 0) {
        SNSpecialNews *news = [self.specialItem.headlines objectAtIndex:0];
        if ([kSNGroupPhotoNewsType isEqualToString:news.newsType] && news.picArray.count > 0) {
            return [news.picArray objectAtIndex:0];
        } else {
            return news.pic;
        }
    }
    return nil;
}

- (NSString *)headlineTitle {
    if (_specialItem.headlines.count > 0) {
        SNSpecialNews *news = [self.specialItem.headlines objectAtIndex:0];
        return news.title;
    }
    return nil;
}

- (BOOL)headlineHasVideo {
    if (_specialItem.headlines.count > 0) {
        SNSpecialNews *news = [self.specialItem.headlines objectAtIndex:0];
        return [news.hasVideo isEqualToString:@"1"];
    }
    return NO;
}

- (void)openNews:(UITapGestureRecognizer *)tap
{
    SNSpecialHeadlineNewsTableItem *snItem = (SNSpecialHeadlineNewsTableItem *)self.specialItem;
    SNSpecialNews *news = [self.specialItem.headlines objectAtIndex:0];
 
    if ([kSNTextNewsType isEqualToString:news.newsType])
        return;
    
    news.isRead = kSNSpecialNewsIsRead_YES;
    NSDictionary *_dicData = [NSDictionary dictionaryWithObject:kSNSpecialNewsIsRead_YES forKey:@"isRead"];
    [[SNDBManager currentDataBase] updateSpecialNewsListByTermId:news.termId newsId:news.newsId withValuePairs:_dicData];
    
    if(news.newsType!=nil && [SNCommonNewsController supportContinuationInSpecial:news.newsType])
    {
        NSMutableDictionary* dic = [snItem.dataSource getSpecialContentDictionary:news];
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
    else if(news.link.length > 0)
    {
        [SNUtility openProtocolUrl:news.link];
    }
}

@end
