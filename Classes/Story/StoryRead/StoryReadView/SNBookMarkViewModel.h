//
//  SNBookMarkViewModel.h
//  sohunews
//
//  Created by H on 2016/10/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNBookMarkView;
@class SNStoryBookMarkAndNoteModel;

typedef void(^SNAddBookMarkBlock)(BOOL success, id completedInfo);

@interface SNBookMarkViewModel : NSObject<UITableViewDelegate>

/**
 添加书签

 @param pageInfo  书签信息
 @param completed 完成的block回调 success是否成功，completedInfo回调信息
 */
+ (void)addBookMark:(SNStoryBookMarkAndNoteModel *)pageInfo completed:(SNAddBookMarkBlock)completed;

/**
 取消添加书签
 
 @param pageInfo  书签信息
 @param completed 完成的block回调 success是否成功，completedInfo回调信息
 */
+ (void)cancelBookMark:(SNStoryBookMarkAndNoteModel *)pageInfo completed:(SNAddBookMarkBlock)completed;

/**
 检查当前页的书签信息。(是否添加了书签)
 */
+ (BOOL)isAddedBookMark:(SNStoryBookMarkAndNoteModel *)pageInfo;


/**
 根据书籍或者章节获取所有的书签列表

 @param bookId    书籍id 必须
 @param chapterId 章节id 如果为空则返回整本书的书签

 @return 存放StoryBookMarkAndNoteModel实例的数组
 */
+ (NSArray *)bookMarksWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId;

@end
