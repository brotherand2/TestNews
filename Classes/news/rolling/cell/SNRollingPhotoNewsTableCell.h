//
//  SNRollingPhotoNewsTableCell.h
//  sohunews
//
//  Created by Cong Dan on 3/20/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRollingNewsTitleCell.h"

/*****************************显示组图新闻的Cell********************************
 
         1、标题最多显示一行
         2、标题多于一行结尾显示"..."
         3、不显示摘要
****************************************************************************/

@interface SNRollingPhotoNewsTableCell : SNRollingNewsTitleCell {
    NSMutableArray *imageViewArray;
    UIView *_adAppBackgroundView;
    UILabel *_adAppLabel;
    UIView *_adAppLineView;
    UIButton *_adAppDownloadButton;
    UIImage *_defaultImage;
}

@end
