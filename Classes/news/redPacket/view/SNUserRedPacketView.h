//
//  SNUserRedPacketView.h
//  sohunews
//
//  Created by wangyy on 16/2/24.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRedPacketInfoCell.h"

@interface SNUserRedPacketView : UIView

@property (nonatomic, assign) SNRedPacketType redPacketType;
@property (nonatomic, assign) BOOL isFromRedPacketActivity;//区分首页流和活动页红包提现
@property (nonatomic, strong) NSString *drawTime;

- (id)initWithFrame:(CGRect)frame redPacketType:(SNRedPacketType)packetType;
- (void)showUserRedPacket;
- (void)updateContentView:(SNRedPacketItem *)redPacketItem;

@end
