//
//  SNRedPacketInfoCell.h
//  sohunews
//
//  Created by wangyy on 16/3/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRedPacketItem.h"

typedef enum {
    SNRedPacketNormal,  //普通红包
    SNRedPacketTask,    //任务红包
    SNRedPacketOther    //拆得红包
} SNRedPacketType;

@interface SNRedPacketInfoCell : UIView

@property (nonatomic, assign) SNRedPacketType redPacketType;

- (id)initWithFrame:(CGRect)frame redPacketType:(SNRedPacketType)packetType;
- (void)updateContentView:(SNRedPacketItem *)redPacketItem;

@end
