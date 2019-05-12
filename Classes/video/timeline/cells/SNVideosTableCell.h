//
//  SNVideosTableCell.h
//  sohunews
//
//  Created by chenhong on 13-9-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosTableBaseCell.h"

@class SNWebImageView;

@interface SNVideosTableCell : SNVideosTableBaseCell

+ (CGFloat)height;
- (void)updateFullscreenBtn;
- (void)updateDownloadBtn;

@end

@protocol SNVideosTableCellDelegate
- (BOOL)canRespondRotate;
@end
