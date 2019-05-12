//
//  SNBookMarkViewModel.m
//  sohunews
//
//  Created by H on 2016/10/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNBookMarkViewModel.h"
#import "SNBookMarkView.h"
#import "SNStoryBookMarkAndNoteModel.h"
#import "SHCoreDataHelper.h"
#import "StoryBookMarks+CoreDataProperties.h"
#import "StoryBookMarks+CoreDataClass.h"

@implementation SNBookMarkViewModel

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0.0f) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
        return;
    }
    if ([scrollView isKindOfClass:[SNBookMarkView class]]) {
        SNBookMarkView * bookMarkView = (SNBookMarkView *)scrollView;
        if ([bookMarkView respondsToSelector:@selector(contentOffsetDidChanged:)]) {
            [bookMarkView contentOffsetDidChanged:scrollView.contentOffset.y];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isKindOfClass:[SNBookMarkView class]]) {
        SNBookMarkView * bookMarkView = (SNBookMarkView *)scrollView;
        if ([bookMarkView respondsToSelector:@selector(didEndDragging:)]) {
            [bookMarkView didEndDragging:scrollView.contentOffset.y];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
}

#pragma mark -- 业务代码
+ (void)addBookMark:(SNStoryBookMarkAndNoteModel *)pageInfo completed:(SNAddBookMarkBlock)completed {
    //to do ...添加书签
    if (!pageInfo.bookId || !pageInfo.chapterId) {
        completed(NO,nil);
        return ;
    }
    
    SHCoreDataHelper * helper = [SHCoreDataHelper sharedInstance];
    StoryBookMarks * bookMarks = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBookMarks" inManagedObjectContext:helper.objectContext];
    bookMarks.bookId        = [NSNumber numberWithInt:pageInfo.bookId.integerValue];
    bookMarks.bookName      = pageInfo.bookName;
    bookMarks.chapterId     = [NSNumber numberWithInt:pageInfo.chapterId.integerValue];
    bookMarks.chapterName   = pageInfo.bookMark;
    bookMarks.timestamp     = pageInfo.bookMarkTime;
    bookMarks.content       = pageInfo.bookMarkcontent;
    bookMarks.page          = [NSNumber numberWithInt:pageInfo.pageNum];
    bookMarks.startLocation = [NSNumber numberWithInt:pageInfo.startLocation];
    bookMarks.length        = [NSNumber numberWithInt:pageInfo.length];
    bookMarks.chapterIndex  = [NSNumber numberWithInt:pageInfo.chapterIndex];

//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    bookMarks.timestamp     = [NSString stringWithFormat:@"%f",interval * 1000];
    [helper saveContext];
    
    completed(YES,nil);
}

+ (void)cancelBookMark:(SNStoryBookMarkAndNoteModel *)pageInfo completed:(SNAddBookMarkBlock)completed {
    //to do ...取消书签
    if (!pageInfo.bookId || !pageInfo.chapterId) {
        completed(NO,nil);
        return ;
    }
    
    SHCoreDataHelper * helper = [SHCoreDataHelper sharedInstance];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StoryBookMarks"
                                   
                                              inManagedObjectContext:helper.objectContext];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId = %d AND chapterId = %d" ,pageInfo.bookId.integerValue,pageInfo.chapterId.integerValue];
    
    if (predicate) [request setPredicate:predicate];
    
    NSArray * results = [helper.objectContext executeFetchRequest:request error:nil];
    
    if (results.count > 0) {
        for (StoryBookMarks * mark in results) {
            if (pageInfo.startLocation <= mark.startLocation.integerValue && mark.startLocation.integerValue < (pageInfo.startLocation + pageInfo.length)) {
                [helper deleteObject:mark];
            }
        }
        [helper saveContext];
        completed(YES,nil);
    }else{
        completed(NO,nil);
    }
    
}

+ (BOOL)isAddedBookMark:(SNStoryBookMarkAndNoteModel *)pageInfo {
    
    if (!pageInfo.bookId || !pageInfo.chapterId) {
        return NO;
    }
    
    SHCoreDataHelper * helper = [SHCoreDataHelper sharedInstance];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StoryBookMarks"
                                   
                                              inManagedObjectContext:helper.objectContext];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId = %d AND chapterId = %d" ,pageInfo.bookId.integerValue,pageInfo.chapterId.integerValue];
    
    if (predicate) [request setPredicate:predicate];
    
    NSArray * results = [helper.objectContext executeFetchRequest:request error:nil];
    
    if (results.count > 0) {
        for (StoryBookMarks * mark in results) {
            if (pageInfo.startLocation <= mark.startLocation.integerValue && mark.startLocation.integerValue < (pageInfo.startLocation + pageInfo.length)) {
                return YES;
            }
        }
    }else{
        return NO;
    }
    
    return NO;
}

+ (NSArray *)bookMarksWithBookId:(NSString *)bookId chapterId:(NSString *)chapterId {
    
    if (bookId.length == 0) {
        return  nil;
    }
    
    SHCoreDataHelper * helper = [SHCoreDataHelper sharedInstance];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StoryBookMarks"
                                   
                                              inManagedObjectContext:helper.objectContext];
    
    [request setEntity:entity];
    
    NSPredicate *predicate = nil;
    
    if (chapterId) {
        predicate = [NSPredicate predicateWithFormat:@"bookId = %d AND chapterId = %d" ,bookId.integerValue,chapterId.integerValue];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"bookId = %d" ,bookId.integerValue];
    }
    
    if (predicate) [request setPredicate:predicate];
    
    
    //换排序规则，书签按时间倒序
    NSSortDescriptor *byTime = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = [NSMutableArray arrayWithObjects:byTime, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray * results = [helper.objectContext executeFetchRequest:request error:nil];
    
    if (results.count > 0) {
        NSMutableArray * ret = [NSMutableArray array];
        for (StoryBookMarks * mark in results) {
            [ret addObject:[SNStoryBookMarkAndNoteModel translateFor:mark]];
        }
        return ret;
    }else{
        return nil;
    }

}

@end
