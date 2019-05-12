//
//  SNNewsScreenSharePic.h
//  sohunews
//
//  Created by wang shun on 2017/8/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SNNewsScreenSharePicDelegate;
@interface SNNewsScreenSharePic : NSObject

@property (nonatomic,weak) id <SNNewsScreenSharePicDelegate> delegate;

@property (nonatomic,strong) UIView* final_share_View;

@property (nonatomic,assign) BOOL isSHH5News;

@property (nonatomic,strong) NSString* weixin_openid;


@property (nonatomic,strong) NSString* selected;//勾选
@property (nonatomic,strong) NSString* headUrl;//头像
@property (nonatomic,strong) NSString* nickName;//nick

- (void)callShare:(NSMutableDictionary*)dic Title:(NSString*)title WithFinalView:(UIView*)final_view;

- (void)finishedShareClose:(id)sender;

- (BOOL)isShowHead:(id)sender;

- (void)save;

- (NSString*)isShowHeadFirst;

@end

@protocol SNNewsScreenSharePicDelegate <NSObject>

- (void)cleanPic;

- (void)changeQRImage:(UIImage*)qrImg;

- (void)removeSelf;

@end
