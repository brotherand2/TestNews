//
//  SNAutoPlayVideoStyleTwoCell.h
//  sohunews
//
//  Created by cuiliangliang on 16/6/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNewsAbstractCell.h"
#import "SNVideoDetailModel.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNRollingNewsTableItem.h"
#import "SNRollingNewsAbstractCell.h"
#import "SNCellImageView.h"
#import <CoreText/CoreText.h>
#import "SNCellContentView.h"

@interface SNAutoPlayVideoStyleTwoCell : SNRollingNewsAbstractCell<SNCellMoreViewShareDelegate>
- (void)updateTheme;
- (void)autoPlay;
- (void)stopPlay;

@end
