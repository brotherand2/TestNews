//
//  SNFeedBackImageModel.h
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackModel.h"

@interface SNFeedBackImageModel : SNFeedBackModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) UIImage *navImage;
@property (nonatomic, assign) CGFloat imgHeight;
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, copy) NSString *originalImageUrl;
@end
