//
//  SNNewsMeUserPortraitCell.h
//  sohunews
//
//  Created by iOS_D on 2016/12/19.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//


#import "SNTableSelectStyleCell2.h"
@class SNNewsMeUserPortraitView;
@class SNNewsMeOpenUserPortraitView;
@interface SNNewsMeUserPortraitCell : SNTableSelectStyleCell2

@property (nonatomic,strong) SNNewsMeUserPortraitView* userPortraitView;
@property (nonatomic,strong) SNNewsMeOpenUserPortraitView* openUserView;
@property (nonatomic,strong) NSDictionary* info;

- (void)updateData:(NSDictionary*)info;
- (void)jumpLink;

+ (CGFloat)getCellHeight:(id)info;
+ (NSInteger)getUserStatus:(NSDictionary*)info;

@end


@interface SNNewsMeUserPortraitView : UIView

@property (nonatomic,strong) UIImageView* headImageView;
@property (nonatomic,strong) UIView* nightheadView;

@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic,strong) UILabel* subTitleLabel;
@property (nonatomic,strong) UIImageView* subImageView;

@property (nonatomic,strong) UIImageView* arrow;

- (void)updateData:(NSString*)name faceTypeTips:(NSString*)tips imageUrl:(NSString*)url;
- (void)updateTheme;

@end

@interface SNNewsMeOpenUserPortraitView : UIView

@property (nonatomic,strong) UIImageView* openImageView;
@property (nonatomic,strong) UILabel* contentLabel;

- (void)updateData:(NSString*)title;
- (void)updateTheme;

@end
