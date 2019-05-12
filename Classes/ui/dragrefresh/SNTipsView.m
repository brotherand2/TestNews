//
//  SNTipsView.m
//  sohunews
//
//  Created by jojo on 13-8-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTipsView.h"

static NSString * const tipsPool[] = {
    @"登录后可以永久保留收藏记录啦",
    @"试试搜索您感兴趣的话题，会有惊喜哦",
    @"常去关注逛逛，每天都有新媒体上线",
    @"小伙伴们都在评论里畅所欲言，加入他们吧",
    @"微博、QQ等账号也可以登录",
    @"每天上午看神吐槽，欢乐不停",
    @"和神回复合影，没准明天您也上新闻",
    @"无数流行语诞生于狐友的评论，再不看就out啦",
    @"直播室里边看边聊，尽情感受第一现场",
    @"错过直播没关系，直播也有往期回顾",
    @"打着鸡血的小编，每天为您奉上精彩原创栏目",
    @"音频和视频新闻，让您身临其境感受小编的气息",
    @"关注精品综艺节目和美剧，第一时间收到更新提醒",
    @"媒体和频道都可以离线下载，随时随地无网也能看",
    @"关注微闻，了解生活百态",
    @"任何疑问和建议告诉小秘书，第一时间为您解答",
    @"精彩的文章和媒体，可以分享给QQ和微信好友啦",
    @"所有媒体都是免费关注的哦",
    @"我们会定期帮您清除缓存",
    @"媒体信息页可以打开推送，最新消息随时跟踪"
};

@interface SNTipsProvider : NSObject
+ (SNTipsProvider *)sharedInstance;
@end

@implementation SNTipsProvider

+ (SNTipsProvider *)sharedInstance {
    static SNTipsProvider *_sProvider = nil;
    @synchronized(self) {
        if (!_sProvider) {
            _sProvider = [[self alloc] init];
            srand48(time(NULL));
        }
    }
    return _sProvider;
}

- (NSString *)randATip {
    return tipsPool[rand() % (sizeof(tipsPool) / sizeof(tipsPool[0]))];
}

@end

@implementation SNTipsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.numberOfLines = 2;
        self.font = [UIFont systemFontOfSize:26 / 2];
        self.text = [self getATipString];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTips:) name:kTipsViewRefreshNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)updateTips:(id)sender {
    NSString *aTip = [self getATipString];
    if ([self.text isEqualToString:aTip]) {
        self.text = [self getATipString];
    } else {
        self.text = aTip;
    }
}

// Data sources
- (NSString *)getATipString {
    return [NSString stringWithFormat:@"小提示: %@", [[SNTipsProvider sharedInstance] randATip]];
}

@end
