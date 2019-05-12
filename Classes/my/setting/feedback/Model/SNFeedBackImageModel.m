//
//  SNFeedBackImageModel.m
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackImageModel.h"

@implementation SNFeedBackImageModel

+ (CGFloat)calRowHeightWithModel:(SNFeedBackImageModel *)model {
//    if (model.row == 0) {
//        return 276;
//    }
     CGFloat height = 0;
    if (!model.isHideDate) {
        
        height += kFBDateTopMargin + 11.0f + kFBNameTopMargin;
    }
     height += kFBDateTopMargin + 13.0f + 4.0f + kFBBubblrBottomMargin * 2;
    CGSize imageSize;
    if (model.navImage == nil) {
        imageSize = [UIImage getImageWithSize:CGSizeMake(model.imgWidth, model.imgHeight) resizeWithMaxSize:CGSizeMake(kFBImageWidth, kFBImageHeight)];
    } else {
        imageSize = [UIImage getImageWithSize:model.navImage.size resizeWithMaxSize:CGSizeMake(kFBImageWidth, kFBImageHeight)];
    }
     height += imageSize.height;
    
    return height;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [aCoder encodeFloat:self.imgWidth forKey:@"imgWidth"];
    [aCoder encodeFloat:self.imgHeight forKey:@"imgHeight"];
    [aCoder encodeObject:self.originalImageUrl forKey:@"originalImageUrl"];
    if (_navImage != nil) {
        
        NSData *imgData = UIImageJPEGRepresentation(_navImage, 1.0);
        [aCoder encodeObject:imgData forKey:@"imgData"];
    }
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        self.originalImageUrl = [aDecoder decodeObjectForKey:@"originalImageUrl"];
        self.imgWidth = [aDecoder decodeFloatForKey:@"imgWidth"];
        self.imgHeight = [aDecoder decodeFloatForKey:@"imgHeight"];
        NSData *imgData = [aDecoder decodeObjectForKey:@"imgData"];
        if (imgData != nil) {
            
            self.navImage = [UIImage imageWithData:imgData];
        }
        
    }
    return self;
}


@end
