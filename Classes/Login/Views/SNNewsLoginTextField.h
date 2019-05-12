//
//  SNNewsLoginTextField.h
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SNNewsLoginTextFieldDelegate;
@interface SNNewsLoginTextField : UIView

@property (nonatomic,weak) id <SNNewsLoginTextFieldDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame WithType:(NSString*)type;
- (NSString*)text;

- (void)setPassWordFieldRect:(CGRect)rect;
    
- (BOOL)resignFirstResponder;

- (void)setEnable:(BOOL)enable;
- (BOOL)enable;

- (void)setText:(NSString*)text;

- (void)becomeFirst;

@end

@protocol SNNewsLoginTextFieldDelegate <NSObject>

- (void)textFieldDidChangeText:(SNNewsLoginTextField*)textField;
- (void)textFieldReturnClick:(SNNewsLoginTextField*)textField;

@end
