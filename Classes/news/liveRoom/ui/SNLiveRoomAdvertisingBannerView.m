//
//  SNLiveRoomAdvertisingBannerView.m
//  sohunews
//
//  Created by lijian on 15-3-26.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomAdvertisingBannerView.h"
#import "SNWebImageView.h"

@interface SNLiveRoomAdvertisingBannerView()
{
    UIButton *_btnClose;
}
@property (nonatomic,copy) handleAdvertisingClose closeHandle;

@end

@implementation SNLiveRoomAdvertisingBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self){
        
        //downloading_canceldownload_press@2x
        /*
        _tuiguang = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 13)];
        _tuiguang.backgroundColor = [UIColor clearColor];
        _tuiguang.textAlignment = NSTextAlignmentLeft;
        _tuiguang.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBlue1Color];
        _tuiguang.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _tuiguang.text = @"广告";
        [self addSubview:_tuiguang];
        */
        
        /*
        UIImage *image = [UIImage imageNamed:@"downloading_canceldownload.png"];
        UIImage *imageH = [UIImage imageNamed:@"downloading_canceldownload_press.png"];
        _btnClose = [[UIButton alloc] initWithFrame:CGRectZero];
        _btnClose.backgroundColor = [UIColor clearColor];
        [_btnClose addTarget:self action:@selector(clickOn:) forControlEvents:UIControlEventTouchUpInside];
        [_btnClose setBackgroundImage:image forState:UIControlStateNormal];
        [_btnClose setBackgroundImage:imageH forState:UIControlStateHighlighted];
        _btnClose.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        _btnClose.hidden = YES;
        
        [self addSubview:_btnClose];
        */
        [self.adImgView setDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder9]];
//        [self setDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder9]];
        [SNNotificationManager addObserver:self selector:@selector(onThemeChanged:) name:kThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if(CGRectEqualToRect(frame, CGRectZero)){
        return;
    }
    
    //_btnClose.right = frame.size.width;
    //_btnClose.hidden = NO;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    
    //TT_RELEASE_CF_SAFELY(_btnClose);
}


- (void)onThemeChanged:(id)sender {

    //NSString *colorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText1Color];
    //_tuiguang.textColor = [UIColor colorFromString:colorString];
    //_tuiguang.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBlue1Color];
    self.alpha = themeImageAlphaValue();
}

- (void)clickOn:(id)sender
{
    if(nil != self.closeHandle){
        self.closeHandle();
        
        //[self removeFromSuperview];
    }
}

- (void)closeAdvetising:(handleAdvertisingClose)handle
{
    self.closeHandle = handle;
}
@end
