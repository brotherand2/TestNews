//
//  SNStoryBookMarkAndNoteModel.h
//  sohunews
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoryBookMarks+CoreDataClass.h"

@interface SNStoryBookMarkAndNoteModel : NSObject

@property(nonatomic,copy)NSString *bookMark;
@property(nonatomic,copy)NSString *bookMarkcontent;
@property(nonatomic,copy)NSString *bookMarkTime;
/**
 书籍id
 */
@property (nonatomic, copy) NSString * bookId;

/**
 书名
 */
@property (nonatomic, copy) NSString * bookName;

/**
 章节id
 */
@property (nonatomic, copy) NSString * chapterId;

/**
 章节名字
 */
//@property (nonatomic, copy) NSString * chapterName;

/**
 当前页内容
 */
//@property (nonatomic, copy) NSString * pageContent;

/**
 页码
 */
@property (nonatomic, assign) NSInteger pageNum;

/**
 起始位置
 */
@property (nonatomic, assign) NSInteger startLocation;

/**
 从起始位置开始的长度
 */
@property (nonatomic, assign) NSInteger length;

/**
 章节次序
 */
@property (nonatomic, assign) NSInteger chapterIndex;

+ (SNStoryBookMarkAndNoteModel *)translateFor:(StoryBookMarks *)bookMarks;

+(float)getBookMarkCellHeight;
+(float)getBookNoteCellHeight;
@end
