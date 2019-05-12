//
//  SNRollingNewsPictureCell.h
//  sohunews
//
//  Created by lhp on 5/7/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNewsTitleCell.h"
#import "SNImageView.h"

/*****************************显示大图模式新闻的Cell****************************
 
         1、标题最多显示一行
         2、标题多于一行结尾显示"..."
         3、不显示摘要
****************************************************************************/

@interface SNRollingNewsPictureCell : SNRollingNewsTitleCell {
    SNImageView *cellImageView;
    
    UIView *_adAppBackgroundView;
    UILabel *_adAppLabel;
    UIView *_adAppLineView;
    UIButton *_adAppDownloadButton;
}

@end
