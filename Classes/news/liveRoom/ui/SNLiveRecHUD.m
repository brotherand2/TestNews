//
//  SNLiveRecHUD.m
//  sohunews
//
//  Created by chenhong on 13-7-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRecHUD.h"

@interface SNLiveRecHUD () {
    UIView *_bg;
    UIImageView *_hud;
    UIImageView *_iconBg;
    UIImageView *_icon;
    
    UILabel *_time;
    UILabel *_info;
    
    BOOL _bState;
}

@end

@implementation SNLiveRecHUD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self loadView];
    }
    return self;
}

- (void)dealloc {
     //(_hud);
     //(_iconBg);
     //(_icon);
     //(_info);
     //(_time);
}

- (void)loadView {
    
    _hud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_rec_hud.png"]];
    _hud.center = self.center;
    [self addSubview:_hud];
    
    CGPoint hudCenter =  CGPointMake(_hud.width/2, _hud.height/2);
    
    _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_rec_mic_top.png"]];
    _icon.center = hudCenter;
    [_hud addSubview:_icon];
    
    _iconBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_rec_mic_bottom.png"]];
    _iconBg.clipsToBounds = YES;
    _iconBg.contentMode = UIViewContentModeTop;
    _iconBg.center = hudCenter;
    [_hud addSubview:_iconBg];
    //_iconBg.hidden = YES;

    _info = [[UILabel alloc] initWithFrame:CGRectMake(0, _hud.height-31, _hud.width, 15)];
    [_hud addSubview:_info];
    _info.font = [UIFont systemFontOfSize:14];
    _info.textAlignment = NSTextAlignmentCenter;
    _info.textColor = [UIColor whiteColor];
    _info.backgroundColor = [UIColor clearColor];
    _info.text = @"上滑取消发送";
    
    _time = [[UILabel alloc] initWithFrame:CGRectMake(92, 20, 40, 16)];
    [_hud addSubview:_time];
    _time.font = [UIFont systemFontOfSize:15];
    _time.textAlignment = NSTextAlignmentCenter;
    _time.textColor = [UIColor whiteColor];
    _time.backgroundColor = [UIColor clearColor];
    _time.text = @"";
}


- (void)changeToCancelState:(BOOL)bCancel {
    if (bCancel) {
        if (bCancel != _bState) {
            _bState = bCancel;
            
            // 切换为取消发送状态
            _info.text = @"松开取消发送";
            _info.textColor = [UIColor redColor];
            _icon.image = [UIImage imageNamed:@"live_rec_cancel.png"];
            _iconBg.hidden = YES;
        }
    } else {
        if (bCancel != _bState) {
            _bState = bCancel;
            
            // 切换为正常录音状态
            _info.text = @"上滑取消发送";
            _info.textColor = [UIColor whiteColor];
            _icon.image = [UIImage imageNamed:@"live_rec_mic_top.png"];
            _iconBg.hidden = NO;
        }
    }
}

- (void)setTime:(NSString *)timeStr {
    _time.text = timeStr;
}

- (void)setLevelMeterDB:(float)lvl {
    float ratio = MAX(0, MIN(1, lvl*1.2));
    [_iconBg.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        _iconBg.height = 286/2 * (1 - ratio);
    }];
}

@end
