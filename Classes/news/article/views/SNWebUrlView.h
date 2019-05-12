//
//  SNWebUrlView.h
//  sohunews
//
//  Created by jojo on 14-3-10.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SNSubscribeButtonAdd,
    SNSubscribeButtonDel,
    SNSubscribeButtonHide,
} SNSubscribeButtonState;

@protocol SNWebUrlViewDelegate <NSObject>
- (void)refreshWebView;
- (void)clickIconView;
- (void)subscribeAction;
- (void)unSubscribeAciton;

@end

@interface SNWebUrlView : UIView /*<UITextFieldDelegate>*/{
    UIImageView *logoImageView;
    UIImageView *backgroundImageView;
//    UITextField *urlTextField;
    UIButton *refreshButton;
    NSString *link;
    UIButton *iconButton;
    id<SNWebUrlViewDelegate> __weak delegate;
    
    UILabel *_titleLabel;
    UIImageView *_coverImageView;
}
@property(nonatomic,strong)NSString *link;
@property(nonatomic,weak)id<SNWebUrlViewDelegate> delegate;
@property (nonatomic, assign) SNSubscribeButtonState buttonState;

- (void)updateLogoUrl:(NSString *) logoUrl withLink:(NSString *) urlString;
- (void)updateTile:(NSString *)title;
//- (BOOL)resignFirstResponder;
- (void)updateTheme;
- (void)disableSohuIcon;
- (void)updateUIForRotate:(BOOL)landscape;
- (void)refreshButtonState;

@end
