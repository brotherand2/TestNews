//
//  Article.h
//  sohunews
//
//  Created by zhu kuanxi on 5/18/11.
//  strongright 2011 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNNewsVotesInfo;

//新闻文章实体类
@interface SNArticle : NSObject {

}

@property(nonatomic, strong)NSString *newsId;//新闻id
@property(nonatomic, strong)NSString *termId;//报纸id
@property(nonatomic, strong)NSString *channelId;//滚动频道id
@property(nonatomic, strong)NSString *title;//标题
@property(nonatomic, strong)NSString *from;//来源
@property(nonatomic, strong)NSString *originFrom;  //原始来源
@property(nonatomic, strong)NSString *newsMark;    //独家
@property(nonatomic, strong)NSString *originTitle; //原标题
@property(nonatomic, strong)NSString *time;//时间
@property(nonatomic, strong)NSString *updateTime;//更新时间
@property(nonatomic, strong)NSString *content;//正文
@property(nonatomic, strong)NSString *preId;//前一篇新闻id
@property(nonatomic, strong)NSString *nextId;//后一篇新闻id
@property(nonatomic, strong)NSString *nextNewsLink;
@property(nonatomic, strong)NSString *nextNewsLink2;
@property(nonatomic, strong)NSString *commentNum;//评论数
@property(nonatomic, strong)NSString *link;//链接
@property(nonatomic, strong)NSString *shareContent;//分享语
@property(nonatomic, strong)NSArray *newsImageItems;
@property(nonatomic, strong)NSArray *shareImages; //所含图片url数组
@property(nonatomic, strong)NSArray *thumbnailImages;//页面内部缩略图
@property(nonatomic, strong)NSMutableDictionary *titleForImageDic;
@property(nonatomic, strong)NSArray *videos;//直播视频
@property(nonatomic, strong)NSArray *audios;//音频
@property(nonatomic, strong)NSArray *adInfos;
@property(nonatomic, strong)SNNewsVotesInfo *votesInfo;//投票
@property(nonatomic, strong)NSString *voteXML;// 投票xml
@property(nonatomic, strong)NSString *subId;// 所属刊物
@property(nonatomic, assign)BOOL autoplayVideo;
@property(nonatomic, strong)NSString *comtStatus; //文章是否评论状态
@property(nonatomic, strong)NSString *comtHint;   //文章禁止评论提示
@property(nonatomic, assign)BOOL cmtRead;
@property(nonatomic, strong)NSString *comtRemarkTips; //写评论默认提示
@property(nonatomic, strong)NSString *logoUrl;//外网logo
@property(nonatomic, strong)NSString *linkUrl;
@property(nonatomic, strong)NSString *thirdPartUrl; //外网带量连接
@property(nonatomic, assign)BOOL favour;
@property(nonatomic, assign)NSInteger newsType;
@property(nonatomic, strong)NSString *h5link;
@property(nonatomic, assign)NSInteger openType;
@property(nonatomic, strong)NSString *favIcon;
@property(nonatomic, strong)NSString *mediaName;
@property(nonatomic, strong)NSString *mediaLink;
@property(nonatomic, strong)NSString *optimizeRead;
@property(nonatomic, strong)NSArray *tagChannelItems;         //频道推广位
@property(nonatomic, strong)NSArray *stockItems;             //相关股票

/*
 <operationInfo>
    <owers>[5782679059297210390]</owers>
    <operators>[5782679059297210390]</operators>
    <action>[1, 2, 3, 4]</action>
    <isPublished>1</isPublished>
    <editNewsLink>
        <![CDATA[
        http://mp.k.sohu.com/server/phone/openNews.go?newsId=11729192
        ]]>
    </editNewsLink>
 </operationInfo> 
 */
@property(nonatomic, strong)NSString *action;
@property(nonatomic, strong)NSString *isPublished;
@property(nonatomic, strong)NSString *editNewsLink;
@property(nonatomic, strong)NSString *operators;

@property(nonatomic, strong)NSArray *tvAdInfos;
@property(nonatomic, strong)NSArray *tvInfos;

//otherInfo: 请求url时附加参数串
+ (id)newsWithNewsId:(NSString *)nId termId:(NSString *)tId userData:(NSDictionary *)userData;
+ (id)newsWithNewsId:(NSString *)nId termId:(NSString *)tId userData:(NSDictionary *)userData onLineMode:(BOOL)bOnLineMode;
+ (id)newsWithNewsId:(NSString *)nId termId:(NSString *)tId userData:(NSDictionary *)userData onLineMode:(BOOL)bOnLineMode newsPaperPath:(NSString*)newsPaperPath;

//This methods added by handy for RollingNews download.
+ (id)newsForDownloadWithNewsId:(NSString *)nId channelId:(NSString *)cId paramsDic:(NSDictionary *)params;
+ (id)newsForDownloadWithNewsId:(NSString *)nId termId:(NSString *)tId paramsDic:(NSDictionary *)params;


/**
 *   正文页新闻缓存调用 2017.3.1
 */
+ (void)newsDownloadWithNewsId:(NSString *)nId channelId:(NSString *)cId paramsDic:(NSDictionary *)params;

/**
 *   profile页 openType == 1 时调起  2017.4.5
 */
+ (void)newsWithNewsId:(NSString *)nId
                termId:(NSString *)tId
              userData:(NSDictionary *)userData
              callBack:(void(^)(NSDictionary *acticleJson))callBack;

/*
 xmlData是类似下面格式的xml
 <root>
 <newsId>1</newsId>
 <type>新闻</type>
 <title>西安免费博物馆内设高票价馆</title>
 <time>2011-05-16 07:40</time>
 <from>西安晚报</from>
 <commentNum>18</commentNum>
 <digNum>68</digNum>
 <content>
 <p>昨日，本报报道半坡博物馆等涨价的稿件引发热议。</p>
 </content>
 <nextName>二手房价跌幅十年最低</nextName>
 <nextId>2</nextId>
 </root>
 
 */
- (id)initWithNewsId:(NSString *)nId termId:(NSString *)tId XMLData:(NSData *)xmlData openType:(NSInteger)openType;
- (id)initWithNewsId:(NSString *)nId termId:(NSString *)tId XMLData:(NSData *)xmlData openType:(NSInteger)openType onLineMode:(BOOL)bOnLineMode;

//otherInfo: 请求url时附加参数串
+ (id)newsWithNewsId:(NSString *)nId channelId:(NSString *)cId userData:(NSDictionary *)userData;
+ (id)newsWithNewsId:(NSString *)nId channelId:(NSString *)cId userData:(NSDictionary *)userData onLineMode:(BOOL)bOnLineMode;

- (id)initWithNewsId:(NSString *)nId channelId:(NSString *)cId XMLData:(NSData *)xmlData openType:(NSInteger)openType;
- (id)initWithNewsId:(NSString *)nId channelId:(NSString *)cId XMLData:(NSData *)xmlData openType:(NSInteger)openType onLineMode:(BOOL)bOnLineMode;

- (BOOL)isRollingNews;

//- (id)reloadWithData:(NSDictionary *)data;

- (BOOL)isCMSOperator;

- (void)updateArticleCmtRead;

- (void)updateArticleFavour;

+ (NSString *)newsContentForJsKitStorageWithNewsId:(NSString *)nId;

@end
