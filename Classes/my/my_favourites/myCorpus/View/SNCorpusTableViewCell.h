//
//  SNCorpusTableViewCell.h
//  sohunews
//
//  Created by Scarlett on 15/8/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"

#define kCorpusTableViewCellHeight ((kAppScreenWidth > 375.0) ? 266.0/3 : 161.0/2)
#define kCorpusCellImageLeftDistance ((kAppScreenWidth > 375.0) ? 42.0/3 : 33.0/2)
#define kCorpusCellImageRightDistance ((kAppScreenWidth > 375.0) ? 42.0/3 : 33.0/2)
#define kCorpusCellImageWidth ((kAppScreenWidth > 375.0) ? 156.0/3 : 95.0/2)
#define kCorpusDeleteImageWidth ((kAppScreenWidth > 375.0) ? 84.0/3 : 48.0/2)

@class SNCorpusTableViewCell;

@protocol SNCorpusTableViewCellDelegate <NSObject>

@optional
- (void)updateCorpusNameWithDict:(NSDictionary *)dict;
- (void)resetToolBar;
- (void)refreshCorpusListWithDict:(NSDictionary *)dict;

@end

typedef void(^CorpusBlock)(SNCorpusTableViewCell *cell);

@interface SNCorpusTableViewCell : SNTableViewCell

@property (nonatomic, strong) UITextField *itemTextField;
@property (nonatomic, copy) CorpusBlock corpusBlock;
@property (nonatomic, weak) id<SNCorpusTableViewCellDelegate> delegate;

- (void)setCellItemWithImagName:(NSString *)imageName text:(NSString *)text corpusID:(NSString *)corpusID isEditMode:(BOOL)isEditMode textColor:(NSString *)textColor;
- (void)cellDeleteMode:(CGFloat)duration;
- (void)cellNormalMode;
- (void)changeCorpusName;
- (void)finishManageCorpus;
@end
