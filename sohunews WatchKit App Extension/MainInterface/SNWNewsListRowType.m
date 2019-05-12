//
//  SNWNewsListRowType.m
//  sohunews
//
//  Created by tt on 15-4-1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNWNewsListRowType.h"
#import "SNWDefine.h"
#import "SNWTools.h"

@interface SNWNewsListRowType () {
    NSDateFormatter *formatter;
}

@end

@implementation SNWNewsListRowType

- (NSString *)relativelyDate:(NSString *)doubleString {
    if (doubleString.length > 0 && ![doubleString isEqualToString:@"0"]) {
        NSDate *dateParam = [NSDate dateWithTimeIntervalSince1970:[doubleString doubleValue] / 1000];
        if (formatter == nil) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"M/dd H:mm"];
        }
        return [formatter stringFromDate:dateParam];
    }
    return nil;
}

- (void)setImageWithUrl:(NSString *)imageUrl
                  title:(NSString *)text
                   time:(NSString *)time {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //设置标题
        if (text.length == 0) {
            [self.titleLabel setText:@"此文章标题未加载成功, 请尝试长按刷新"];
        } else {
            [self.titleLabel setText:text];
        }
        //设置日期
        if (time.length == 0) {
            [self.timeLabel setText:[[NSDate date] description]];
        } else {
            [self.timeLabel setText:[self relativelyDate:time]];
        }
    });
    //判断有无图片
    if (imageUrl) {
        // 先设置占位图片
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.rowGroup setBackgroundImageNamed:@"placeholder"];
        });
        
        // 分别获取每张图片 ImageCache不支持OS2
        [SNWTools getDataFromServerWithType:RequestType_getImage
                                        Url:imageUrl
                                      Reply:^(NSDictionary *replyInfo, NSError *error) {
            if (replyInfo[@"data"]) {
                NSData *imageData = replyInfo[@"data"];
                if (imageData) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self.rowGroup setBackgroundImageData:imageData];
                    });
                }
            }
        }];
    } else {
        [self.rowGroup setHeight:0];
        [self.rowGroup setBackgroundImage:nil];
        
        [self.maskGroup setHeight:0];
        [self.maskGroup setBackgroundImage:nil];
    }
}

@end
