//
//  SNNewsSpeakerManager.h
//  sohunews
//
//  Created by weibin cheng on 14-6-19.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsSpeakerView.h"

@interface SNNewsSpeakerManager : NSObject<SNSpeakerRemoteControlDelegate>

+ (SNNewsSpeakerManager*)shareManager;

- (void)showNewsSpeakerViewWithList:(NSArray *)newsList;

- (void)closeNewsSpeakerView;
@end
