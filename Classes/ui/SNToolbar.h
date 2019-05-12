//
//  SNPhotoGalleryToolbar.h
//  sohunews
//
//  Created by Dan on 6/30/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNDevice.h"


#define kToolbarHeight ([[SNDevice sharedInstance] isPlus]?(146.0 / 3.0):(45.0))
#define kToolbarHeightWithoutShadow 42

#define kToolBarBtnImgWidth             ((kAppScreenWidth == 320.0) ? 48.0/2 : ((kAppScreenWidth == 375.0) ? 48.0/2 : 70.0/2))

#define kToolBarBackBtnLeft             ((kAppScreenWidth == 320.0) ? 6 : ((kAppScreenWidth == 375.0) ? 10 : 32.0/3))
#define kToolBarShareBtnRight            ((kAppScreenWidth == 320.0) ? 36.0/2 : ((kAppScreenWidth == 375.0) ? 36.0/2 : 62.0/3))
#define kToolBarBtnSpace               ((kAppScreenWidth == 320.0) ? 62.0/2 : ((kAppScreenWidth == 375.0) ? 62.0/2 : 110.0/3))

typedef enum
{
    SNToolbarAlignCenter,
    SNToolbarAlignRight
}SNToolbarAlignType;


@interface SNToolbar : UIView
@property(nonatomic, strong)UIButton *leftButton;
@property(nonatomic, strong)UIButton *rightButton;

// public method
- (UIImageView *)backgroundView;
- (void)setBackgroundImage:(UIImage *)image;
- (void)setButtons:(NSArray *)btns;
- (void)setButtons:(NSArray *)btns withType:(SNToolbarAlignType)type;
- (void)show:(BOOL)show animated:(BOOL)animated;
- (void)replaceButtonAtIndex:(int)index withItem:(UIButton *)newItem;
- (void)updateUIForRotate;
- (void)hideShadowLine;
- (void)updateFullADStyle;
+ (CGFloat)toolbarHeight;
@end
