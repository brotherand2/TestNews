//
//  SNRollingNewsTableCell.h
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Updated by sampanli 1/20/12
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRollingNewsTableItem.h"
#import "SNRollingNewsAbstractCell.h"
#import "SNCellImageView.h"
#import <CoreText/CoreText.h>
#import "SNCellContentView.h"

/*****************************显示标题、摘要、图片的Cell*********************************
 
         1、标题最多显示两行
         2、标题多于两行结尾显示"..."
         3、标题两行时不显示摘要
         4、不显示摘要

 ****************************************************************************/

@interface SNRollingNewsTableCell : SNRollingNewsAbstractCell {
    UIView   *_adAppBackgroundView;
    UILabel  *_adAppLabel;
    UIView   *_adAppLineView;
    UIButton *_adAppDownloadButton;
}
@property (nonatomic, strong) SNCellImageView *cellImageView;
@end
