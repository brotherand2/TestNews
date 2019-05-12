//
//  SNUserAccountManageView.h
//  sohunews
//
//  Created by yangln on 14-10-1.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NICK_NAME_TAG 100
#define GENDER_TAG 101
#define LOCATION_TAG 102
#define MOBILE_BIND_TAG 103

typedef enum
{
    SNMultiRowsPlain,
    SNMultiRowsLeftRightText,
    SNMultiRowsImageText,
    SNMultiRowsTextField
    
} SNMultiRowsType;

@protocol SNUserAccountManageDelegate <NSObject>

- (void)tapUILabelIndex:(NSInteger)index tag:(NSInteger)aTag;

@end

@interface SNUserAccountManageView : UIView {
    NSInteger _pointY;
    NSInteger _currentItems;
}

@property(nonatomic,weak) id<SNUserAccountManageDelegate> delegate;

- (void)addItemUpDownText:(NSString *)aUp downText:(UILabel *)aDownLabel;
- (void)addItemImage:(SNWebImageView*)aImage text:(NSString *)aText;
- (void)addItemTextField:(UITextField *)aTextField upText:(NSString *)aText;
- (void)addSingleItem:(NSString *)aText;
- (void)drawSeperateLine:(CGRect)rect;

@end
