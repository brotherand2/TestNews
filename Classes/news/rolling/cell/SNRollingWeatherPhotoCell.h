//
//  SNWeatherPhotoCell.h
//  sohunews
//
//  Created by lhp on 3/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"
#import "SNRollingBaseCell.h"
#import "UITableViewCell+ConfigureCell.h"

@interface SNRollingWeatherPhotoCell : SNRollingBaseCell {
    SNWebImageView *photoImageView;
}

@end
