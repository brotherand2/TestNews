//
//  SNStoryBookMarkAndNoteModel.m
//  sohunews
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryBookMarkAndNoteModel.h"
#import "NSDate-Utilities.h"

@implementation SNStoryBookMarkAndNoteModel

+(float)getBookMarkCellHeight
{
    return (12 + [UIFont systemFontOfSize:13].lineHeight + 6 + [UIFont systemFontOfSize:16].lineHeight + 6 + [UIFont systemFontOfSize:11].lineHeight + 5);
}

+(float)getBookNoteCellHeight
{
    return (12 + [UIFont systemFontOfSize:13].lineHeight + 6 + [UIFont systemFontOfSize:16].lineHeight + 6 + [UIFont systemFontOfSize:11].lineHeight);
}

+ (SNStoryBookMarkAndNoteModel *)translateFor:(StoryBookMarks *)bookMarks {
    SNStoryBookMarkAndNoteModel * bookmarkModel = [[SNStoryBookMarkAndNoteModel alloc] init];
    bookmarkModel.bookId = bookMarks.bookId.stringValue;
    bookmarkModel.chapterId = bookMarks.chapterId.stringValue;
    bookmarkModel.bookName = bookMarks.bookName;
    bookmarkModel.bookMark = bookMarks.chapterName;
    bookmarkModel.bookMarkcontent = bookMarks.content;
    bookmarkModel.bookMarkTime = [NSDate relativelyDate:bookMarks.timestamp];
    bookmarkModel.startLocation = bookMarks.startLocation.integerValue;
    bookmarkModel.length = bookMarks.length.integerValue;
    bookmarkModel.pageNum = bookMarks.page.integerValue;
    bookmarkModel.chapterIndex = bookMarks.chapterIndex.integerValue;
    return bookmarkModel;
}

@end
