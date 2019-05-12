//
//  SNSmallCorpusTableViewCell.h
//  sohunews
//
//  Created by Scarlett on 15/9/2.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"

#define kHFHighViewHeight ((kAppScreenWidth > 375.0) ? 934.0/3 : 564.0/2)
#define kSmallCorpusTabelTopDistance ((kAppScreenWidth > 375.0) ? 2.0/3 : 5.0/2)
#define kSmallCorpusTabelLeftDistance ((kAppScreenWidth > 375.0) ? 42.0/3 : 33.0/2)
#define kSmallCorpusTabelHeight ((kAppScreenWidth > 375.0) ? (kHFHighViewHeight - kSmallCorpusTabelTopDistance - 173.0/3 - 20) : (kHFHighViewHeight - kSmallCorpusTabelTopDistance - 105.0/2 - 20))
#define kSmallCorpusTabelCellHeight 45.0f //((kAppScreenWidth > 375.0) ? 144.0/3 : 96.0/2)
#define kSmallImageViewWidth ((kAppScreenWidth > 375.0) ? 64.0/3 : 40.0/2)

@interface SNSmallCorpusTableViewCell : SNTableViewCell

- (void)setCellWithText:(NSString *)text imageName:(NSString *)imageName;

@end
