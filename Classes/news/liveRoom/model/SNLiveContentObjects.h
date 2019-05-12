//
//  SNLiveContentObjects.h
//  sohunews
//
//  Created by Chen Hong on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNAdvertiseObjects.h"

typedef enum {
    UNKNOWN_STATUS = 0,
    WAITING_STATUS = 1,
    LIVING_STATUS = 2,
    END_STATUS     = 3
    
}LIVE_STATUS_TYPE;

typedef enum {
    LiveMediaText  = 0,     // 非多媒体
    LiveMediaVideo = 1,     // 视频片段
    LiveMediaSound = 2,     // 音频直播
    LiveMediaVideoFlow = 3, // 视频直播
    LiveMediaGIF   = 4      // GIF

}LiveMediaType;

typedef enum {
    LiveInputDefault    = 0,
    LiveInputRec        = 1
}LiveInputMode;

typedef enum {
    kLiveTableTab = 0,
    kChatTableTab,
    kStatTableTab,
    kTableTabCount
}LiveTableEnum;

static const int kVideoDisplayModeShrink = 1;

/* 直播置顶信息 */
@interface SNLiveRoomTopObject : NSObject

@property(nonatomic, copy) NSString *top; // 置顶文字
@property(nonatomic, copy) NSString *topImage; // 置顶图片
@property(nonatomic, copy) NSString *topLink; // 置顶跳转链接

@end

/* 直播间角色 */
@interface SNLiveRoomRole : NSObject
@property(nonatomic, copy) NSString *rName;
@property(nonatomic, copy) NSString *nColor;
@property(nonatomic, copy) NSString *dColor;

- (id)initWithDict:(NSDictionary *)dict;

@end

/* 界面控制 */
//"compAudLen":120,主持人语音允许时长
//"inputShowType":0,默认( 文字输入)，1,显示语音输入界面,
@interface SNLiveRoomControlInfo : NSObject

@property(nonatomic,assign)int compAudLen;
@property(nonatomic,assign)int inputShowType;

- (id)initWithDict:(NSDictionary *)dict;

@end

@class SNLiveRoomMediaObject;

// 直播的比赛比分相关数据
@interface SNLiveContentMatchInfoObject : NSObject

@property(nonatomic, copy) NSString     *homeTeamTitle;            // 主队名称
@property(nonatomic, copy) NSString     *homeTeamScore;            // 主队得分
@property(nonatomic, copy) NSString     *homeTeamSupportNum;       // 主队支持数
@property(nonatomic, copy) NSString     *homeTeamIconURL;          // 主队图标URL
@property(nonatomic, copy) NSString     *homeTeamInfoURL;          // 主队信息URL

@property(nonatomic, copy) NSString     *visitingTeamTitle;        // 客队名称
@property(nonatomic, copy) NSString     *visitingTeamScore;        // 客队得分
@property(nonatomic, copy) NSString     *visitingTeamSupportNum;   // 客队支持数
@property(nonatomic, copy) NSString     *visitingTeamIconURL;      // 客队图标URL
@property(nonatomic, copy) NSString     *visitingTeamInfoURL;      // 客队信息URL

@property(nonatomic, copy) NSString     *onlineCount;              // 参与数
@property(nonatomic, copy) NSString     *liveStatus;               // 直播状态：1-预告 2-直播中 3-直播结束

@property(nonatomic, copy) NSString     *liveTime;                 // 比赛时间
@property(nonatomic, copy) NSString     *matchTitle;               // 特殊比赛title

@property(nonatomic, copy) NSString     *liveType;                 // 比赛类型，1-双方比赛 2-特殊赛事 
@property(nonatomic, copy) NSString     *liveStatistics;           // 比赛统计
@property(nonatomic, copy) NSString     *statisticsType;           // 是否支持技术统计 0不支持技术统计 1篮球

@property(nonatomic, copy) NSString     *interval;                  // 刷新时间间隔

@property(nonatomic, copy) NSString     *subServer;                 // 直播间内容推送的订阅服务器地址；

@property(nonatomic, strong) SNLiveRoomTopObject     *top;          // 置顶

@property(nonatomic, copy) NSString     *cursor;                    // 接口返回数据中最新项的index

@property(nonatomic, strong)SNLiveRoomMediaObject *mediaObj;        // 视频直播节点

//3.5
@property(nonatomic, copy) NSString     *shareContent;              // 分享语

//4.0
@property(nonatomic, assign) int        comtStatus;                //0：评论正常， 1：关闭评论，不能发如何评论,包括文字、图片、语音 , 2：禁止语音评论 , 3：禁止图片评论 ,4：禁止文件评论，即同时禁止图片语音评论
@property(nonatomic, copy) NSString     *comtHint;                  //给用户的提示，评论正常，没有此字段，比如：该直播禁止语音评论

//3.5.1
@property(nonatomic, assign) BOOL       needLogin;                  // 0-不需要登录就可以评论  1-需要登录才可以评论
@property(nonatomic, strong) NSMutableArray *allRoles;

//3.5.2
@property(nonatomic, copy) NSString     *ts;                        // 时间戳

//4.0
@property(nonatomic, strong) SNLiveRoomControlInfo *ctrlInfo;      // 界面控制

//4.3
@property(nonatomic, copy) NSString *catId;
@property(nonatomic, copy) NSString *subCatId;
@property(nonatomic, assign) BOOL isWorldCup;                       // 世界杯
@property(nonatomic, copy) NSString *statisticsUrl;                 // 数据统计地址

// v5.2.0
@property (nonatomic, copy) NSString *pubType;                      // 是否独家 0 1


- (void)updateByLiveGameItem:(LivingGameItem *)livingGameItem;

- (void)updateByLiveInfoDictonary:(NSDictionary *)info;

- (BOOL)isMediaLiveMode; //是否音视频直播

- (BOOL)isForbiddenAudio; //是否禁止语音评论

- (BOOL)isForbiddenPic; //是否禁止图片评论

- (BOOL)hasH5Statistics; //是否有H5的数据统计页面

@end

@interface SNLiveRoomAuthorInfo : NSObject

@property(nonatomic, copy) NSString    *authorimg;
@property(nonatomic, copy) NSString    *passport;
@property(nonatomic, copy) NSString    *spaceLink;
@property(nonatomic, copy) NSString    *pid;
@property(nonatomic, copy) NSString    *linkStyle;                  // [用户空间-0;本地-1] 
@property(nonatomic, assign) UInt8     gender;                      // 性别, 1男 2女
@property(nonatomic, assign) UInt8     role;                        // 用户角色, 1主持人、2嘉宾、3互动用户、4普通用户
@property(nonatomic, strong) NSArray   *signList;                   // 用户徽章

- (id)initWithDict:(NSDictionary *)dict;
- (BOOL)isLogin;

@end

@interface SNLiveRoomBaseObject : NSObject {
    SNLiveRoomAuthorInfo *_authorInfo;
}

@property(nonatomic,strong)SNLiveRoomAuthorInfo *authorInfo;

@end


// 回复对象
/*
 "replyComment":" {            [包含此字段代表此内容为直播员回复用户]
 "commentId": "13",
 "rid":"166539017",
 "author": "红色帆布鞋",
 "createTime": "1329879250963",
 "content": "评论内容" ,
 "mergeType"=2      //直播评论
 }" ,
 */
@interface SNLiveRoomReplyObject : SNLiveRoomBaseObject

@property(nonatomic,copy)NSString *commentId;
@property(nonatomic,copy)NSString *rid;
@property(nonatomic,copy)NSString *author;
@property(nonatomic,copy)NSString *createTime;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *mergeType;
@property(nonatomic,copy)NSString *imgUrl;
@property(nonatomic,assign)BOOL   showAllReplyContent;
@property(nonatomic,assign)CGFloat  contentH1;
@property(nonatomic,assign)CGFloat  contentH2;
@end

// 多媒体对象
/*
 "mediaInfo":{         [长视频][ 视频直播包含此节点]
 "mediaTitle":"aaa",
 "mediaImage":"http://aaa.com/a.jpg",
 "mediaUrl":"http://aaa.com/a.mp4",
 "mediaType":"1" [1--视频片段，2--音频，3--视频直播]
  "mDispMode":0 [视频显示大小:0-缺省放大,1-缩小]
 }
 */
@interface SNLiveRoomMediaObject : NSObject

@property(nonatomic,copy)NSString *mediaTitle;
@property(nonatomic,copy)NSString *mediaImage;
@property(nonatomic,copy)NSString *mediaUrl;
@property(nonatomic,copy)NSString *mediaSize;
@property(nonatomic,copy)NSString *mediaLength;
@property(nonatomic,assign)int mediaType;           // [0非多媒体直播，1--视频，2--音频 3--直播 4--GIF]
@property(nonatomic,assign)int displayMode;         // [视频显示大小:0-缺省放大,1-缩小]

//4.2 增加
@property(nonatomic,copy)NSString *site;            // [对应视频源站点的的ID（这个值是服务器这边的枚举定义)]

@property(nonatomic,copy)NSString *site2;           // [对应搜狐主站下的3个来源站的ID，是用来与播放器SDK交互的一个参数，
                                                    // 值有1：搜狐视频，2：播客，3：直播，这个参数用来告诉播放器SDK，
                                                    // vid是何种类型的视频的ID  （如果是非搜狐站点的视频，这个参数没用，给0即可）]
@property(nonatomic,copy)NSString *siteName;

@property(nonatomic,copy)NSString *siteId;          // [(eg: 74代表东方卫视）对应源站的视频的唯一ID]

@property(nonatomic,copy)NSString *playById;        // [是否按ID来播放视频， 1：是， 0：否 只对搜狐视频来源的通过id来播放，
                                                    // 如果有非搜狐站点的视频，不按vid或lid或tvId播放。）]

@property(nonatomic,copy)NSString *playAd;          // [是否开启广告播放， 1：是， 0：否]
@property(nonatomic,copy)NSString *adServer;


//5.5.1 增加
@property(nonatomic,copy)NSString *vid;             // 增加直播间的视频vid

- (void)updateWithDict:(NSDictionary *)dict;

@end


// 直播内容项
/*
 "action":
 "克里斯-波什进攻篮板",
 "actionTeam":
 "热火",
 "actionTime":
 1339732148710,
 "contentId":
 14837,
 "contentPic":
 "http://aaa.com/a.jpg",
 "hostScore":
 96,
 "isKeyEvent":
 0,
 "quarter":
 4,
 "videoInfo":
 {
 "videoDesc":
 "desc",
 "videoLength":
 "10s",
 "videoM3u8":
 "http://aaa.com/a.m3u8",
 "videoMp4":
 "http://aaa.com/a.mp4",
 "videoName":
 "aaa",
 "videoSize":
 "1000"
 },
 "vistorScore":
 100
 */

@class SNLiveCommentObject;

@interface SNLiveContentObject : SNLiveRoomBaseObject {
    NSString    *author;
    NSString    *action;
    NSString    *actionTeam;
    NSNumber    *actionTime;
    NSNumber    *contentId;
    NSString    *contentPic;
    NSString    *contentPicSmall;
    NSNumber    *hostScore;
    NSNumber    *visitorScore;
//    NSNumber    *isKeyEvent;
    NSNumber    *quarter;
    
    //v3.4新加
    NSString    *link;
    SNLiveCommentObject   *replyComment;
    SNLiveContentObject *replyContent;
    SNLiveRoomMediaObject *mediaInfo;
    BOOL        showAllContent; // 是否全部显示内容

    CGFloat     contentH1;      // action展开高度
    CGFloat     contentH2;      // action折叠高度
}

@property(nonatomic, copy) NSString    *author;
@property(nonatomic, copy) NSString    *action;
@property(nonatomic, copy) NSString    *actionTeam;
@property(nonatomic, strong) NSNumber    *actionTime;
@property(nonatomic, strong) NSNumber    *contentId;
@property(nonatomic, copy) NSString    *contentPic;
@property(nonatomic, copy) NSString    *contentPicSmall;
@property(nonatomic, strong) NSNumber    *hostScore;
@property(nonatomic, strong) NSNumber    *visitorScore;
//@property(nonatomic, retain) NSNumber    *isKeyEvent;
@property(nonatomic, strong) NSNumber    *quarter;
@property(nonatomic, assign) BOOL       showAllContent;
@property(nonatomic, assign) CGFloat    contentH1;
@property(nonatomic, assign) CGFloat    contentH2;

//v3.4
@property(nonatomic,copy)NSString *link;
@property(nonatomic,copy)NSString *contentPicLink;
@property(nonatomic,strong)SNLiveCommentObject *replyComment;
@property(nonatomic,strong)SNLiveRoomMediaObject *mediaInfo;
//v3.6
@property(nonatomic,strong)SNLiveContentObject *replyContent;

- (BOOL)hasSound;
- (BOOL)hasVideo;
- (BOOL)hasGIF;
- (BOOL)hasReply;
- (BOOL)hasReplyCont;

@end

/*
 {
    "commentId": "166539017",
    "autor": "红色帆布鞋",
    "createTime": "1329879250963",
    "content": "评论内容",
    "floors": []
}
 */
@interface SNLiveCommentObject : SNLiveRoomBaseObject {
    NSString    *commentId;
    NSString    *author;
    NSString    *createTime;
    NSString    *content;
    NSString    *imageUrl;
    NSString    *rid;
    NSString    *audUrl;
    NSString    *audLen;
    
    SNLiveCommentObject *replyComment;
    SNLiveContentObject *replyContent;
    BOOL        showAllReplyComment;
    CGFloat     contentH1;      // action展开高度
    CGFloat     contentH2;      // action折叠高度
}

@property(nonatomic, copy) NSString    *commentId;
@property(nonatomic, copy) NSString    *author;
@property(nonatomic, copy) NSString    *createTime;
@property(nonatomic, copy) NSString    *content;
@property(nonatomic, copy) NSString    *imageUrl;
@property(nonatomic, copy) NSString    *rid;
@property(nonatomic, copy) NSString    *audUrl;
@property(nonatomic, copy) NSString    *audLen;
@property(nonatomic, assign) BOOL      showAllComment;
@property(nonatomic, assign) CGFloat    contentH1;
@property(nonatomic, assign) CGFloat    contentH2;

//v3.4
@property(nonatomic,strong)SNLiveCommentObject *replyComment;
//v3.5
@property(nonatomic,strong)SNLiveContentObject *replyContent;

- (BOOL)hasReply;
- (BOOL)hasReplyCont;
- (BOOL)hasSound;
- (BOOL)isMyComment;

@end



//STADDisplayTrackType
@interface SNLiveRollAdContentObject : SNLiveContentObject

@property (nonatomic, strong) SNAdLiveInfo *adInfo;
@property (nonatomic, assign) NSUInteger step;
@property (nonatomic, assign) BOOL isPushAd;
@property (nonatomic, assign) long long searchContentID;

@end
