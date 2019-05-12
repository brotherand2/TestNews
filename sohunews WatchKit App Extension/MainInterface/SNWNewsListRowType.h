//
//  SNWNewsListRowType.h
//  sohunews
//
//  Created by tt on 15-4-1.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface SNWNewsListRowType : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *rowGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *maskGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;

/**
 *  优先判断本地缓存，若没有，则通过host app的SDWebImage取图片，再缓存
 *
 *  @param imageUrl 图片在线地址
 *  @param text     文字
 *  @param time     日期
 */
- (void)setImageWithUrl:(NSString *)imageUrl
                  title:(NSString *)text
                   time:(NSString *)time;

@end