//
//  SNNewsScreenShareItemsView.m
//  sohunews
//
//  Created by wang shun on 2017/8/11.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShareItemsView.h"

#import "SNShareItemsView.h"
#import "SNNewsShareParamsHeader.h"

@interface SNNewsScreenShareItemsView ()


@end

@implementation SNNewsScreenShareItemsView

-(instancetype)initWithFrame:(CGRect)frame WithData:(NSArray*)shareIconsArr{
    if (self = [super initWithFrame:frame]) {
        [self createUI:shareIconsArr];
    }
    return self;
}

- (void)createUI:(NSArray*)arr{
    
    CGFloat y      = kAppScreenHeight* (45/1280.0);
    CGFloat height = kAppScreenHeight* (132/1280.0);
    
    __weak typeof(self)weakself = self;
    SNShareItemsView *screenShotShareView = [[SNShareItemsView alloc] initWithFrame:CGRectMake(0, y, kAppScreenWidth, height) shareItems:arr handler:^(NSString *title) {
        SNDebugLog(@"do someThing.....");

        [weakself share:title];
    }];

    [self addSubview:screenShotShareView];
}

- (void)share:(NSString*)t{
    if (t) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(shareTo:)]) {
            [self.delegate shareTo:t];
        }
    }
    
    //_act=share_to&_tp=clk&newsId=&channelid=
    /*
     s=weixin_blog 微信朋友圈
     
     s=weixin 微信好友
     
     s=sns_sohu 狐友
     */
    NSString* s = @"";
    if ([t isEqualToString:kShareTitleWechatSession] || [t isEqualToString:SNNewsShare_Icons_WeChat]) {
        s =@"weixin";
    }
    else if ([t isEqualToString:kShareTitleWechat] || [t isEqualToString:SNNewsShare_Icons_Timeline]){
        s =@"weixin_blog";
    }
    else if([t isEqualToString:kShareTitleMySohu] || [t isEqualToString:SNNewsShare_Icons_Sohu]){//狐友
        s =@"sns_sohu";
    }
    NSString* str = [NSString stringWithFormat:@"_act=share_view_to&_tp=clk&s=%@&newsId=&channelid=",s];
    [SNNewsReport reportADotGif:str];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
