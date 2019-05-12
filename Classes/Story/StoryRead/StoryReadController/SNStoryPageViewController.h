//
//  SNStoryPageViewController.h
//  StorySoHu
//
//  Created by chuanwenwang on 16/10/12.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNStoryContentController.h"

typedef enum {
    StoryPageFromH5Detail,
    StoryPageFromH5Catelaog,
    StoryPageFromChannel,
    StoryPageFromProtocol
}StoryPageFromWhichPage;

typedef enum
{
    StoryPageScrollAnimationNone = 0,//没有动画
    StoryPageScrollAnimationRightToLeft,//从右到左
    StoryPageScrollAnimationLeftToRight//从左到右
}StoryPageScrollAnimation;

@protocol SNStoryWebViewControllerDelegate <NSObject>

-(void)addBookShelfInPageView;

@end

@class StoryBookList;

@interface SNStoryPageViewController : UIViewController

@property(nonatomic, assign)NSInteger chapterIndex;//章节索引
@property(nonatomic, assign)NSInteger chapterId;//章节id
@property(nonatomic, assign)StoryPageFromWhichPage pageType;//记录从哪个页面进入
@property(nonatomic,strong)NSString *novelId;//小说id

@property(nonatomic,strong)NSString *openAnimation;//入口动画
@property(nonatomic,assign)BOOL isFinishOpenAnimation;//入口动画是否完成
@property(nonatomic,assign)BOOL isAnchor;//是否是锚点，NO：不是
@property(nonatomic, strong)UIView* screenBrightnessView;//屏幕亮度view
@property(nonatomic, weak)id<SNStoryWebViewControllerDelegate>delegate;
/**
 小说封面
 */
@property (nonatomic, strong) UIImageView * cover;

/**
 在书架上的位置
 */
@property (nonatomic, assign) CGRect rectInBookshelf;

//小说专用数据
@property (nonatomic, strong) NSArray *chapterArray;//章节总数
@property (nonatomic, strong) NSMutableArray *availableChapterArray;//可读章节
@property (nonatomic, strong) NSMutableDictionary *chapterCacheDic;//缓存欲读章节
@property (nonatomic, strong) NSMutableArray *payArray;//付费章节
@property (nonatomic, strong) StoryBookList *book;

/**
 *  初始化小说数据
 */
-(void)initPageArrayWithNovelId:(NSString *)novelId chapterId:(NSInteger)chapterId font:(UIFont *)font chapterIndex:(NSInteger)chapterIndex;
/**
 * 同步pid章节
 */
-(void)updatePidInfoByCid;

/**
 * 页面跳转
 */
-(void)setPageViewControllerWithChapterIndex:(int)chapterIndex pageIndex:(int)pageIndex scrollType:(StoryScrollType)scrollType scrollAnimation:(StoryPageScrollAnimation)scrollAnimation;

@end
