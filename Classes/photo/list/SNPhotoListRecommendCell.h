//
//  SNPhotoListRecommendCell.h
//  sohunews
//
//  Created by jialei on 13-8-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNAdDataCarrier.h"

@interface SNPhotoListRecommendCell : UITableViewCell
{
    id _delegate;
}

@property(nonatomic,assign)id delegate;
@property (nonatomic, retain) SNAdDataCarrier *sdkAdRecommend;
@property (nonatomic, retain) SNAdDataCarrier *sdkAdTextPic;

+ (float)heightForRecommdendCell:(GalleryItem *)item;

- (void)setObject:(GalleryItem *)obj;

@end
