//
//  SNCorpusRollingBigVideoCell.h
//  sohunews
//
//  Created by Scarlett on 16/6/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNCorpusRollingBigVideoCell : SNTableViewCell
@property (nonatomic, strong)NSString *videoID;
- (void)setCellInfoWithUrl:(NSString *)url newsType:(NSString *)newsType title:(NSString *)title time:(NSString *)time ids:(NSString *)ids isEditMode:(BOOL)isEditMode link:(NSString *)link videoID:(NSString *)videoID site:(NSString *)site tvPlayTime:(NSString *)tvPlayTime isItemSelected:(BOOL)isItemSelected;
- (void)autoPlayVideo;
- (void)stopPlayVideo;
+ (CGFloat)getCellHeight:(NSString *)title;
@end
