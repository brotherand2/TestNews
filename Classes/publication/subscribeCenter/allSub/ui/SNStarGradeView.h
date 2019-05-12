//
//  SNStarGradeView.h
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SNStarGradeViewStyleSmall = 0,
    SNStarGradeViewStyleBig,
    SNStarGradeViewStyleLarge
}SNStarGradeViewStyle;

// small
#define kGradeViewWidthSmall            ((14 * 5 + 4 * 4) / 2)
#define kGradeViewHeightSmall           (14 / 2)
#define kGradeViewSpaceSmall            (4 / 2)
#define kGradeViewStarSizeSmall         (14 / 2)

// big
#define kGradeViewWidthBig              ((30 * 5 + 12 * 4) / 2)
#define kGradeViewHeightBig             (30 / 2)
#define kGradeViewSpaceBig              (12 / 2)
#define kGradeViewStarSizeBig           (30 / 2)

// large
#define kGradeViewWidthLarge            ((54 * 5 + 10 * 4) / 2)
#define kGradeViewHeightLarge           (54 / 2)
#define kGradeViewSpaceLarge            (10 / 2)
#define kGradeViewStarSize              (54 / 2)

@interface SNStarGradeView : UIView {
    SNStarGradeViewStyle _style;
    BOOL _canEdit;
    
    NSMutableArray *_startsButtonsArray;
    UIImageView *_maskStarButton;
    
    CGFloat _grade;
}

@property(nonatomic, assign) SNStarGradeViewStyle style;
@property(nonatomic, assign, setter = setEditable:) BOOL canEdit;
@property(nonatomic, assign) CGFloat grade;

- (id)initWithStyle:(SNStarGradeViewStyle)style canEdit:(BOOL)canEdit;

@end
