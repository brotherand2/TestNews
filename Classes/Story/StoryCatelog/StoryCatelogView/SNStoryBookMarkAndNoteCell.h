//
//  SNStoryBookMarkAndNoteCell.h
//  sohunews
//
//   书签和批注cell
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNStoryBookMarkAndNoteCell : UITableViewCell

-(void)storyBookMarkCellWithModel:(id)model indexPath:(NSIndexPath *)indexPath isBookMark:(BOOL)isBookMark;
@end
