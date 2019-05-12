//
//  SNStoryChapter.h
//  sohunews
//
//  Created by chuanwenwang on 2016/11/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNStoryChapter : NSObject

@property(nonatomic, assign)NSInteger chapterId;//章节id
@property(nonatomic, assign)NSInteger oid;//章节id
@property(nonatomic, strong)NSString *chapterContent;//章节内容
@property(nonatomic, strong)NSString *chapterTitle;
@property(nonatomic, strong)NSMutableArray *chapterPageArray;//章节页数
@property(nonatomic, assign)BOOL isFree;//是否免费
@property(nonatomic, assign)BOOL hasPaid;//是否购买
@property(nonatomic, assign)BOOL isDownload;//是否下载过
@end
