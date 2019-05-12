//
//  SNNewsSpeakerView.h
//  sohunews
//
//  Created by weibin cheng on 14-6-18.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNNewsSpeaker.h"

typedef NS_ENUM(NSInteger, SNListenNewsError) {
    SNListenNewsErrorTimeOut = 10114,
    SNListenNewsErrorNoNetWork = 20019
};

static const CGFloat kNewsSpeakerViewHeight = 460.0/2;

typedef void(^SNNewsSpeakerViewCloseBlock)(void);

@protocol SNSpeakerRemoteControlDelegate

@optional
- (void)remoteControlPauseOrPlay;
- (void)remoteControlPreviousTrack;
- (void)remoteControlNextTrack;

@end

@interface SNNewsSpeakerView : UIView<SNNewsSpeakerDelegate>
{
    UILabel* _titleLabel;
    UIButton* _pauseButton;
    UIButton* _nextButton;
    UIButton* _previousButton;
}
@property(nonatomic, copy) SNNewsSpeakerViewCloseBlock closeBlock;
@property(nonatomic, weak)id<SNSpeakerRemoteControlDelegate> delegate;

@end
