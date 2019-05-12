//
//  SNNewsSpeaker.m
//  sohunews
//
//  Created by weibin cheng on 14-6-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsSpeaker.h"
#import "SNListenNewsConst.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySetting.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

const NSInteger kMaxContentLength = 500;

@interface SNNewsSpeaker ()<IFlySpeechSynthesizerDelegate>
{
    NSInteger _subIndex;
    NSInteger _lastIndex;
    BOOL      _isCallStop;
    BOOL      _onCompleted;
}
@property(nonatomic, readwrite, assign)SNNewsSpeakerState state;
@property(nonatomic, readwrite, assign)NSInteger currentIndex;
@property(nonatomic, strong)SNListenNewsList*   newsList;
@property(nonatomic, strong)NSMutableArray* contentArray;
@property(nonatomic, strong)IFlySpeechSynthesizer* speechSynthesizer;
@property(nonatomic, strong)NSString* content;
@property(nonatomic, assign)BOOL isCallStop;
@end

@implementation SNNewsSpeaker
@synthesize state = _state;
@synthesize currentIndex = _currentIndex;
@synthesize newsList = _newsList;
@synthesize contentArray = _contentArray;
@synthesize speechSynthesizer = _speechSynthesizer;
@synthesize delegate = _delegate;

+ (SNNewsSpeaker*)shareSpeaker
{
    static SNNewsSpeaker* newsSpeaker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        newsSpeaker = [[SNNewsSpeaker alloc] init];
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",APPID_VALUE,TIMEOUT_VALUE];
        //所有服务启动前，需要确保执行createUtility
        [IFlySpeechUtility createUtility:initString];
    });
    return newsSpeaker;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _newsList = [[SNListenNewsList alloc] init];
        _newsList.delegate = self;
        
        [IFlySetting showLogcat:NO];//关闭灵犀SDK的日志输出
        
        //单例模式
        IFlySpeechSynthesizer* flySpeech = [IFlySpeechSynthesizer sharedInstance];
        flySpeech.delegate = self;
        
        //设置发音人
        [flySpeech setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
        self.speechSynthesizer = flySpeech;
        
        //手机锁屏时，显示语音控制面板，wangyy
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        _onCompleted = NO;
    }
    return self;
}

- (void)reset
{
    _currentIndex = 0;
    _subIndex = 0;
    self.content = nil;
    self.contentArray = nil;
}

- (void)startSpeaking:(NSArray*)newsList
{
    [self reset];
    [self.newsList startDownloadNewsList:newsList];
    self.state = SNNewsSpeakerStateWaiting;
}

- (void)playOrPause
{
    if(self.state == SNNewsSpeakerStateWorking)
    {
        [_speechSynthesizer pauseSpeaking];
    }
    else if(self.state == SNNewsSpeakerStatePaused)
    {
        [_speechSynthesizer resumeSpeaking];
    }
    else if(self.state == SNNewsSpeakerStateStopped)
    {
        [_speechSynthesizer startSpeaking:self.content];
    }
//    [self setPlayingInfoCenter];
}

- (void)pause {
    if (self.state == SNNewsSpeakerStateWorking) {
        [_speechSynthesizer pauseSpeaking];
    }
}

- (void)stop
{
    [self.newsList cancelAllDownloader];
    _lastIndex = _currentIndex;
    if(_speechSynthesizer.isSpeaking)
    {
        [_speechSynthesizer stopSpeaking];
        //self.isCallStop = YES;
    }
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self clearPlayingInfoCenter];
}

- (void)speakNext
{
    if(_currentIndex < self.newsList.count-1)
    {
        _lastIndex = _currentIndex;
        ++_currentIndex;
        if (_speechSynthesizer.isSpeaking)
        {
            [_speechSynthesizer stopSpeaking];
            //self.isCallStop = YES;
        }
        else
        {
            _currentIndex = [self.newsList startDownloadNewsWithIndex:_currentIndex];
            self.state = SNNewsSpeakerStateWaiting;
        }
    
        [self setPlayingInfoCenter];
    }
}

- (void)speakPrevious
{
    if(_currentIndex >= 0)
    {
        _lastIndex = _currentIndex;
        --_currentIndex;
        if (_speechSynthesizer.isSpeaking)
        {
            [_speechSynthesizer stopSpeaking];
            //self.isCallStop = YES;
        }
        else
        {
            [self.newsList startDownloadNewsWithIndex:_currentIndex];
            self.state = SNNewsSpeakerStateWaiting;
        }
        
        [self setPlayingInfoCenter];
    }
}

- (NSString*)currentNewsTitle
{
    SNListenNewsItem* item = [self.newsList itemByIndex:_currentIndex];
    return item.title;
}

- (void)speakContent:(NSString*)content
{
    //lijian 2017.06.05 此处导致某些语音停止后再不继续续播
    //if(_state != SNNewsSpeakerStateWaiting)
//        return;
    
    //NSLog(@"===============currentID=%d",_currentIndex);
    self.content = content;
    if(content.length > kMaxContentLength)
    {
        self.contentArray = [NSMutableArray arrayWithCapacity:5];
        NSString* string = content;
        while (string.length > kMaxContentLength) {
            NSString* subString = [string substringToIndex:kMaxContentLength-1];
            [self.contentArray addObject:subString];
            string = [string substringFromIndex:kMaxContentLength-1];
        }
        if(string.length > 0)
        {
            [self.contentArray addObject:string];
        }
        _subIndex = 0;
        [_speechSynthesizer startSpeaking:self.contentArray[_subIndex]];
    }
    else
    {
        _subIndex = 0;
        self.contentArray = nil;
        [_speechSynthesizer startSpeaking:content];
    }
    _onCompleted = NO;
    //注册romoteEvent，可后台控制音频播放
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self setPlayingInfoCenter];
}

- (void)continuePlayNext
{
    if(self.contentArray.count > 0)
    {
        if(_subIndex < self.contentArray.count-1)
        {
            ++_subIndex;
            [_speechSynthesizer startSpeaking:self.contentArray[_subIndex]];
            self.state = SNNewsSpeakerStateWaiting;
        }
        else
        {
            if(_currentIndex < [self.newsList count]-1)
            {
                _lastIndex = _currentIndex;
                ++_currentIndex;
                _currentIndex = [self.newsList startDownloadNewsWithIndex:_currentIndex];
                self.state = SNNewsSpeakerStateWaiting;
            }
            else
            {
                //已经是最后一条
                self.state = SNNewsSpeakerStateStopped;
                if(_delegate && [_delegate respondsToSelector:@selector(newsSpeakerDidFinished)])
                {
                    [_delegate newsSpeakerDidFinished];
                }
                else {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"语音新闻已播放完毕" toUrl:nil mode:SNCenterToastModeOnlyText];
                }
            }
        }
    }
    else
    {
        if(_currentIndex < [self.newsList count]-1)
        {
            _lastIndex = _currentIndex;
            ++_currentIndex;
            _currentIndex = [self.newsList startDownloadNewsWithIndex:_currentIndex];
            self.state = SNNewsSpeakerStateWaiting;
            
            [SNNotificationManager postNotificationName:kPalyNextNewsNotification object:nil userInfo:nil];
        }
        else
        {
            //已经是最后一条
            self.state = SNNewsSpeakerStateStopped;
            if(_delegate && [_delegate respondsToSelector:@selector(newsSpeakerDidFinished)])
            {
                [_delegate newsSpeakerDidFinished];
            }
            else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:@"语音新闻已播放完毕" toUrl:nil mode:SNCenterToastModeOnlyText];
                return;
            }
        }
        
        if ([SNUtility getApplicationDelegate].isWWANNetworkReachable) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"正在非wifi环境播放语音新闻" toUrl:nil mode:SNCenterToastModeWarning];
            
        }
    }

}
#pragma mark SNListenNewsListDelegate
- (void)downloadNewsDidFinished:(NSInteger)index withContent:(NSString*)content
{
    _currentIndex = index;
    if(index == _currentIndex)
    {
        //下载完成，开始播放
        if ([content trim].length > 0) {
            [self speakContent:content];
            [self setPlayingInfoCenter];
        } else {
//            [self.newsList startDownloadNewsWithIndex:_currentIndex++];
//            self.state = SNNewsSpeakerStateWaiting;
            [self speakNext];
        }
    }
    else if(index > _currentIndex)
    {
        //预加载完成，不影响当前播放
    }
}

#pragma mark IFlySpeechSynthesizerDelegate
- (void)onCompleted:(IFlySpeechError *)error
{
    NSString *errorDesc = error.errorDesc;
 
    if (nil != errorDesc || errorDesc.length > 0)
    {
        SNDebugLog(@"%s %@", __FUNCTION__, errorDesc);
    }
    _onCompleted = YES;
    
    //调用stop停止播放
    if(_isCallStop)
    {
        if(_lastIndex == _currentIndex)
        {
            self.state = SNNewsSpeakerStateStopped;
        }
        else
        {
            _currentIndex = [self.newsList startDownloadNewsWithIndex:_currentIndex];
            self.state = SNNewsSpeakerStateWaiting;
        }
        self.isCallStop = NO;
        return;
    }
    
    //正常播放完成,开始播放下一个
    if(_state == SNNewsSpeakerStateWorking && error.errorCode == 0)
    {
//        [self performSelectorOnMainThread:@selector(continuePlayNext) withObject:nil waitUntilDone:NO];
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self continuePlayNext];
        //});
    }
    //发生错误
    if(error.errorCode > 0)
    {
        self.state = SNNewsSpeakerStateStopped;
        if(_delegate && [_delegate respondsToSelector:@selector(newsSpeakerDidFailed:)])
            [_delegate newsSpeakerDidFailed:error];
    }
}

- (void)onSpeakBegin
{
    self.state = SNNewsSpeakerStateWorking;
}

- (void)onSpeakPaused
{
    self.state = SNNewsSpeakerStatePaused;
}

- (void)onSpeakResumed
{
    self.state = SNNewsSpeakerStateWorking;
}

- (void)setState:(SNNewsSpeakerState)state
{
    _state = state;
    if(state == SNNewsSpeakerStateWaiting)
    {
        SNListenNewsItem* item = [self.newsList itemByIndex:_currentIndex];
        BOOL first = _currentIndex == 0 ? YES : NO;
        BOOL end = _currentIndex == self.newsList.count-1 ? YES : NO;
        if(_delegate && [_delegate respondsToSelector:@selector(newsSpeakerContentDidChanged:isFirst:isEnd:)])
            [_delegate newsSpeakerContentDidChanged:item.title isFirst:first isEnd:end];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(newsSpeakerStateDidChanged)])
        [_delegate newsSpeakerStateDidChanged];
}

- (BOOL)isFirst
{
    return _currentIndex == 0 ? YES : NO;
}

- (BOOL)isEnd
{
    return _currentIndex == self.newsList.count-1 ? YES : NO;
}

- (BOOL)isIFlyOnCompleted{
    return _onCompleted;
}

- (void)setPlayingInfoCenter
{
    NSString *title = [[SNNewsSpeaker shareSpeaker] currentNewsTitle];
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"搜狐新闻", MPMediaItemPropertyTitle,
                             title, MPMediaItemPropertyArtist,
                             nil];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:infoDic];
}

- (void)clearPlayingInfoCenter
{
    NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"", MPMediaItemPropertyTitle,
                             @"", MPMediaItemPropertyArtist,
                             nil];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:infoDic];
}
@end
