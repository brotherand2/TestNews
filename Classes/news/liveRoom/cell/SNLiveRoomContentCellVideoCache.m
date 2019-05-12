//
//  SNLiveRoomContentCellVideoCache.m
//  sohunews
//
//  Created by handy wang on 7/11/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNLiveRoomContentCellVideoCache.h"

@interface SNLiveRoomContentCellVideoCache() {
    NSString *_playingVideoKey;
}
@end

@implementation SNLiveRoomContentCellVideoCache

+ (SNLiveRoomContentCellVideoCache *)sharedInstance {
    static SNLiveRoomContentCellVideoCache *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNLiveRoomContentCellVideoCache alloc] init];
    });
    return _sharedInstance;
}

- (NSString *)playingVideoKey {
    return _playingVideoKey;
}

- (void)setPlayingVideoKey:(NSString *)key {
     //(_playingVideoKey);
    _playingVideoKey = key;
}

#pragma mark -

- (NSString *)createPlayingVideoKey:(SNLiveRoomBaseObject *)obj {
    NSString *_key = nil;
    if ([obj isKindOfClass:[SNLiveContentObject class]]) {
        SNLiveContentObject *_data = (SNLiveContentObject *)(obj);
        _key = [NSString stringWithFormat:kSNLiveRoomCellPlayingVideoKeyPattern,
                _data.contentId, _data.mediaInfo.mediaUrl];
    } else if ([obj isKindOfClass:[SNLiveCommentObject class]]) {
        SNLiveCommentObject *_data = (SNLiveCommentObject *)(obj);
        if (_data.hasReplyCont) {
            _key = [NSString stringWithFormat:kSNLiveRoomCellPlayingVideoKeyPattern,
                    _data.commentId, _data.replyContent.mediaInfo.mediaUrl];
        }
    }
    return _key;
}

@end
