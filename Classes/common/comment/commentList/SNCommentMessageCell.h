//
//  SNCommentMessageCell.h
//  sohunews
//
//  Created by 贾 磊 on 14-2-19.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCommentListCell.h"

@interface SNCommentMessageCell : SNCommentListCell
{
//    FGalleryPhotoView *_photoView;
//    UIView *_imageDetailView;
}

+ (float)rowHeightForObject:(SNNewsComment *)comment;

@end
