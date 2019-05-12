//
//  SNRollingWeatherCell.h
//  sohunews
//
//  Created by lhp on 12/5/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingBaseCell.h"

@interface SNRollingWeatherCell : SNRollingBaseCell {
    UILabel *cityLabel;
    UILabel *weatherLabel;
    UIImageView *weatherImageView;
    UILabel *curTemperatureLabel;
    
    UILabel *airQualityLabel;
}
@end
