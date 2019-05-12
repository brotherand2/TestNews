//
//  SNHotTableCell.m
//  sohunews
//
//  Created by ivan.qi on 3/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoTableCell.h"
#import "UIColor+ColorUtils.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNDBManager.h"
#import "SNPhotoConfigs.h"

//////////////////////////////////////////////////////////////
#define CELL_TITLE_SECTION_HEIGHT           (19)
#define CELL_LEFT_RIGHT_MARGIN              (14)
#define PHOTO_CELL_TOP_MARGIN               (15.5)
#define PHOTO_CELL_BOTTOM_MARGIN            (10)
#define MARGIN_BETWEEN_ICON_AND_LABEL       (3)
#define ICON_WIDTH                          (12)
#define ICON_HEIGHT                         (11)
#define NUM_LABEL_WIDTH                     (15)
#define NUM_LABEL_HEIGHT                    (7)
#define TITLE_IMAGE_MARGIN                  (9.5)
//////////////////////////////////////////////////////////////

@implementation SNPhotoTableCell

@synthesize item, lastImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];

        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];

        [SNNotificationManager addObserver:self
                                                 selector:@selector(updateReadFlag:)
                                                     name:photoListSlideshowDidChange
                                                   object:nil];
         self.newsIdArray = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    [UIView drawCellSeperateLine:rect];
}

- (void)addTitleSection {
    UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:10];
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(CELL_LEFT_RIGHT_MARGIN, PHOTO_CELL_TOP_MARGIN - 2,
                                      kAppScreenWidth - CELL_LEFT_RIGHT_MARGIN*2,
                                      [SNUtility getNewsTitleHeight]);
        [titleLabel setFont:[SNUtility getNewsTitleFont]];
        titleLabel.tag = 10;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
    }
    titleLabel.text = self.item.hotPhotoNews.title;
}

-(void)addCommentIconAndLabel {
    UIImageView *commentIconView = (UIImageView *)[self.contentView viewWithTag:13];
    if (!commentIconView) {
        commentIconView = [[UIImageView alloc] init];
        if (lastImageView) {
            commentIconView.frame = CGRectMake(CELL_LEFT_RIGHT_MARGIN,
                                               lastImageView.frame.origin.y + lastImageView.frame.size.height + 6,
                                               ICON_WIDTH,
                                               ICON_HEIGHT);
        }
        
        commentIconView.tag = 13;
        [self.contentView addSubview:commentIconView];
    }
    
    UILabel *commentNumLabel = (UILabel *)[self.contentView viewWithTag:14];
    if (!commentNumLabel) {
        commentNumLabel = [[UILabel alloc] init];
        commentNumLabel.frame = CGRectMake(commentIconView.origin.x+commentIconView.frame.size.width+6-2,
                                           commentIconView.origin.y,
                                           30,9+2);
        [commentNumLabel setFont:[UIFont digitAndLetterFontOfSize:9]];
        commentNumLabel.backgroundColor = [UIColor clearColor];
        commentNumLabel.tag = 14;
        [self.contentView addSubview:commentNumLabel];
    }
    
    NSString *commentNumText = [self.item.hotPhotoNews.commentNum isEqualToString:@"0"] ? @"" : self.item.hotPhotoNews.commentNum;
    commentNumLabel.text = commentNumText;
    commentNumLabel.accessibilityLabel = [NSString stringWithFormat:@"%d个评论", [self.item.hotPhotoNews.commentNum intValue]];
}

- (void)addCountView {
    UIImageView *numIcon = (UIImageView *)[self.contentView viewWithTag:11];
    if (!numIcon) {
        numIcon = [[UIImageView alloc] init];
        numIcon.frame = CGRectMake(120/2-1,
                                   lastImageView.frame.origin.y + lastImageView.frame.size.height + 6,
                                   ICON_WIDTH,
                                   ICON_HEIGHT);
        numIcon.tag = 11;
        [self.contentView addSubview:numIcon];
    }
    
    UILabel *imageNumLabel = (UILabel *)[self.contentView viewWithTag:12];
    if (!imageNumLabel) {
        imageNumLabel = [[UILabel alloc] init];
        imageNumLabel.frame = CGRectMake(numIcon.origin.x+numIcon.frame.size.width+6-2,
                                         numIcon.origin.y,
                                         25, 9+2);
        [imageNumLabel setFont:[UIFont digitAndLetterFontOfSize:9]];
        imageNumLabel.backgroundColor = [UIColor clearColor];
        imageNumLabel.tag = 12;
        [self.contentView addSubview:imageNumLabel];
    }
    imageNumLabel.text = self.item.hotPhotoNews.imageNum;
    imageNumLabel.accessibilityLabel = [NSString stringWithFormat:@"%d张图片", [self.item.hotPhotoNews.imageNum intValue]];
}

// cell图片是否已加载
-(BOOL)isImagesLoaded {
    // Do in subclass
    return YES;
}

-(void)addImages:(BOOL)ignoreNonePicMode {
    // Do in subclass.
}


-(void)changeFavNumLabel:(NSString *)text {
    // Do nothing
}

- (void)changeMask
{
    // Do in subclass.
}

- (void)changeTheme {
    [self setReadStyleByMemory];
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    
    UIImageView *numIcon = (UIImageView *)[self.contentView viewWithTag:11];
    if (numIcon) {
        numIcon.image = [UIImage imageNamed:@"icohome_picsmall_v5.png"];
    }
    UIImageView *commentIconView = (UIImageView *)[self.contentView viewWithTag:13];
    if (commentIconView) {

        commentIconView.image = [UIImage imageNamed:@"icohome_commentsmall_v5.png"];
    }
    
    _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
    
    [self changeImageAlpha];
    [self changeMask];
    [self changeDefaultImage];
}

- (void)changeImageAlpha {
    //TO-DO in subClass
}

- (void)changeDefaultImage {
    //TO-DO in subClass
}

- (BOOL)isThemeChanged
{
    return ![_currentTheme isEqualToString:[[SNThemeManager sharedThemeManager] currentTheme]];
}

- (BOOL)isPicModeChanged
{
    return [_currentPicMode intValue] != ([SNUtility getApplicationDelegate].shouldDownloadImagesManually ? 1:0);
}

- (void)layoutSubviews {
    if ([self isThemeChanged]) {
        _currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
        [self changeTheme];
    }
    if ([self isPicModeChanged]) {
        _currentPicMode = [SNUtility getApplicationDelegate].shouldDownloadImagesManually ? @"1" : @"0";
        [self changeDefaultImage];
    }
    
    UIView *titleLabel = (UIImageView *)[self.contentView viewWithTag:10];
    titleLabel.height = [SNUtility getNewsTitleHeight];
    
    [self setCacheReadFlag];
    [self setReadStyleByMemory];
}

-(void)updateTheme {
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.contentView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    [self setNeedsDisplay];
    [self changeTheme];
}

- (void)updateNonePicMode {
    [self setNeedsDisplay];
    [self addImages:NO];
    [self changeDefaultImage];
}

- (void)openNews {
    
    if ([SNUtility getApplicationDelegate].shouldDownloadImagesManually && ![self isImagesLoaded]) {
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            [self showSelectedBg:NO];
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            return;
        }
        // 尝试重新加载cell图片
        [self addImages:YES];
        [self showSelectedBg:NO];
        //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        // 如果有未加载成功的图尝试再次下载
        [self addImages:YES];
        
        [item.controller cacheCellIndexPath:self];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:self.item.hotPhotoNews.newsId forKey:kNewsId];
//        [userInfo setObject:self.item.hotPhotoNews.subLink forKey:kSubLink];//用于打开频道新闻里组图的二代链接
        [userInfo setObject:kDftSingleGalleryTermId forKey:kTermId];
        [userInfo setObject:item.controller forKey:kController];
        [userInfo setObject:kNewsOnline forKey:kNewsMode];
        [userInfo setObject:self.item.allItems forKey:kNewsList];
        [userInfo setObject:self.item.hotPhotoNews.type forKey:kType];
        [userInfo setObject:self.item.hotPhotoNews.typeId forKey:kTypeId];
        [userInfo setObject:[NSNumber numberWithInt:GallerySourceTypeGroupPhoto] forKey:kGallerySourceType];
        [userInfo setObject:self.item.hotPhotoNews.sublink forKey:kLink];
        
        if ([kGroupPhotoCategory isEqualToString:self.item.hotPhotoNews.type]) {
            
            [userInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_GROUPPHOTOTAB_CATEGORY] forKey:kMyFavouriteRefer];
            
        } else if ([kGroupPhotoTag isEqualToString:self.item.hotPhotoNews.type]) {
            
            [userInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOSLIDE_FROM_GROUPPHOTOTAB_TAG] forKey:kMyFavouriteRefer];
            
        } else if ([kGroupPhotoChannel isEqualToString:self.item.hotPhotoNews.type]) {
            
            [userInfo setObject:self.item.hotPhotoNews.typeId forKey:kChannelId];
            [userInfo setValue:[NSNumber numberWithInt:MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_CHANNEL] forKey:kMyFavouriteRefer];
            
        }
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([self.item.hotPhotoNews.time doubleValue]/1000.0)];
        NSString *strTimer = [formatter stringFromDate:date];
        [userInfo setValue:strTimer forKey:kPubDate];
        
//        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://photoSlideshow"] applyAnimated:YES] applyQuery:userInfo];
        //小岳说不要幻灯片模式，换成列表模式

        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5NewsWebView"] applyAnimated:YES] applyQuery:userInfo];

        [[TTNavigator navigator] openURLAction:urlAction];
        
        self.item.hotPhotoNews.readFlag = YES;
        [self setAlreadyReadStyle];
    }
}

- (void)setReadStyleByMemory {
    if (self.item.hotPhotoNews.readFlag == 1) {
        [self setAlreadyReadStyle];
        [[SNDBManager currentDataBase] markPhotoItemAsReadByTypeId:self.item.hotPhotoNews.typeId
                                                            newsId:self.item.hotPhotoNews.newsId
                                                              type:self.item.hotPhotoNews.type];
    } else {
        [self setUnReadStyle];
    }
}

- (void)setAlreadyReadStyle
{
    UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:10];
    if (titleLabel) {
        [titleLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color]]];
    }
    UILabel *imageNumLabel = (UILabel *)[self.contentView viewWithTag:12];
    if (imageNumLabel) {
        [imageNumLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color]]];
    }
    UILabel *commentNumLabel = (UILabel *)[self.contentView viewWithTag:14];
    if (commentNumLabel) {
        [commentNumLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText3Color]]];
    }
}

- (void)setUnReadStyle
{
    UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:10];
    if (titleLabel) {
        [titleLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText2Color]]];
    }
    UILabel *imageNumLabel = (UILabel *)[self.contentView viewWithTag:12];
    if (imageNumLabel) {
        [imageNumLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoListImageCountColor]]];
    }
    UILabel *commentNumLabel = (UILabel *)[self.contentView viewWithTag:14];
    if (commentNumLabel) {
        [commentNumLabel setTextColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoListCommentCountColor]]];
    }
}

- (void)setObject:(id)object {
    if (object && object != self.item) {
        //[[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
        
        self.selectionStyle     = UITableViewCellSelectionStyleNone;
        self.item               = object;
        self.item.delegate = self;
        self.item.selector = @selector(openNews);
        
        [self addTitleSection];
        [self addImages:NO];
        [self addCommentIconAndLabel];
        [self addCountView];

        if ([self isThemeChanged] || [self isPicModeChanged]) {
            [self changeDefaultImage];
        }
        
        [self setNeedsDisplay];
    }
    else{
        UILabel *titleLabel = [self.contentView viewWithTag:10];
        [titleLabel setFont:[SNUtility getNewsTitleFont]];
    }
}

- (void)showSelectedBg:(BOOL)show
{
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            _cellSelectedBg.frame = self.bounds;
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1;
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
        _cellSelectedBg.alpha = 0;
        [UIView commitAnimations];
    }    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    [self showSelectedBg:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    [self showSelectedBg:selected];
}

- (void)setCacheReadFlag
{
    long count = _newsIdArray.count;
    for (int index = 0; index < count; index++) {
        NSString *newsId = _newsIdArray[index];
        if ([newsId isEqualToString:self.item.hotPhotoNews.newsId]) {
            self.item.hotPhotoNews.readFlag = 1;
        }
    }
}

#pragma mark - observer
- (void)updateReadFlag:(NSNotification *)notifaction
{
    NSString *newsId = [notifaction object];
    if (newsId.length > 0) {
//        self.item.hotPhotoNews.readFlag = YES;
//        [self setAlreadyReadStyle];
        [self.newsIdArray addObject:newsId];
    }
}

-(void)dealloc
{
    [SNNotificationManager removeObserver:self];
     //(_cellSelectedBg);
     //(item);
     //(lastImageView);
}

@end
