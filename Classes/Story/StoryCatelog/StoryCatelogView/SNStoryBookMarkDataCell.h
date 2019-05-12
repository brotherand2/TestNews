//
//  SNStoryBookMarkDataCell.h
//  sohunews
//
//   书签和批注cell
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    StoryBookNoDataTabChapter,
    StoryBookNoDataTabMark,
    StoryBookNoDataTabTip,
} StoryBookNoDataTab;

typedef void(^refreshChapterListBlock)();//刷新章节

@interface SNStoryBookMarkDataCell : UITableViewCell

@property(nonatomic, copy)refreshChapterListBlock refreshChapter;
/**

 @param tab             0-目录；1-书签；2-批注

 @return cell
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bookTab:(StoryBookNoDataTab)tab;

@end
