//
//  SNNewsLoginPhoneVerifyBtn.m
//  sohunews
//
//  Created by wang shun on 2017/7/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginPhoneVerifyBtn.h"
#import "SNNewsLoginPhoneVerifyRequest.h"
#import "SNMobileValidateRequest.h"

#import "SNNewAlertView.h"

#define PhoneVerifyBtCountDownTime 60

@interface SNNewsLoginPhoneVerifyBtn ()<SNNewAlertViewDelegate>
{
    BOOL isSendSms;//已经发送过请求
    
    __block int timeout;//计时
    dispatch_source_t _timer;
}
@property (nonatomic,strong) NSDate* fisrtClickDate;

@end


@implementation SNNewsLoginPhoneVerifyBtn

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        isSendSms = NO;
        [self createBtn];
    }
    return self;
}

- (void)createBtn{
    
    NSDictionary* dic = @{NSFontAttributeName:[UIFont systemFontOfSize:11]};
    
    NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:@"收不到验证码? 来试试语音验证" attributes:dic];
    [str addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeText3Color) range:NSMakeRange(0, 7)];
    [str addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeBlue2Color) range:NSMakeRange(7, 8)];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"收不到验证码? 来试试语音验证" forState:UIControlStateNormal];
//    [btn setTitleColor:SNUICOLOR(kThemeBlue2Color) forState:UIControlStateNormal];
    [btn setAttributedTitle:str forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setFrame:CGRectMake((self.frame.size.width-170)/2, 0, 170, self.frame.size.height)];
    [self addSubview:btn];
    [btn addTarget:self action:@selector(phoneVerifyClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)phoneVerifyClick:(UIButton*)b{
    
    if (isSendSms == YES) {//如果请求已经发出
        double i = [self getDateInterval:[NSDate date] Date2:self.fisrtClickDate];
        if (i<=1) {
            NSString* str = @"使用太频繁啦~60秒后才能再次使用哦";
            if (timeout >0 && timeout < 60) {
                str = [NSString stringWithFormat:@"使用太频繁啦~%d秒后才能再次使用哦",timeout];
                [[SNCenterToast shareInstance] showCenterToastWithTitle:str toUrl:nil mode:SNCenterToastModeOnlyText];
                return;
            }
            else{
                isSendSms = NO;
            }
        }
        else{
            isSendSms = NO;
        }
    }
    
    self.fisrtClickDate = [NSDate date];
    [self phoneVerify];
}

- (void)phoneVerify{
    isSendSms = YES;

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(getCurrentPhoneNumberData)]) {
        NSDictionary* phoneNumberDic = [self.dataSource getCurrentPhoneNumberData];
        if (phoneNumberDic && phoneNumberDic.count>0) {
            //type 业务类型 signup：注册;signin：登录;bind：绑定手机;unbind：解绑手机
            NSString* phoneNumber = [phoneNumberDic objectForKey:@"mobileNo"];
            NSString* type        = [phoneNumberDic objectForKey:@"type"];
            
            [self isValidatePhone:phoneNumber Completion:^(BOOL finshed) {
                
                if(finshed == YES){
                    NSDictionary* params = @{@"mobileNo":phoneNumber,@"type":type,@"sendMethod":@"1"};
                    [[[SNNewsLoginPhoneVerifyRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
                        
                        NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
                        NSString* statusMsg  = [responseObject objectForKey:@"statusMsg"];
                        
                        if (statusCode.integerValue == 10000000) {//成功
                            [self showAlert:statusMsg];
                            [self countDownTime];
                        }
                        else if (statusCode.integerValue == 10000030){//
                            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
                        }
                        else if (statusCode.integerValue == 10000031){
                            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeOnlyText];
                        }
                        
                    } failure:^(SNBaseRequest *request, NSError *error) {
                        isSendSms = NO;
                    }];
                }
                else{
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入正确的手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
                    isSendSms = NO;
                }
            }];
        }
     }
}


- (void)isValidatePhone:(NSString*)text Completion:(void (^)(BOOL finshed))completion{
    
    if (text.length == 0){
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入手机号" toUrl:nil mode:SNCenterToastModeOnlyText];
        if (completion) {
            completion(NO);
        }
        return;
    }
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    [[[SNMobileValidateRequest alloc] initWithDictionary:@{@"mobileNo":text}] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        
        NSString *status = [responseObject stringValueForKey:@"statusCode" defaultValue:nil];
        
        /*
         #define kRightMobileNum @"30020001"//手机号正确：30020001
         #define kWrongMobileNum @"30020002"//手机号错误：30020002
         #define kEmptyMobileNum @"30020003"//手机号为空：30020003
         */

        if ([status isEqualToString:@"30020001"]) {
            if (completion) {
                completion(YES);
            }
        }
        else if ([status isEqualToString:@"30020002"] || [status isEqualToString:@"30020003"]) {
            if (completion) {
                completion(NO);
            }
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
        if (completion) {
            completion(NO);
        }
    }];

}

- (void)showAlert:(NSString*)title{
    
    SNNewAlertView *actionSheet = [[SNNewAlertView alloc] initWithTitle:nil message:title?:@"" cancelButtonTitle:@"我知道了" otherButtonTitle:nil];
    actionSheet.delegate = self;
    [actionSheet show];
}


//获取时间间隔
- (double)getDateInterval:(NSDate*)date1 Date2:(NSDate*)date2{
    // 时间1
    NSTimeZone *zone1 = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone1 secondsFromGMTForDate:date1];
    NSDate *localDate1 = [date1 dateByAddingTimeInterval:interval1];
    
    // 时间2
    NSTimeZone *zone2 = [NSTimeZone systemTimeZone];
    NSInteger interval2 = [zone2 secondsFromGMTForDate:date2];
    NSDate *localDate2 = [date2 dateByAddingTimeInterval:interval2];
    
    // 时间2与时间1之间的时间差（秒）
    double intervalTime = [localDate2 timeIntervalSinceReferenceDate] - [localDate1 timeIntervalSinceReferenceDate];
    return intervalTime;
}


#pragma mark count-down time
- (void)countDownTime {
    timeout = PhoneVerifyBtCountDownTime; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if (timeout<=0) { //倒计时结束，关闭
            [self cancelTimer];
        }
        else {            
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void)cancelTimer{
    isSendSms = NO;
    if(!_timer)
        return;
    dispatch_source_cancel(_timer);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
