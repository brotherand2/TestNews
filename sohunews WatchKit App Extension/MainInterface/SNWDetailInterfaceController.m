//
//  SNWDetailInterfaceController.m
//  sohunews
//
//  Created by iEvil on 12/7/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import "SNWDetailInterfaceController.h"
#import "WatchSessionManager.h"
#import "SNWDefine.h"

@interface SNWDetailInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *ballGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *arrowImage;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *detailLabel;

@property (copy, nonatomic) NSString *link;     //打开文章页的Link
@property (copy, nonatomic) NSString *logParams;

@end

@implementation SNWDetailInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //获取内容
    self.link = context[snw_handoff_news_url];
    self.logParams = context[snw_handoff_news_log_params];
}

- (void)willActivate {
    [super willActivate];
    
    //显示文字
    [self p_startUIAnimation];
    
    //Send Handoff
    [self p_sendHandoff];
    
    //发送用户数据
    [self p_sendUserLog];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    
    //Stop Handoff
    [self p_stopHandoff];
}

- (void)p_startUIAnimation {
    [self.ballGroup setBackgroundImageNamed:@"ball"];
    [self.ballGroup startAnimatingWithImagesInRange:NSMakeRange(0, 10) duration:0.3 repeatCount:1];
    
    [self.arrowImage setImageNamed:@"arrow"];
    [self.arrowImage startAnimatingWithImagesInRange:NSMakeRange(0, 8) duration:0.4 repeatCount:1];
    
    [self.titleLabel setText:@"内容已同步"];
    [self.detailLabel setText:@"请到iPhone上查看"];
}

- (void)p_sendHandoff {
    if (_link.length > 0) {
        [self updateUserActivity:snw_handoff_view_detail_identifier userInfo:@{snw_handoff_news_url : _link, snw_handoff_version : snw_handoff_current_version} webpageURL:nil];
    }
}

- (void)p_stopHandoff {
    [self invalidateUserActivity];
}

- (void)p_sendUserLog {
    [[WatchSessionManager sharedInstance] updateApplicationContext:@{snw_host_userLog : snw_host_userLog, snw_host_logParams : _logParams}];
}

@end
