//
//  GlanceController.m
//  sohunews WatchKit App Extension
//
//  Created by iEvil on 12/4/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import "GlanceController.h"
#import "SNWDefine.h"
#import "SNWTools.h"

@interface GlanceController() {
    NSDateFormatter *formatter;
}

@property (weak, nonatomic) IBOutlet WKInterfaceImage *hudImage;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *lowerGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabelNoPic;

@property (copy, nonatomic) NSString *link;
@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self p_initUI];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self p_updateData];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self stopHandoff];
}

- (void)p_initUI {
    [self.hudImage setImageNamed:@"dot"];
}

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

- (void)setImageWithUrl:(NSString *)imageUrl {
    // 判断有无图片
    if (imageUrl) {
        [self.titleLabel setHidden:NO];
        [self.titleLabelNoPic setHidden:YES];
        
        //先设置占位图片
        [self.lowerGroup setBackgroundImageNamed:@"placeholder"];
        [SNWTools getDataFromServerWithType:RequestType_getImage Url:imageUrl Reply:^(NSDictionary *replyInfo, NSError *error) {
            if (replyInfo[@"data"]) {
                NSData *imageData = replyInfo[@"data"];
                if (imageData) {
                    [self.lowerGroup setBackgroundImageData:imageData];
                }
            }
        }];
    } else {
        // 若无图片地址
        [self.titleLabel setHidden:YES];
        [self.titleLabelNoPic setHidden:NO];
        [self.lowerGroup setBackgroundImage:nil];
    }
}

- (void)p_updateData {
    // 开始更新
    [self startHud];
    [SNWTools getTopNews:^(NSDictionary *topNews) {
        NSArray *list = topNews[snw_list_pushs];
        if (list.count > 0) {
            NSDictionary *firstDict = list[0];
            if (firstDict.count > 0) {
                self.link = firstDict[snw_list_link];
                [self sendHandoff];
                
                [self.titleLabel setText:firstDict[snw_list_title]];
                [self.titleLabelNoPic setText:firstDict[snw_list_title]];
                [self.timeLabel setText:[self relativelyDate:firstDict[snw_list_updateTime]]];
                
                NSArray *imageArray = firstDict[snw_list_image_url];
                if ([imageArray isKindOfClass:[NSArray class]] &&
                    imageArray.count > 0) {
                    [self setImageWithUrl:imageArray[0]];
                } else {
                    [self setImageWithUrl:nil];
                }
            }
        }
        [self stopHud];
    }];
}

- (void)startHud {
    [self.hudImage setHidden:NO];
    [self.hudImage startAnimating];
}

- (void)stopHud {
    [self.hudImage stopAnimating];
    [self.hudImage setHidden:YES];
}

- (void)sendHandoff {
    if (_link.length > 0) {
        [self updateUserActivity:snw_handoff_view_detail_identifier userInfo:@{snw_handoff_news_url : _link, snw_handoff_version : snw_handoff_current_version} webpageURL:nil];
    }
}

- (void)stopHandoff {
    [self invalidateUserActivity];
}

@end
