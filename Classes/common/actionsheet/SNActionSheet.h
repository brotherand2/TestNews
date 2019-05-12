//
//  SNActionView.h
//  sohunews
//
//  Created by lhp on 9/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNavigationBar.h"
#import "SNActionSheetLoginManager.h"

@protocol SNActionSheetDelegate;

typedef enum SNActionSheetType {
    SNActionSheetTypeDefault,
    SNActionSheetTypeLogin,
    SNActionSheetTypeCellMore,
}SNActionSheetType;

typedef enum SNActionSheetButtonType {
    SNActionSheetButtonTypeCancel           = 1001,
    SNActionSheetButtonTypeOthers           = 1002,
    SNActionSheetButtonTypeDestructive      = 1003,
}SNActionSheetButtonType;

@interface SNActionSheet : UIView {
    SNActionSheetType _type;
    int _viewHeight;
    int _contentHeight;
    NSInteger buttonCount;
    BOOL isShowKeyBoard;                        //关闭是否弹起键盘
    NSDictionary *userInfo;
    UIControl *_backgroundView;
    SNNavigationBar *_actionView;
    id<SNActionSheetDelegate> __weak delegate;
}

@property(nonatomic,weak)id<SNActionSheetDelegate> delegate;
@property(nonatomic,assign)BOOL isShowKeyBoard;
@property(nonatomic,strong)NSDictionary *userInfo;
@property(nonatomic,assign)BOOL disableDismissAction;

- (id)      initWithTitle:(NSString *)title
                 delegate:(id<SNActionSheetDelegate>) actionDelegate
                iconImage:(UIImage *) image
                  content:(NSString *) content
               actionType:(SNActionSheetType) type
        cancelButtonTitle:(NSString *)cancelButtonTitle
   destructiveButtonTitle:(NSString *)destructiveButtonTitle
        otherButtonTitles:(NSArray *)otherButtonTitles;

- (void)showActionViewAnimation;
- (void)closeAction;
- (void)initCancelButtonWithCancelButtonTitle:(NSString *) cancelButtonTitle;

@end

@protocol SNActionSheetDelegate <NSObject>
@optional


//buttonIndex 从下到上依次增加 0、1、2、3、...
- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)dismissActionSheetByTouchBgView:(SNActionSheet *)actionSheet;
@end
