//
//  SNMoreActionButton.h
//  sohunews
//
//  Created by lhp on 11/20/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SNMoreActionButtonTypeNight,
    SNMoreActionButtonTypePic,
    SNMoreActionButtonTypeUninterested,
    SNMoreActionButtonTypeReport,
    SNMoreActionButtonTypeShare,
    SNMoreActionButtonTypeFavorites,
    SNMoreActionButtonTypeDefault,

}SNMoreActionButtonType;

#define kButtonImageWidth  50

@protocol SNMoreActionButtonDelegate;
@interface SNMoreActionButton : UIButton {
    
    UIImageView *buttonImageView;
    UILabel *titleLabel;
    SNMoreActionButtonType buttonType;
    id<SNMoreActionButtonDelegate> __weak delegate;
    
    BOOL isNightMode;
    BOOL isNonePicMode;
}

@property(nonatomic,weak) id<SNMoreActionButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
         buttonType:(SNMoreActionButtonType) type;

@end

@protocol SNMoreActionButtonDelegate <NSObject>
@optional

- (void)moreActionButtonSelectedType:(SNMoreActionButtonType) type isNightMode:(BOOL) isNight isNonePicMode:(BOOL) isNonePic;

@end
