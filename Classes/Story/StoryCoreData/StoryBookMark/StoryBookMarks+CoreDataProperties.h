//
//  StoryBookMarks+CoreDataProperties.h
//  sohunews
//
//  Created by H on 2016/11/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "StoryBookMarks+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface StoryBookMarks (CoreDataProperties)

+ (NSFetchRequest<StoryBookMarks *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSNumber *  bookId;
@property (nullable, nonatomic, copy)   NSString *  bookName;
@property (nullable, nonatomic, retain) NSNumber *  chapterId;
@property (nullable, nonatomic, copy)   NSString *  chapterName;
@property (nullable, nonatomic, copy)   NSString *  content;
@property (nullable, nonatomic, retain) NSNumber *  page;
@property (nullable, nonatomic, copy)   NSString *  timestamp;
@property (nullable, nonatomic, retain) NSNumber *  startLocation;
@property (nullable, nonatomic, retain) NSNumber *  length;
@property (nullable, nonatomic, retain) NSNumber *  chapterIndex;

@end

NS_ASSUME_NONNULL_END
