//
//  SNPasteBoardAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/28.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPasteBoardAlert.h"
#import "SNNewAlertView.h"

@interface SNPasteBoardAlert ()
@property (nonatomic, strong) SNNewAlertView *pasteBoardAlert;
@end

@implementation SNPasteBoardAlert

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        self.alertViewType = SNAlertViewPasteBoardType;
        [self setAlertViewData:content];
    }
    return self;
}

- (void)showAlertView {
    if (self.pasteBoardAlert) {
        [self.pasteBoardAlert show];
    } else {
        [self dismissAlertView];
    }
}


- (void)setAlertViewData:(id)content {
    if (content && [content isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)content;
        NSString *text = [dict stringValueForKey:@"text" defaultValue:@""];
        NSString *url = [dict stringValueForKey:@"url" defaultValue:@""];
        if (text.length > 0 && url.length > 0) {
            //弹出浮层
            SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:[text URLDecodedString] delegate:nil cancelButtonTitle:@"关闭" otherButtonTitle:@"立即查看"];
            self.pasteBoardAlert = alertView;
            self.pasteBoardAlert.alertViewType = SNAlertViewPasteBoardType;
            [alertView actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
                [SNUtility openProtocolUrl:[url URLDecodedString]];
            }];
        }
    }
}

- (void)dealloc {
    self.pasteBoardAlert = nil;
}

@end
