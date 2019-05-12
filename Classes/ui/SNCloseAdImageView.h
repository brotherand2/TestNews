//
//  SNCloseAdImageView.h
//  sohunews
//
//  Created by HuangZhen on 11/07/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//


typedef void(^SNCloseAdAction)(id sender);
typedef void(^SNClickAdAction)();

@interface SNCloseAdImageView : UIView

/**
 default YES
 */
@property (nonatomic, assign) BOOL closeEnable;

- (instancetype)initWithFrame:(CGRect)frame closeAction:(SNCloseAdAction)closeAction clikcAction:(SNClickAdAction)clikcAction;

- (void)loadImageWithUrl:(NSString *)url completed:(SNWebImageCompleteBlock)completedBlock;

- (void)loadImageWithUrl:(NSString *)url  size:(CGSize)size completed:(SNWebImageCompleteBlock)completedBlock;

- (void)setCloseButtonOrigin:(CGPoint)origin;
- (void)setBackgroundViewHidden:(BOOL)hidden;
- (void)setBottomLineHidden:(BOOL)hidden;

@end
