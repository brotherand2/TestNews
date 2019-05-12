//
//  SNNewAlertView.h
//  sohunews
//
//  Created by 李腾 on 2016/12/1.
//  Copyright © 2016年 sohu. All rights reserved.
//


#import "SNBaseAlertView.h"

@class SNNewAlertView;

@protocol SNNewAlertViewDelegate <NSObject>

@optional
- (void)willAppearAlertView:(SNNewAlertView *)alertView;
- (void)didAppearAlertView:(SNNewAlertView *)alertView;
// !!注意: buttonIndex  1 代表取消按钮或者点击了弹窗之外的区域 ， 2  代表 otherButton
- (void)willDisAppearAlertView:(SNNewAlertView *)alertView withButtonIndex:(NSInteger)buttonIndex;
- (void)didDisAppearAlertView:(SNNewAlertView *)alertView withButtonIndex:(NSInteger)buttonIndex;
- (void)cancelButtonClickedOnAlertView:(SNNewAlertView *)alertView;
- (void)otherButtonClickedOnAlertView:(SNNewAlertView *)alertView;

@end

typedef NS_ENUM(NSUInteger, SNNewAlertViewStyle) {
    SNNewAlertViewStyleAlert       = 0,  // Default is alert.
    SNNewAlertViewStyleActionSheet = 1
};



@interface SNNewAlertView: SNBaseAlertView

#pragma mark - Public Properties

@property (nonatomic, weak) id<SNNewAlertViewDelegate> delegate;

#pragma mark - Public Methods

// Initialize method, same as UIAlertView
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitle:(NSString *)otherButtonTitle;

// Initialize convenience method,default alertStyle is SNNewAlertViewStyleAlert
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitle:(NSString *)otherButtonTitle;

// Initialize With Custom View (Specify the frame of the contentView).
- (instancetype)initWithContentView:(UIView *)contentView
                  cancelButtonTitle:(NSString *)cancelButtonTitle
                   otherButtonTitle:(NSString *)otherButtonTitle
                         alertStyle:(SNNewAlertViewStyle)alertStyle;

// Initialize With Custom View 
- (instancetype)initWithContentView:(UIView *)contentView
                    backgroundColor:(UIColor *)backgroundColor
                         alertStyle:(SNNewAlertViewStyle)alertStyle;


// Handle Actions with Block
- (void)actionWithBlocksCancelButtonHandler:(void (^)(void))cancelHandler
                         otherButtonHandler:(void (^)(void))otherHandler;


/**
 *  Show in specified view
 */
- (void)showInView:(UIView *)view;

/**
 *  Show in window
 */
- (void)show;

/**
 *  Dismiss the alert
 */
- (void)dismiss;
/**
 *  Dismiss the alert with completionBlock
 */
- (void)dismissWithCompletion:(void (^)(void))completion;

/**
 * Dismiss the alert Anywhere
 */
+ (void)forceDismissAlertView;

@end

