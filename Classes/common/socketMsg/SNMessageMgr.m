//
//  SNMessageMgr.m
//  sohunews
//
//  Created by chenhong on 13-11-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMessageMgr.h"
#import "GCDAsyncSocket.h"
#import "SNURLJSONResponse.h"
#import "UIDevice-Hardware.h"
#import "SNNotifyService.h"
#import "SNDataInputStream.h"
#import "SNMessage.h"
#import "SNMessageMgrConsts.h"
#import "SNHostRequest.h"
#import "NSJSONSerialization+String.h"

// 消息处理相关业务
#import "SNBubbleBadgeService.h"
///////////////////////////////////////////////////////////////////////////////////////////////////

@interface SNMessageMgr()<GCDAsyncSocketDelegate>

@end

@implementation SNMessageMgr {
    // socket
    GCDAsyncSocket *_asyncSocket;
    
    // last http request duration(ms)
    int _lastExecuteTime;
    
    // heart beat timer
    NSTimer        *_checkTimer;

    // pull mode
    int _mode;
}

+ (SNMessageMgr *)sharedInstance {
    static SNMessageMgr *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SNMessageMgr alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                  delegateQueue:mainQueue];
    }
    return self;
}


- (BOOL)isConnected {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        return NO;
    }
    
    if ([_asyncSocket isConnected]) {
        return YES;
    }
    return NO;
}

- (void)connect {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        SNDebugLog(@"network is unavailable");
        return;
    }
    
    [self startTimerIfNeeded];
    
    if ([_asyncSocket isConnected]) {
        [self sendMsg:kPI tag:kPiTag];
        return;
    }
    
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    if (!cid.length) {
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestHostUrl];
    });
}

- (void)stop {
    [self stopTimer];
    [_asyncSocket disconnect];
}

- (void)stopTimer {
    [_checkTimer invalidate];
    _checkTimer = nil;
}

- (void)startTimerIfNeeded {
    if (_checkTimer && ![_checkTimer isValid]) {
         //(_checkTimer);
    }
    
    if (!_checkTimer) {
        _checkTimer = [NSTimer scheduledTimerWithTimeInterval:kCheckInterval
                                                        target:self
                                                      selector:@selector(sendHeartBeat)
                                                      userInfo:nil
                                                       repeats:YES];
    }

}

- (void)restart {
    [self stop];
    [self connect];
}

- (void)sendMsg:(NSString *)msg tag:(long)tag {
    if (msg.length == 0) {
        SNDebugLog(@"msg length == 0");
        return;
    }
    SNDebugLog(@"send msg: %@", msg);
    
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [_asyncSocket writeData:msgData withTimeout:-1 tag:tag];
}

- (void)sendHeartBeat {
    SNDebugLog(@"\r\n\r\nheart beat!");
    [self connect];
}

- (void)requestHostUrl {
    
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    if (!cid.length) return;
    
    __block SNStopWatch *watch = [[SNStopWatch watch] begin];
    
    [[[SNHostRequest alloc] initWithDictionary:@{@"ltime":[NSString stringWithFormat:@"%zd",_lastExecuteTime]}] send:^(SNBaseRequest *request, id rootData) {
       
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @try {
                [watch stop];
                _lastExecuteTime = (int)(watch.diff * 1000);
                if ([rootData isKindOfClass:[NSDictionary class]]) {
                    _mode = [rootData intValueForKey:@"m" defaultValue:0];
                    NSString *hostUrl = [rootData stringValueForKey:@"b" defaultValue:nil];
                    NSArray *array = [hostUrl componentsSeparatedByString:@":"];
                    if (array.count == 2) {
                        self.host = [array objectAtIndex:0];
                        self.port = (uint16_t)([[array objectAtIndex:1] intValue]);
                    }
                }
                return [self requestHostUrlFinished];
            } @catch (NSException *exception) {
                SNDebugLog(@"SNHostRequest exception reason--%@", exception.reason);
            } @finally {
                
            }
        });
    } failure:^(SNBaseRequest *request, NSError *error) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [watch stop];
            _lastExecuteTime = (int)(watch.diff * 1000);
            [self requestHostUrlFinished];
        });
    }];
}

- (void)requestHostUrlFinished {
    
    if (_mode > 0 && [self.host isKindOfClass:[NSString class]] && self.host.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            if (![_asyncSocket connectToHost:_host onPort:_port error:&error]) {
                SNDebugLog(@"Error connecting: %@", error);
            } else {
                SNDebugLog(@"Connecting...");
            }
        });
    }

}


#pragma mark Socket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	SNDebugLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [self sendMsg:kMagicV2 tag:kMagicV2Tag];
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    NSString *sub = [NSString stringWithFormat:kSUB, cid];
    [self sendMsg:sub tag:kSubTag];
    [self sendMsg:kPI tag:kPiTag];
    
    [_asyncSocket readDataToLength:4 withTimeout:-1 tag:kDataSizeTag];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    SNDebugLog(@"socket:%p socketDidSecure", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	SNDebugLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	SNDebugLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
    SNDataInputStream *ds = [SNDataInputStream dataInputStreamWithData:data];
    @try {
        if (tag == kDataSizeTag) {
            int size = [ds readInt32];
            
            // 防止读取数据异常
            if (size > kMaxMsgSize) {
                SNDebugLog(@"read length error! msg body too large (%d > %d)", size, kMaxMsgSize);
                [_asyncSocket disconnect];
                return;
            } else {
                SNDebugLog(@"sizeTag: %d", size);
            }

            [_asyncSocket readDataToLength:size withTimeout:-1 tag:kDataBodyTag];
        }
        else if (tag == kDataBodyTag) {
            int frameType = [ds readInt32];
            
            switch (frameType) {
                case FRAMETYPERESPONSE:
                {
                    // do nothing
                    SNDebugLog(@"FRAMETYPERESPONSE: %@", [ds readString]);
                }
                    break;
                    
                case FRAMETYPEMESSAGE:
                {
                    // 解析MSG
                    SNMessage *msg = [self decodeMessage:ds];
                    SNDebugLog(@"FRAMETYPEMESSAGE: %@", msg);
                    
                    if (msg.msgId) {
                        [SNNotifyService saveMaxMsgId:[msg.msgId intValue]];
                        [[NSUserDefaults standardUserDefaults] setObject:msg.msgId
                                                                  forKey:kMessageMgrLastMsgIdReceivedKey];
                    }

                    // 通知服务器已收到该消息
                    NSString *ok = [NSString stringWithFormat:kOK, msg.msgId];
                    [self sendMsg:ok tag:kMsgOKTag];
                    
                    // 本地处理消息
                    [self handleMessage:msg];
                }
                    break;
                    
                case FRAMETYPEERROR:
                    SNDebugLog(@"FRAMETYPEERROR: %@", [ds readString]);
                    break;
                    
                default:
                    break;
            }
            
            [_asyncSocket readDataToLength:4 withTimeout:-1 tag:kDataSizeTag];
        }
        else {
            SNDebugLog(@"unknown read tag %ld", tag);
            [_asyncSocket readDataToLength:4 withTimeout:-1 tag:kDataSizeTag];
        }
    }
    @catch (NSException *exception) {
        // 其他异常，测试socket的可用性，如果不可用，则断开
        SNDebugLog(@"socket:didReadData:withTag %ld exception:%@", tag, exception);
        [_asyncSocket disconnect];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	SNDebugLog(@"socket did disconnect:%p withError: %@", sock, err);
}

#pragma mark - msg

- (SNMessage *)decodeMessage:(SNDataInputStream *)ds {
    SNMessage *message = nil;
    @try {
        int64_t timestamp = [ds readLong64];
        [ds readShort16]; //short attempts
        int64_t msgId = [ds readLong64];
        msgId = CFSwapInt64(msgId); // msgId需要特殊处理一下，与其他的字节序不一致
        NSString *body = [ds readString];
        
        message = [[SNMessage alloc] initWithMsgId:[NSString stringWithFormat:@"%lld", msgId]
                                               body:body
                                          timestamp:[NSString stringWithFormat:@"%lld", timestamp]];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    
    return message;
}

- (BOOL)handleMessage:(SNMessage *)msg {
    if (!msg) {
        return YES;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithString:msg.body
                                                          options:NSJSONReadingMutableLeaves
                                                            error:NULL];
    if (dic == nil)
        return NO;
    
    BOOL ret = NO;
    
    NSString *type = [dic stringValueForKey:@"type" defaultValue:nil];
    if (type) {
        SNDebugLog(@"handleMessage: type = %@", type);
        if ([SNPreference sharedInstance].debugModeEnabled) {
            if ([SNPreference sharedInstance].touchDetectEnabled) {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:@"收到通知%@", type] toUrl:nil mode:SNCenterToastModeOnlyText];
            }
            
        }
        switch ([type intValue]) {
            // 气泡未读数变化
            case 26: {
                // 避免短时间内连续收到消息时多次请求接口
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestNewBadge) object:nil];
                [self performSelector:@selector(requestNewBadge) withObject:nil afterDelay:1];
                ret = YES;
                
            }
                break;
                
            // 自动加热播提示消息
            case 81: {
                [SNNotificationManager postNotificationName:kSNAddHotVideoNotification
                                                                    object:nil
                                                                  userInfo:dic];
                ret = YES;
            }
                break;
                
#if 0 // 服务端发邀请时走的是苹果apns，消息通知只发送气泡数变化(26)消息，不发邀请主持人(101) --- 20131213
            
            // 邀请主持人
            case 101: {
                [SNNotificationManager postNotificationName:kSNLiveInviteNotification
                                                                    object:nil
                                                                  userInfo:dic];
                ret = YES;
            }
                break;
#endif
            // 活动通知
            case 82: {
                [SNNotificationManager postNotificationName:kSNJoinActionNotification
                                                                    object:nil
                                                                  userInfo:dic];
                ret = YES;
            }
                break;
            // 未知
            default: {
                SNDebugLog(@"message not handled: %@", dic);
            }
                break;
        }
    }
    
    return ret;
}

- (void)requestNewBadge {
    SNDebugLog(@"requestNewBadge");
    [[SNBubbleBadgeService shareInstance] requestNewBadge];
}

@end
