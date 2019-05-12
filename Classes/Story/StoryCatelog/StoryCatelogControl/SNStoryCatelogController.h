//
//  SNStoryCatelogController.h
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/11.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNStoryBaseViewController.h"
#import "SNStoryBookMarkAndNoteModel.h"

typedef enum{
    StoryCateLogFromH5Detail,//H5详情页进入
    StoryCateLogFromReadPage//阅读页进入目录
    
}StoryCatelogType;//进入目录页的来源

@class StoryBookList;

@protocol SNStoryCatelogDelegate <NSObject>

@optional
-(void)storyCatelogIntoPageWithIndex:(NSUInteger)index chapterArray:(NSMutableArray*)chapterArray;

- (void)gotoBookMarkPageWith:(SNStoryBookMarkAndNoteModel *)bookMark chapterArray:(NSMutableArray*)chapterArray;

@end
@interface SNStoryCatelogController : SNStoryBaseViewController

@property(nonatomic,assign) StoryCatelogType catelogType;
@property(nonatomic,strong) NSString *novelId;//小说id
@property(nonatomic,weak) id<SNStoryCatelogDelegate>delegate;
- (void)updateTheme;
-(void)chapterHasReadWithNovelId:(NSString *)novelId  book:(StoryBookList *)book;
@end
