//
//  SNGuideRegister.h
//  sohunews
//
//  Created by jialei on 13-7-31.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineLoginViewController.h"
#import "SNLabel.h"
#import "SNBaseFavouriteObject.h"

typedef BOOL (^onLoginComplete)();

@protocol SNGuideLoginDelegate <NSObject>

- (void)guideLoginSuccess;
- (void)guideRegisterViewOnBack;

@end


@interface SNGuideRegisterViewController : SNTimelineLoginViewController
{
    NSString *_showtitle;
    NSString *_showName;
    NSString *_showIconUrl;
    UIImage *_showIcon;
    NSString *_tipText;
    
    UIImageView *_showIconBgView;
    UIImageView *_showIconMarkView;
    UILabel *_showNameLabel;
    SNLabel *_tipTextLabel;
    UIImageView *_showTipTextView;
    id _delegate;
    BOOL _needAutoSub;
    SNBaseFavouriteObject *_favouriteObject;
}

@property(nonatomic, copy) NSString *subId;
@property(nonatomic, strong)SNBaseFavouriteObject *favouriteObject;

@end
