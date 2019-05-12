//
//  SNChannelPromotionView.h
//  sohunews
//
//  Created by Cae on 15/4/17.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNChannelPromotionView : UIView


@property (nonatomic, retain) NSArray *modelArray;

- (id) initWithModelArray:(NSArray *)array;

- (void) updateTheme;

+ (NSInteger) heightForModelArray:(NSArray *)modelArray;

@end
