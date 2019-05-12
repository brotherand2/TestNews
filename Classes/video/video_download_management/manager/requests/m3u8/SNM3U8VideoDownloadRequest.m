//
//  SNM3U8VideoDownloadRequest.m
//  sohunews
//
//  Created by handy wang on 9/4/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNM3U8VideoDownloadRequest.h"
#import "SNM3U8SegmentInfo.h"
#import "SNVideoDownloadManager.h"
#import "SNM3U8Playlist.h"
#import "SNDBManager.h"
#import "SNM3U8File.h"

#define kEXTM3U                                                         (@"#EXTM3U")
#define kEXT_X_TARGETDURATION                                           (@"#EXT-X-TARGETDURATION")
#define kEXTINF                                                         (@"#EXTINF")
#define kEXT_X_ENDLIST                                                  (@"#EXT-X-ENDLIST")

#define kEXT_X_STREAM_INF                                               (@"#EXT-X-STREAM-INF")
#define kBANDWIDTH                                                      (@"BANDWIDTH")

#define kVID                                                            (@"KVID")

#define kMaxConcurrentDownloadSegmentCount                              (1)

@interface SNM3U8VideoDownloadRequest()
@property (nonatomic, strong)NSString                   *m3u8Content;
@property (nonatomic, strong)SNM3U8File                 *m3u8File;
@property (nonatomic, strong)NSMutableArray             *downloadingRequests;
@end

@implementation SNM3U8VideoDownloadRequest

- (id)initWithURL:(NSURL *)newURL {
    if (self = [super init]) {
        self.url = newURL;
        self.downloadingRequests = [NSMutableArray array];
    }
	return self;
}

- (void)setDelegate:(id)delegate {
}

- (void)setDownloadProgressDelegate:(id)downloadProgressDelegate {
}


#pragma mark - Public
- (void)startAsynchronous {
    SNVideoDataDownload *_model = [self.userInfo objectForKey:kDownloadingVideoItem];
    NSArray *_segments = [[SNDBManager currentDataBase] queryVideoSegmentsByVID:_model.vid];
    NSMutableArray *_unfinishedSegments = [NSMutableArray array];
    for (SNM3U8SegmentInfo *_segment in _segments) {
        if (_segment.state != SNVideoDownloadState_Successful) {
            _segment.state = SNVideoDownloadState_Waiting;
            [_unfinishedSegments addObject:_segment];
        }
    }
    
    //数据库中有segments的缓存
    if (_unfinishedSegments.count > 0) {
        self.m3u8Content = nil;
        self.m3u8File = [[SNM3U8File alloc] init];
        
        /**
         * segmentsActualCount是m3u8文件里真实的片断个数，它与playlist.segments.count是不一样的。
         * 因为当暂停或crash后再继续下载时，playlist.segments.count个数是会变的，也是就是playlist.segments.count <= segmentsActualCount
         */
        self.m3u8File.segmentsActualCount = _segments.count;
        
        self.m3u8File.vid = _model.vid;
        self.m3u8File.EXTM3U = kEXTM3U;
        self.m3u8File.EXT_X_ENDLIST = nil;
        self.m3u8File.EXT_X_TARGETDURATION = 123456;//这个值没有存库，所以随便给个大于0的值就行，以便能让后面的下载方法验证通过
        self.m3u8File.playlist.segments = _unfinishedSegments;
        self.m3u8File.nestM3u8BANDWIDTH = 0;
        self.m3u8File.nestM3U8URL = nil;
        
        [self downloadNextSegmentInThreadIfNeccessary];
    }
    //数据库中没segments的缓存
    else if (_model.state != SNVideoDownloadState_Successful && !!(self.url) && (self.url.absoluteString.length > 0)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *_error = nil;
            NSStringEncoding _encoding;
            
            self.m3u8Content = [NSString stringWithContentsOfURL:self.url usedEncoding:&_encoding error:&_error];
            if ([self parseM3U8Content:self.m3u8Content]) {
                [self downloadNextSegmentInThreadIfNeccessary];
            }
            else {
                [self callbackForFail];
            }
        });
    }
    else {
        [self callbackForFail];
    }
}

- (void)clearAllSegmentRequests {
    for (ASIHTTPRequest *_downloadingRequest in self.downloadingRequests) {
        SNM3U8SegmentInfo *_info = [_downloadingRequest.userInfo objectForKey:kSegmentInfo];
        _info.state = SNVideoDownloadState_Pause;
        [_downloadingRequest clearDelegatesAndCancel];
        _downloadingRequest.userInfo = nil;
    }
    [self.downloadingRequests removeAllObjects];
}

#pragma mark - Private
//Specification参考http://tools.ietf.org/html/draft-pantos-http-live-streaming-11#section-3.3.2
- (BOOL)parseM3U8Content:(NSString *)m3u8Content {
    SNDebugLog(@"Ready to parse m3u8 file content:\n%@", m3u8Content);
    
    //空文件
    if (m3u8Content.length <= 0) {
        SNDebugLog(@"===Invalid m3u8 content: Empty m3u8 file content.");
        return NO;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //文件第一行必须以#EXTM3U开头，以表示是M3U8文件，非则视为非法
    //////////////////////////////////////////////////////////////////////////////////////////////////
    NSArray *_m3u8ContentLines = nil;
    //各个系统下的制作的文本的换行符不一样，参考http://blog.csdn.net/tskyfree/article/details/8121951
    //Windows换行符
    if ([m3u8Content containsString:@"\r\n"]) {
        _m3u8ContentLines = [m3u8Content componentsSeparatedByString:@"\r\n"];
    }
    //Unix换行符
    else if ([m3u8Content containsString:@"\n"]) {
        _m3u8ContentLines = [m3u8Content componentsSeparatedByString:@"\n"];
    }
    //Mac OS换行符
    else if ([m3u8Content containsString:@"\r"]) {
        _m3u8ContentLines = [m3u8Content componentsSeparatedByString:@"\r"];
    }
    
    if (_m3u8ContentLines.count <= 0) {
        return NO;
    }
    NSString *_firstLine  = [[_m3u8ContentLines objectAtIndex:0] trim];
    if (![_firstLine isEqualToString:kEXTM3U]) {
        SNDebugLog(@"===Invalid m3u8 content: Didnt begin with #EXTM3U.");
        return NO;
    }
    
    SNVideoDataDownload *_model    = [self.userInfo objectForKey:kDownloadingVideoItem];
    self.m3u8File = [[SNM3U8File alloc] init];
    self.m3u8File.vid = _model.vid;
    self.m3u8File.EXTM3U = kEXTM3U;
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //文件最后一行必须以#EXT-X-ENDLIST结尾，以表示是点播类型的M3U8
    //////////////////////////////////////////////////////////////////////////////////////////////////
    /* 此条件暂不限制，以支持可以下载部分直播内容
    if (![m3u8Content endWith:kEXT_X_ENDLIST]) {
        SNDebugLog(@"===Invalid m3u8 content: Didnt begin with #EXT-X-ENDLIST.");
        return NO;
    }
    self.m3u8File.EXT_X_ENDLIST = kEXT_X_ENDLIST;
    */
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //解析文本内容
    //////////////////////////////////////////////////////////////////////////////////////////////////
    int _segmentInfoOrder = 0;
    NSString *_highesDefinitionM3U8URL = nil;
    int _hignesBandwidth = 0;
    for (int i = 0; i < _m3u8ContentLines.count; i++) {
        NSString *_m3u8ContentLine = [[_m3u8ContentLines objectAtIndex:i] trim];
        
        //#EXT-X-TARGETDURATION
        if ([_m3u8ContentLine startWith:kEXT_X_TARGETDURATION]) {
            self.m3u8File.EXT_X_TARGETDURATION = [[_m3u8ContentLine substringFromIndex:(kEXT_X_TARGETDURATION.length+1)] integerValue];
        }
        
        //#EXTINF
        if ([_m3u8ContentLine startWith:kEXTINF]) {
            //获取duration
            CGFloat _duration = [[_m3u8ContentLine substringWithRange:
                                  NSMakeRange(kEXTINF.length+1, _m3u8ContentLine.length-(kEXTINF.length+1)-1)] integerValue];
            //获取地址
            NSString *_segmentURL = nil;
            int _nextIndex = (i+1);
            if (_nextIndex < _m3u8ContentLines.count) {
                _segmentURL = [_m3u8ContentLines objectAtIndex:_nextIndex];
            }
            //组装segment对象
            if (_duration > 0 && _segmentURL.length > 0) {
                SNM3U8SegmentInfo *_segmentInfo = [[SNM3U8SegmentInfo alloc] init];
                _segmentInfo.vid            = self.m3u8File.vid;
                _segmentInfo.segmentOrder   = _segmentInfoOrder++;
                _segmentURL                 = [self mergeVideoURLFromSegmentURL:_segmentURL];
                _segmentInfo.urlString      = _segmentURL;
                _segmentInfo.duration       = _duration;
                _segmentInfo.downloadBytes  = 0;
                _segmentInfo.totalBytes     = 0;
                _segmentInfo.videoType      = kDownloadVideoType_M3U8;
                _segmentInfo.state          = SNVideoDownloadState_Waiting;
                [self.m3u8File.playlist.segments addObject:_segmentInfo];
                 //(_segmentInfo);
            }
            self.m3u8File.segmentsActualCount = self.m3u8File.playlist.segments.count;
        }
        
        //#EXT-X-STREAM-INF
        if ([_m3u8ContentLine startWith:kEXT_X_STREAM_INF]) {//含有内嵌m3u8文件地址
            //获取带宽值
            int _tmpBandwidthValue = 0;
            NSArray *_keyValuePairs = [_m3u8ContentLine componentsSeparatedByString:@","];
            for (NSString *_keyValuePair in _keyValuePairs) {
                if ([[_keyValuePair uppercaseString] startWith:kBANDWIDTH]) {
                    NSArray *_values = [_keyValuePair componentsSeparatedByString:@"="];
                    if (_values.count == 2) {
                        NSString *_bandwidthString = [_values objectAtIndex:1];
                        if (_bandwidthString.length > 0) {
                            _tmpBandwidthValue = [_bandwidthString intValue];
                        }
                    }
                }
            }
            //获取内嵌m3u8文件地址
            int _nextIndex = (i+1);
            if (_nextIndex < _m3u8ContentLines.count) {
                NSString *_tmpNestM3U8URL = [_m3u8ContentLines objectAtIndex:_nextIndex];
                if (_tmpNestM3U8URL.length > 0  && _tmpBandwidthValue > _hignesBandwidth &&  _tmpBandwidthValue > 0) {
                    _highesDefinitionM3U8URL = _tmpNestM3U8URL;
                    _hignesBandwidth = _tmpBandwidthValue;
                }
            }
        }
    }
    self.m3u8File.nestM3u8BANDWIDTH = _hignesBandwidth;
    self.m3u8File.nestM3U8URL       = _highesDefinitionM3U8URL;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //根据文本内容进行相关判断
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //获取到最清晰的内嵌M3U8文件URL地址
    if (self.m3u8File.nestM3U8URL.length > 0 && self.m3u8File.nestM3u8BANDWIDTH > 0) {
        self.url = [NSURL URLWithString:_highesDefinitionM3U8URL];
        NSError *_error = nil;
        NSStringEncoding _encoding;
        self.m3u8Content = [NSString stringWithContentsOfURL:self.url usedEncoding:&_encoding error:&_error];
        return [self parseM3U8Content:self.m3u8Content];
    }
    
    //解析完的文件信息中没有EXT-X-TARGETDURATION，则视为非法文件
    if (self.m3u8File.EXT_X_TARGETDURATION <=0) {
        return NO;
    }
    
    //是否作为一个普通M3U8文件进行了解析
    if (self.m3u8File.vid.length > 0 && self.m3u8File.playlist.segments.count > 0) {
        return [[SNDBManager currentDataBase] saveVideoSegments:self.m3u8File.playlist.segments];
    }
    else {
        return NO;
    }
}

- (NSString *)mergeVideoURLFromSegmentURL:(NSString *)segmentURL {
    NSString *_videoURL = [self.url.absoluteString trim];
    SNDebugLog(@"Ready to merge videoURL:%@ with segmentURL:%@", _videoURL, segmentURL);
    if (_videoURL.length <= 0 || segmentURL.length <= 0) {
        return nil;
    }
    
    if ([SNAPI isWebURL:segmentURL]) {
        return segmentURL;
    }
    
    NSRange _lastSlashRange     = [_videoURL rangeOfString:@"/" options:NSBackwardsSearch|NSCaseInsensitiveSearch];
    NSRange _doubleSlashRange  = [_videoURL rangeOfString:@"//" options:NSBackwardsSearch|NSCaseInsensitiveSearch];
    if (_doubleSlashRange.location == NSNotFound ||
        _lastSlashRange.location == NSNotFound ||
        _lastSlashRange.location == _doubleSlashRange.location+1) {//最后一根斜线是http://中的最后一根斜线，说明videoURL非法
        return nil;
    }
    
    _videoURL = [_videoURL substringToIndex:(_lastSlashRange.location+1)];
    SNDebugLog(@"Truncated videoURL:%@", _videoURL);
    
    //---单独把schema取出来是为防止后续stringByAppendingPathComponent时，会把://合并为:/
    NSURL *_tmpURL = [NSURL URLWithString:_videoURL];
    NSString *_schema = _tmpURL.scheme;
    if (_schema.length <= 0) {
        return nil;
    }
    _schema = [NSString stringWithFormat:@"%@://", _schema];
    if (_schema.length <= 0) {
        return nil;
    }
    //---
    
    _videoURL = [_videoURL substringFromIndex:_schema.length];
    
    //无子目录
    if (![self containInnerSlash:segmentURL]) {
        segmentURL = [_videoURL stringByAppendingPathComponent:segmentURL];
    }
    //有子目录
    else {
        NSString *_firstDirName = nil;
        if ([segmentURL startWith:@"/"]) {
            NSRange _firstInnerSlashRange = [segmentURL rangeOfString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(1, (segmentURL.length-1))];
            if (_firstInnerSlashRange.location != NSNotFound) {
                _firstDirName = [segmentURL substringWithRange:NSMakeRange(1, _firstInnerSlashRange.location)];
            }
        }
        else {
            NSRange _firstInnerSlashRange = [segmentURL rangeOfString:@"/" options:NSCaseInsensitiveSearch];
            if (_firstInnerSlashRange.location != NSNotFound) {
                _firstDirName = [segmentURL substringToIndex:_firstInnerSlashRange.location];
            }
        }
        if (_firstDirName.length <= 0) {
            return nil;
        }
        
        //子目录与videoURL中的目录不重叠
        if (![_videoURL containsString:_firstDirName]) {
            segmentURL = [_videoURL stringByAppendingPathComponent:segmentURL];
        }
        //子目录与videoURL中的目录有重叠
        else {
            NSRange _tmpRange = [_videoURL rangeOfString:_firstDirName options:NSBackwardsSearch];
            _videoURL = [_videoURL substringToIndex:_tmpRange.location];
            if (_videoURL.length <= 0) {
                return nil;
            }
            segmentURL = [_videoURL stringByAppendingPathComponent:segmentURL];
        }
    }
    return [_schema stringByAppendingString:segmentURL];
}

- (BOOL)containInnerSlash:(NSString *)path {
    if (path.length <= 0) {
        return NO;
    }
    NSRange _innerSlashRange = [path rangeOfString:@"/" options:NSBackwardsSearch|NSCaseInsensitiveSearch];
    return (_innerSlashRange.location != NSNotFound && _innerSlashRange.location != 0);
}

- (void)downloadNextSegmentInThreadIfNeccessary {
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self downloadNextSegmentInThreadIfNeccessary];
        });
        return;
    }
    
    if (self.m3u8File.vid.length > 0 && self.m3u8File.EXT_X_TARGETDURATION > 0 && self.m3u8File.playlist.segments.count > 0) {
        
        BOOL _appened = NO;
        while (self.downloadingRequests.count < kMaxConcurrentDownloadSegmentCount && [self waitingSegments].count > 0) {
            SNM3U8SegmentInfo *_segment = [[self waitingSegments] objectAtIndex:0];
            SNVideoDownloadRequest *_segmentRequest    = [SNVideoDownloadRequest requestWithURL:[NSURL URLWithString:_segment.urlString]];
            _segmentRequest.delegate                   = self;
            _segmentRequest.downloadProgressDelegate   = self;
            
            NSMutableDictionary *_segmentUserInfo = [NSMutableDictionary dictionary];
            [_segmentUserInfo setObject:self.m3u8File.vid forKey:kVID];
            [_segmentUserInfo setObject:_segment forKey:kSegmentInfo];
            _segmentRequest.userInfo = _segmentUserInfo;
            
            NSString *_tmpName = [NSString stringWithFormat:@"%@_%ld", self.m3u8File.vid, (long)_segment.segmentOrder];
            _segmentRequest.temporaryFileDownloadPath = [[SNVideoDownloadConfig m3u8VideoTmpDir] stringByAppendingPathComponent:_tmpName];
            
            NSString *_destName = [NSString stringWithFormat:@"%ld", (long)_segment.segmentOrder];
            _segmentRequest.downloadDestinationPath = [[SNVideoDownloadConfig m3u8VideoDir:self.m3u8File.vid] stringByAppendingPathComponent:_destName];
            
            if (!!_segmentRequest) {
                SNDebugLog(@"Ready to start request %@ to download segment %@_%d from :%@", _segmentRequest, self.m3u8File.vid, _segment.segmentOrder, _segmentRequest.url.absoluteString);
                [self.downloadingRequests addObject:_segmentRequest];
                
                _appened = YES;
                _segment.state = SNVideoDownloadState_Downloading;
                NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
                [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
                [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
                
                [_segmentRequest startAsynchronous];
            }
        }
        if (!_appened) {
            SNDebugLog(@"===INFO: A news segment is waiting to download, because only support %d items concurrent download.", kMaxConcurrentDownloadSegmentCount);
        }

        if ([self waitingSegments].count <= 0) {
            if (self.downloadingRequests.count > 0) {
                SNDebugLog(@"===INFO: No waiting items, however, there is %d downloading items.", self.downloadingRequests.count);
            }
            else {
                [self finishedToDownloadAllSegmentsIfNeeded];
            }
        }
    }
    else {
        SNDebugLog(@"===ERROR: @@@@There is no playlist in m3u8 file content.");
        [self callbackForFail];
    }
}

- (NSArray *)waitingSegments {
    NSMutableArray *_array = [NSMutableArray array];
    for (SNM3U8SegmentInfo *segment in self.m3u8File.playlist.segments) {
        if (segment.state == SNVideoDownloadState_Waiting) {
            [_array addObject:segment];
        }
    }
    return _array;
}

#pragma mark - ASIHTPRequestDelegate
- (void)requestStarted:(ASIHTTPRequest *)iRequest {
    //更新视频model的状态为SNVideoDownloadState_Downloading并保存到数据库
    SNVideoDataDownload *_videoModel    = [self.userInfo objectForKey:kDownloadingVideoItem];
    _videoModel.state = SNVideoDownloadState_Downloading;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *__data = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_videoModel.state] forKey:@"state"];
        [[SNDBManager currentDataBase] updateADownloadedVideo:__data byVid:_videoModel.vid];
    });
}

- (void)request:(ASIHTTPRequest *)iRequest didReceiveResponseHeaders:(NSDictionary *)iResponseHeaders {
    int __responseStatusCode = [iRequest responseStatusCode];
    /**
     * 判断是否200、301、302、303
     * 因为：
     * ASIHTTPRequest will automatically redirect to a new URL when it encounters one of the following HTTP status codes, assuming a Location header was sent:
     * 301 Moved Permanently
     * 302 Found
     * 303 See Other
     */
    
    if(!(__responseStatusCode >= HttpSucceededResponseStatusCode && __responseStatusCode <= 299) &&
       __responseStatusCode != 301 &&
       __responseStatusCode != 302 &&
       __responseStatusCode != 303){
        [self requestFailed:iRequest];
    }
    else {
        [[SNVideoDownloadManager sharedInstance] diskSpaceNotEnoughAndPauseAllIfNeededWithResponseHeaders:iResponseHeaders];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)iRequest {
    NSString *_vid = [iRequest.userInfo objectForKey:kVID];
    SNM3U8SegmentInfo *_segment = [iRequest.userInfo objectForKey:kSegmentInfo];
    _segment.state = SNVideoDownloadState_Successful;

    NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
    [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
    [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_vid andSegmentOrder:_segment.segmentOrder];
    SNDebugLog(@"//////Succeeded to download segment %@_%d from %@", _vid, _segment.segmentOrder, iRequest.url.absoluteString);
    
    iRequest.delegate = nil;
    iRequest.downloadProgressDelegate = nil;
    iRequest.userInfo = nil;
    [self.downloadingRequests removeObject:iRequest];
    
    [self downloadNextSegmentInThreadIfNeccessary];
}

- (void)requestFailed:(ASIHTTPRequest *)iRequest {
    for (ASIHTTPRequest *_downloadingRequest in self.downloadingRequests) {
        SNM3U8SegmentInfo *_segment = [_downloadingRequest.userInfo objectForKey:kSegmentInfo];
        _segment.state = SNVideoDownloadState_Failed;
        [_downloadingRequest clearDelegatesAndCancel];
        _downloadingRequest.userInfo = nil;
    }
    [self.downloadingRequests removeAllObjects];
    
    [self callbackForFail];
}

#pragma mark - ASIProgressDelegate
//有多大的数据需要下载
- (void)request:(ASIHTTPRequest *)iRequest incrementDownloadSizeBy:(long long)newLength {
	[self request:iRequest didReceiveBytes:0];
}

//下载中每次接收到数据长度
- (void)request:(ASIHTTPRequest *)iRequest didReceiveBytes:(long long)newLength {
    NSString *_vid                  = [iRequest.userInfo objectForKey:kVID];
    SNM3U8SegmentInfo *_segment     = [iRequest.userInfo objectForKey:kSegmentInfo];
    
    if ([iRequest totalBytesRead] == 0) {
    }
    else if ([iRequest contentLength]+[iRequest partialDownloadSize] > 0) {
        CGFloat _totalBytes         = ([iRequest contentLength]+[iRequest partialDownloadSize])*1.0;
        CGFloat _downloadedBytes    = ([iRequest totalBytesRead]+[iRequest partialDownloadSize])*1.0;

        _segment.state = SNVideoDownloadState_Downloading;
        _segment.totalBytes = _totalBytes;
        _segment.downloadBytes = _downloadedBytes;
        NSMutableDictionary *_valuePair = [NSMutableDictionary dictionary];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.state] forKey:@"state"];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.downloadBytes] forKey:@"downloadBytes"];
        [_valuePair setObject:[NSNumber numberWithInt:_segment.totalBytes] forKey:@"totalBytes"];
        [[SNDBManager currentDataBase] updateVideoSegment:_valuePair byVid:_segment.vid andSegmentOrder:_segment.segmentOrder];
        
        NSMutableDictionary *_progressData = [NSMutableDictionary dictionary];
        [_progressData setObject:kDownloadVideoType_M3U8 forKey:kDownloadingVideoType];
        [_progressData setObject:_vid forKey:kDownloadingM3U8VID];
        //这里只能用segmentsActualCount，不然当暂停后再继续下载时在cell里计算出来的进度会偏大，因为暂停后再继续下载时self.m3u8File.playlist.segments.count会变小
        [_progressData setObject:[NSNumber numberWithInteger:self.m3u8File.segmentsActualCount] forKey:kSegmentsCount];
        [_progressData setObject:[NSNumber numberWithInteger:_segment.segmentOrder] forKey:kSegmentOrder];
        [_progressData setObject:[NSNumber numberWithFloat:_totalBytes] forKey:kVideoTatalBytes];
        [_progressData setObject:[NSNumber numberWithFloat:_downloadedBytes] forKey:kVideoDownloadedBytes];
        
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SNNotificationManager postNotificationName:kVideoDownloadingProgressNotification object:_progressData];
            });
        } else {
            [SNNotificationManager postNotificationName:kVideoDownloadingProgressNotification object:_progressData];
        }
    }
}

#pragma mark - ========================================================================
- (void)finishedToDownloadAllSegmentsIfNeeded {
    //---是否有一个下载失败，如果有则视为下载失败
    BOOL _existedOneFail = NO;
    for (SNM3U8SegmentInfo *_info in self.m3u8File.playlist.segments) {
        if (_info.state == SNVideoDownloadState_Failed) {
            _existedOneFail = YES;
            break;
        }
    }
    if (_existedOneFail) {
        [self callbackForFail];
        return;
    }
    //-------------------------------
    
    //Compose new m3u8 file
    if(self.m3u8File.playlist != nil) {
        NSString *_m3u8FileName = [NSString stringWithFormat:@"%@.m3u8", self.m3u8File.vid];
        NSString *_m3u8Path = [[SNVideoDownloadConfig m3u8VideoDir:self.m3u8File.vid] stringByAppendingPathComponent:_m3u8FileName];
        SNDebugLog(@"===Ready to create m3u8 file in path {%@}", _m3u8Path);
        
        //创建文件头部
        NSString *head = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-TARGETDURATION:%ld\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n",
                          (long)self.m3u8File.EXT_X_TARGETDURATION];
        
        //下载m3u8的根目录为本地web服务器的根目录
        NSString *segmentPrefix = [NSString stringWithFormat:@"https://127.0.0.1:12345/%@/", self.m3u8File.vid];
        
        //填充片段数据
        NSArray *_allSegmentsInM3U8File = [[SNDBManager currentDataBase] queryVideoSegmentsByVID:self.m3u8File.vid];
        for(int i = 0; i < _allSegmentsInM3U8File.count; i++){
            NSString *segmentFilename   = [NSString stringWithFormat:@"%d",i];
            SNM3U8SegmentInfo *segInfo  = [_allSegmentsInM3U8File objectAtIndex:i];
            NSString        *duration   = [NSString stringWithFormat:@"#EXTINF:%ld,\n", (long)segInfo.duration];
            NSString        *segmentURL = [segmentPrefix stringByAppendingString:segmentFilename];
            head                        = [NSString stringWithFormat:@"%@%@%@\n",head, duration, segmentURL];
        }
        
        //创建尾部
        NSString *end           = @"#EXT-X-ENDLIST";
        head                    = [head stringByAppendingString:end];
        NSMutableData *writer   = [[NSMutableData alloc] init];
        [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
        
        BOOL bSucc = [writer writeToFile:_m3u8Path atomically:YES];
         //(writer);
        if(bSucc) {
            SNDebugLog(@"Succeed to create m3u8file: _m3u8Path:%@, content:%@", _m3u8Path, head);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *_localM3U8URL = [segmentPrefix stringByAppendingPathComponent:_m3u8FileName];
                NSDictionary *_data = [NSDictionary dictionaryWithObject:_localM3U8URL forKey:@"localM3U8URL"];
                [[SNDBManager currentDataBase] updateADownloadedVideo:_data byVid:self.m3u8File.vid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self callbackForSuccess];
                });
            });
        }
        else {
            SNDebugLog(@"Failed to create m3u8file.");
            [self callbackForFail];
        }
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)callbackForSuccess {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callbackForSuccess];
        });
        return;
    }
    if ([_callback respondsToSelector:@selector(requestFinished:)]) {
        [self.userInfo setValue:kM3U8_Download_Result_Success forKey:kM3U8_Download_Result];
        [_callback requestFinished:self];
    }
}

- (void)callbackForFail {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callbackForFail];
        });
        return;
    }
    
    NSArray *_excludingStates = [NSArray arrayWithObject:[NSNumber numberWithInt:SNVideoDownloadState_Successful]];
    [[SNDBManager currentDataBase] updateAllSegmentsState:SNVideoDownloadState_Failed byVid:self.m3u8File.vid excludingStates:_excludingStates];
    
    if ([_callback respondsToSelector:@selector(requestFailed:)]) {
        [self.userInfo setValue:kM3U8_Download_Result_Fail forKey:kM3U8_Download_Result];
        [_callback requestFailed:self];
    }
}

@end
