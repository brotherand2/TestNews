//
//  SNSoundManager.h
//  sohunews
//
//  Created by chenhong on 13-4-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SNSoundItem.h"
#import "AMRPlayer.h"
#import "SNAudioStreamPlayer.h"

#define kSndDownloadUserInfoKey @"kSndDownloadUserInfoKey"

// 声音播放状态
typedef enum {
    SNSoundStatusDefault,           // 默认状态
    SNSoundStatusPlaying,           // 播放中
    SNSoundStatusDownloading,       // 下载中
    SNSoundStatusDownloadFailed,    // 下载失败
} SNSoundStatusType;

@interface SNSoundManager : NSObject <AVAudioPlayerDelegate, AMRPlayerDelegate, SNAudioStreamPlayerDelegate> {
    SNSoundItem *_sndItemPlaying;       // 当前正在播放的sndItem
    SNSoundItem *_sndItemNextToPlay;    // 下一个要播放的sndItem
    NSString *_playCommentId;
}

@property (nonatomic, strong) SNSoundItem *sndItemPlaying;
@property (nonatomic, strong) SNSoundItem *sndItemNextToPlay;
@property (nonatomic, strong) NSString *playCommentId;

+ (SNSoundManager *)sharedInstance;

- (BOOL)playSound:(SNSoundItem *)sndItem;
- (void)pause;
- (BOOL)resume;
- (BOOL)pauseByUrl:(NSString *)url;
- (void)stopByUrl:(NSString *)url;
- (void)stopAmr;
- (void)stopAll;

- (void)notifySoundPlayFinished;

- (void)downloadSoundItem:(SNSoundItem *)sndItem;
- (BOOL)isSoundItemDownloading:(SNSoundItem *)sndItem;
- (void)cancelAllDownloads;

- (SNSoundStatusType)statusForSoundItem:(SNSoundItem *)sndItem;
- (void)setStatus:(SNSoundStatusType)status soundItem:(SNSoundItem *)sndItem;
- (void)clearAllStatus;

- (SNSoundStatusType)statusForSoundUrl:(NSString *)sndUrl;

+ (NSString *)soundFileDownloadPathWithURL:(NSString *)urlParam;

- (void)getCurrentTime:(CGFloat *)currTime duration:(CGFloat *)dur;

//Utility
+ (BOOL)isMicrophoneEnabled;

@end
