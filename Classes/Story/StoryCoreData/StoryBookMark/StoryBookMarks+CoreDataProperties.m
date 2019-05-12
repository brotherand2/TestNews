//
//  StoryBookMarks+CoreDataProperties.m
//  sohunews
//
//  Created by H on 2016/11/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "StoryBookMarks+CoreDataProperties.h"

@implementation StoryBookMarks (CoreDataProperties)

+ (NSFetchRequest<StoryBookMarks *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"StoryBookMarks"];
}

@dynamic bookId;
@dynamic bookName;
@dynamic chapterId;
@dynamic chapterName;
@dynamic content;
@dynamic page;
@dynamic timestamp;
@dynamic startLocation;
@dynamic length;
@dynamic chapterIndex;

@end
