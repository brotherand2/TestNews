//
//  SNRollingNewsBookShelfCell.m
//  sohunews
//
//  Created by H on 2016/11/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#define kAddMoreButtonHeight    (35)
#define kRecomTipheight         (35)

#import "SNBookCover.h"
#import "UIImageView+WebCache.h"
#import "SNStoryPageViewController.h"
#import "SNBookShelf.h"
#import "SNStoryUtility.h"
#import "SNNotificationManager.h"
#import "SNNovelUtilities.h"
#import "SNNovelShelfController.h"
#import "StoryBookList.h"
#import "StoryBookAnchor.h"

@interface SNBookCover ()

@property (nonatomic, strong) UIView * nightMask;

@property (nonatomic, strong) UILabel * bookName;

@property (nonatomic, strong) UIImageView * dot;

@property (nonatomic, strong) UIButton * selectButton;

@property (nonatomic, strong) UILabel * udpateChapter;

@property (nonatomic, strong) UILabel * hasReadChapter;

@property (nonatomic, assign) BOOL  isEditing;

@end

@implementation SNBookCover

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self initContent];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)initContent {
    if (!self.bookCover) {
        self.bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, self.width, (NSInteger)(self.width * [SNNovelUtilities shelfImageHeightWidthRatio]))];
        [self addSubview:self.bookCover];
        
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            if (!self.nightMask) {
                self.nightMask = [[UIView alloc] initWithFrame:self.bookCover.frame];
            }
            self.nightMask.backgroundColor = [UIColor blackColor];
            self.nightMask.alpha = 0.3f;
            [self addSubview:self.nightMask];
        }
    }
    if (!self.bookName) {
        self.bookName = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bookCover.frame)+10, self.width, self.height - self.bookCover.height)];
        self.bookName.top = self.bookCover.bottom;
        self.bookName.textColor = SNUICOLOR(kThemeText2Color);
        self.bookName.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        self.bookName.numberOfLines = 0;
        [self addSubview:self.bookName];
    }
    
    if (!_udpateChapter) {
        self.udpateChapter = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bookCover.frame)-25, self.width, 25)];
        self.udpateChapter.textColor = SNUICOLOR(kThemeCheckLineColor);
        self.udpateChapter.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.udpateChapter.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        self.udpateChapter.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.udpateChapter];
    }
    
    if (!self.hasReadChapter) {
        self.hasReadChapter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - self.bookCover.height)];
        self.hasReadChapter.top = self.bookCover.bottom;
        self.hasReadChapter.textColor = SNUICOLOR(kThemeText3Color);
        self.hasReadChapter.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        [self addSubview:self.hasReadChapter];
    }
    
    if (!_selectButton) {
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *normalImage = [UIImage imageNamed:@"novel_icofiction_wxz_v5.png"];
        UIImage *selectedImage = [UIImage imageNamed:@"novel_icofiction_xz_v5.png"];
        _selectButton.frame = CGRectMake(CGRectGetMaxX(_bookCover.frame)-4-normalImage.size.width, CGRectGetMinY(_bookCover.frame)+4, normalImage.size.width, normalImage.size.height);
        [_selectButton setImage:normalImage forState:UIControlStateNormal];
        [_selectButton setImage:selectedImage forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.hidden = YES;
        [self addSubview:_selectButton];
    }
    
    if (!self.dot) {
        self.dot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        self.dot.left = self.width - self.dot.width/2.f;
        self.dot.top = CGRectGetMinY(_bookCover.frame) -self.dot.height/2.f;
        self.dot.backgroundColor = SNUICOLOR(kThemeRed1Color);
        self.dot.layer.cornerRadius = 7;
        [self addSubview:self.dot];
    }
    
    UITapGestureRecognizer * tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPressToDo:)];
    [self addGestureRecognizer:tapPress];
}

-(void)selectBtnTaped:(UIButton *)sender{
    sender.selected  = !sender.selected;
    if ([_sourceController isKindOfClass:[SNNovelShelfController class]]) {
        NSMutableArray *selectedArr = ((SNNovelShelfController*)self.sourceController).selectedBooks;
        if (selectedArr) {
            if (sender.selected) {
                [selectedArr addObject:_book];
            }else{
                if ([selectedArr containsObject:_book]) {
                    [selectedArr removeObject:_book];
                }
            }
            [(SNNovelShelfController*)_sourceController refreshSelectState];
        }
    }
}

- (void)tapPressToDo:(UIGestureRecognizer *)gesture {
    if(_isEditing) {
        [self selectBtnTaped:_selectButton];
        return;
    }
    
    // open the book
    if (!self.book.bookId || self.book.bookId.length <= 0) {
        return;
    }
    
    SNNovelShelfController *shelfController = nil;
    if (_sourceController && [_sourceController isKindOfClass:[SNNovelShelfController class]]) {
        shelfController = _sourceController;
        if (shelfController.bookAnimating) {
            return;
        }
        
        shelfController.bookAnimating = YES;
    }
    
    SNStoryPageViewController *pageController = [SNStoryPageViewController new];
    pageController.pageType = StoryPageFromChannel;//频道流进入
    pageController.novelId = self.book.bookId;
    pageController.openAnimation = @"open";
    pageController.isFinishOpenAnimation = NO;
    shelfController.pageViewController = pageController;
    
    
    [[[[TTNavigator navigator] topViewController] flipboardNavigationController] pushViewNoMaskController:pageController animated:NO];
    [self setHasRead:YES];
    
    //添加一个动画的封面view
    CGRect screenBounds = TTScreenBounds();
    CGRect frame = [self.bookCover convertRect:self.bookCover.bounds toView:nil];
    UIImageView * animateImg = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x - frame.size.width/2.f, frame.origin.y, frame.size.width, frame.size.height)];
    animateImg.image = self.bookCover.image;
    [[TTNavigator navigator].window addSubview:animateImg];
    
    //将小说正文放到封面下面，与封面一起动画
    pageController.view.frame = frame;
    pageController.cover = animateImg;
    pageController.rectInBookshelf = frame;
    
    //设置动画
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform,- M_PI_2, 0, 1, 0 );
    animateImg.layer.anchorPoint = CGPointMake(0, 0.5);
    transform.m34 = 4.5/2000;
    
    NSNumber* alphaNum = [SNUserDefaults objectForKey:kSNStory_Screen_Brightness];
    UIView* view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = alphaNum?alphaNum.floatValue:0;
    
    sohunewsAppDelegate* app = (sohunewsAppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window addSubview:view];
    view.userInteractionEnabled = NO;
    pageController.screenBrightnessView = view;
    
    //开始动画
    shelfController.footerView.userInteractionEnabled = NO;
    [UIView animateWithDuration:3/8.f animations:^{
        animateImg.layer.transform = transform;
        
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        animateImg.frame = screenBounds;
        pageController.view.frame = screenBounds;
        
    } completion:^(BOOL finished) {
        [animateImg setHidden:YES];
        pageController.isFinishOpenAnimation = YES;
        shelfController.footerView.userInteractionEnabled = YES;
        shelfController.bookAnimating = NO;
        [SNNotificationManager postNotificationName:kNovelDidAddBookShelfNotification object:nil userInfo:@{@"scrollTop":@"1",@"bookId":self.book.bookId}];
    }];
    
    //异步处理已读
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //设置已读
        [SNBookShelf setBookHasRead:self.book.bookId complete:nil];
    });
    
    //1 书架点击
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"act=fic&tp=pv&from=1&bookId=%@",self.book.bookId]];//书架进入埋点统计
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}


/* @qz 屏蔽此功能
- (void)longPressToDo:(UIGestureRecognizer *)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ){
        //CGPoint location = [gesture locationInView:[UIApplication sharedApplication].keyWindow];
        //show book manager menu view
        [self showMenuInLocation:self.frame view:self];
    }
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action == @selector(menuRemove:)) {
        return YES;
    }
    if (action == @selector(menuDetail:)) {
        return YES;
    }
    return NO; //隐藏系统默认的菜单项
}

- (void)menuRemove:(id)sender{
    [SNBookShelf removeBookShelf:self.book.bookId completed:^(BOOL success) {
        if(success) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已删除" toUrl:nil mode:SNCenterToastModeSuccess];
        }else{
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"删除失败" toUrl:nil mode:SNCenterToastModeError];
        }
    }];
}

- (void)menuDetail:(id)sender{
    [SNUtility openProtocolUrl:self.book.detailUrl];
    //详情页埋点统计 8.小说频道-点击书籍管理
    [SNStoryUtility storyReportADotGif:[NSString stringWithFormat:@"act=fic&objType=fic_todetail&fromObjType=%@",@"8"]];
}
*/

- (void)updateTheme {
    self.dot.image = [UIImage imageNamed:@"ico_hong_v5.png"];
    self.bookName.textColor = SNUICOLOR(kThemeText2Color);
    if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
        if (!self.nightMask) {
            self.nightMask = [[UIView alloc] initWithFrame:self.bookCover.bounds];
        }
        self.nightMask.backgroundColor = [UIColor blackColor];
        self.nightMask.alpha = 0.3f;
        [self addSubview:self.nightMask];
    }else{
        [self.nightMask removeFromSuperview];
        self.nightMask = nil;
    }
}

- (void)setHasRead:(BOOL)hasRead {
    self.dot.hidden = hasRead;
}

- (void)updateBook:(id)bookItem isEdit:(BOOL)isEditing{

    if ([bookItem isKindOfClass:SNBook.class]) {
        SNBook * book = (SNBook*)bookItem;
        self.book = book;
        self.isEditing = isEditing;
        if (isEditing) {
            _dot.hidden = YES;
            _selectButton.hidden = NO;
            if (_sourceController && [_sourceController isKindOfClass:[SNNovelShelfController class]]) {
                NSMutableArray *selectedArr = ((SNNovelShelfController*)self.sourceController).selectedBooks;
                if (selectedArr) {
                    if ([selectedArr containsObject:book]) {
                        self.selectButton.selected = YES;
                    }else{
                        self.selectButton.selected = NO;
                    }
                }
            }else{
                self.selectButton.hidden = YES;
            }
        }else{
            [self setHasRead:!book.showDot];
            self.selectButton.hidden = YES;
        }

        [self.bookCover sd_setImageWithURL:[NSURL URLWithString:book.imageUrl] placeholderImage:[UIImage themeImageNamed:@"news_default_image.png"] completed:nil];
        self.bookName.text = book.title ? book.title : @"";
        
        NSString *nameText = _bookName.text;
        CGSize titleSize = [nameText boundingRectWithSize:CGSizeMake(self.width, 9999)
                                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                           attributes:@{NSFontAttributeName:_bookName.font}
                                              context:nil].size;
        CGSize singleSize = [@"呵呵" boundingRectWithSize:CGSizeMake(self.width, 9999)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                               attributes:@{NSFontAttributeName:_bookName.font}
                                                  context:nil].size;
        int onelineHeight = rint(singleSize.height);
        
        if (titleSize.height > onelineHeight) {
            _bookName.frame = CGRectMake(4, CGRectGetMaxY(_bookCover.frame)+10, self.width-8, onelineHeight*2);
        }else{
            _bookName.frame = CGRectMake(4, CGRectGetMaxY(_bookCover.frame)+10, self.width-8, onelineHeight);
        }
        
        _udpateChapter.text = book.lastUpdateBook;
        
        if(book.bookId){
            StoryBookList *bookList = [StoryBookList fecthBookByBookIdByUsingCoreData:book.bookId];
            
            if (bookList.hasReadChapterId > 0) {
                _hasReadChapter.text = [NSString stringWithFormat:@"已读%d章",bookList.hasReadChapterId];
            }else{
                
                StoryBookAnchor *anchor = [StoryBookAnchor fetchBookAnchorWithBookId:book.bookId];
                if (anchor && anchor.chapter > 0) {
                    _hasReadChapter.text = [NSString stringWithFormat:@"已读%d章",anchor.chapter];
                } else {
                    _hasReadChapter.text = @"尚未开始阅读";
                }
            }
            [_hasReadChapter sizeToFit];
            _hasReadChapter.frame = CGRectMake(_bookName.frame.origin.x, CGRectGetMaxY(_bookName.frame)+10, self.width-_bookName.frame.origin.x, _hasReadChapter.frame.size.height);
        }
    }
}

@end



