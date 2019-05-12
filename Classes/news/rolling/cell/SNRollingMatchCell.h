//
//  SNRollingMatchCell.h
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNewsTitleCell.h"
#import "SNCellMatchContentView.h"

@interface SNRollingMatchCell : SNRollingNewsTitleCell {
    SNCellMatchContentView *matchContentView;
    UIImageView *videoImageView;
}

@end
