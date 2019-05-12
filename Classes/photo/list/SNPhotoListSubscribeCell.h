//
//  SNPhotoListSubscribeCell.h
//  sohunews
//
//  Created by jialei on 13-8-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewCell.h"
@interface SNPhotoListSubscribeCell : SNTableViewCell

+ (float)heightForSubscribeCell;
- (void)setObject:(SCSubscribeObject *)subObj;

@end
