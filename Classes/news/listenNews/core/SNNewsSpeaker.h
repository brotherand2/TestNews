//
//  SNNewsSpeaker.h
//  sohunews
//
//  Created by weibin cheng on 14-6-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNListenNewsList.h"
#import "iflyMSC/IFlySpeechError.h"

typedef NS_ENUM(NSInteger, SNNewsSpeakerState)
{
    SNNewsSpeakerStateWaiting,
    SNNewsSpeakerStateWorking,
    SNNewsSpeakerStatePaused,
    SNNewsSpeakerStateStopped
};

@protocol SNNewsSpeakerDelegate;

@interface SNNewsSpeaker : NSObject<SNListenNewsListDelegate>
@property(nonatomic, readonly, assign)SNNewsSpeakerState state;
@property(nonatomic, readonly, assign)NSInteger currentIndex;
@property(nonatomic, weak)id<SNNewsSpeakerDelegate> delegate;

+ (SNNewsSpeaker*)shareSpeaker;

- (void)startSpeaking:(NSArray*)newsList;

/**
 如果是停止状态会播放，如果是播放状态会暂停
 */
- (void)playOrPause;

/**
 单纯的暂停
 */
- (void)pause;

- (void)stop;

- (void)speakNext;

- (void)speakPrevious;

- (NSString*)currentNewsTitle;

- (BOOL)isFirst;

- (BOOL)isEnd;

- (BOOL)isIFlyOnCompleted;

@end

@protocol SNNewsSpeakerDelegate <NSObject>

@optional
- (void)newsSpeakerContentDidChanged:(NSString*)title isFirst:(BOOL)first isEnd:(BOOL)end;

- (void)newsSpeakerStateDidChanged;

- (void)newsSpeakerDidFailed:(IFlySpeechError*)error;

- (void)newsSpeakerDidFinished;
@end
