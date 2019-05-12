//
//  SNPhotosChannelDataSource.h
//  sohunews
//
//  Created by wang yanchen on 13-1-5.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNScrollTabBarDataSourceWrapper.h"
#import "SNTagPhotoModel.h"

@interface SNPhotosChannelDataSource : SNScrollTabBarDataSourceWrapper {
    SNTagPhotoModel *_model;
}

@property(nonatomic, retain) SNTagPhotoModel *model;

@end
