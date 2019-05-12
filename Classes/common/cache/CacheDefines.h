/*
 *  CacheDefines.h
 *  CacheMgr
 *
 *  Created by 李 雪 on 11-6-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

//select * from sqlite_master where type="table";

#define DB_FILE_NAME				@"SohuNews.sqlite"
#define DB_FILE_NAME_FOR_BACKUP     @"SohuNews_backup.sqlite"
#define NEWSARTICLE_DEFAULTIMAGE	@"default.png"

#define CACHE_EXPIRATIONAGE			3
//缓存大小的最大限制 30M
#define CACHE_MAXSIZE				(30 * 1024 * 1024)
//最低给系统留20％空间
#define CACHE_MINFREESPACE			0.2
//当需要清理缓存时，需要保持剩余空间的弹性，防止清理功能被频繁调用
#define CACHE_CLEARRATE             1.2

#define CACHE_DIRECTORY				@"Cache/"
#define CACHE_NEWSPAPER_DIRECTORY	@"Newspaper"
#define NEWSSHAREIMAGE_TYPE         @"share"

#define NEWSPAPER_PATH_FLAG			@"/mpaper/"

#define	UPDATE_SETSTATEMNT			@"setStatement"
#define	UPDATE_SETARGUMENTS			@"valueArguments"

//tbSubscribe
/*
 CREATE TABLE tbSubscribe (ID INTEGER PRIMARY KEY,pubTypeName TEXT,subId TEXT,subType TEXT,pubId TEXT,pubName TEXT,pubIcon TEXT,pubType TEXT,pubPush TEXT,termId TEXT,lastTermLink TEXT,orderIndex INTEGER,iconPath TEXT,status TEXT,noReadCount TEXT,noReadTermIds TEXT,defaultSub TEXT);
 */
#define	TB_SUBSCRIBE				@"tbSubscribe"

//字段
#define	TB_SUBSCRIBE_ID				@"ID"
#define	TB_SUBSCRIBE_PUBTYPENAME	@"pubTypeName"
#define	TB_SUBSCRIBE_SUBID			@"subId"
#define TB_SUBSCRIBE_SUBTYPE		@"subType"
#define	TB_SUBSCRIBE_PUBID			@"pubId"                    
#define TB_SUBSCRIBE_PUBNAME		@"pubName"
#define TB_SUBSCRIBE_PUBICON		@"pubIcon"
#define	TB_SUBSCRIBE_PUBTYPE		@"pubType"
#define	TB_SUBSCRIBE_PUBPUSH		@"pubPush"
#define	TB_SUBSCRIBE_TERMID			@"termId"
#define TB_SUBSCRIBE_LASTTERMLINK	@"lastTermLink"
#define TB_SUBSCRIBE_ORDERINDEX		@"orderIndex"
#define TB_SUBSCRIBE_ICONPATH		@"iconPath"
#define TB_SUBSCRIBE_STATUS			@"status"
#define TB_SUBSCRIBE_NOREADCOUNT	@"noReadCount"
#define TB_SUBSCRIBE_NOREADTERMIDS	@"noReadTermIds"
#define TB_SUBSCRIBE_DEFAULTSUB 	@"defaultSub"
#define TB_SUBSCRIBE_DOWNLOADED     @"downloaded"
//tbSubscribeHomeImage
/*
 CREATE TABLE tbSubscribeHomeImage (ID INTEGER PRIMARY KEY,subId TEXT,pubId TEXT,termId TEXT,src TEXT,link TEXT,date TEXT,termName TEXT,pubName TEXT,termType TEXT,title TEXT,path TEXT,noReadCount TEXT,noReadTermIds TEXT,orderIndex TEXT);
 */
#define	TB_SUBHOMEIMAGE				@"tbSubscribeHomeImage"
//字段
#define	TB_SUBHOMEIMAGE_ID			@"ID"
#define	TB_SUBHOMEIMAGE_SUBID		@"subId"
#define TB_SUBHOMEIMAGE_PUBID		@"pubId"
#define TB_SUBHOMEIMAGE_TERMID		@"termId"
#define TB_SUBHOMEIMAGE_SRC			@"src"
#define TB_SUBHOMEIMAGE_LINK		@"link"
#define TB_SUBHOMEIMAGE_DATE		@"date"
#define TB_SUBHOMEIMAGE_TERMNAME	@"termName"
#define TB_SUBHOMEIMAGE_PUBNAME		@"pubName"
#define TB_SUBHOMEIMAGE_TERMTYPE	@"termType"
#define TB_SUBHOMEIMAGE_TITLE		@"title"
#define TB_SUBHOMEIMAGE_PATH		@"path"
#define TB_SUBHOMEIMAGE_NOREADCOUNT	@"noReadCount"
#define TB_SUBHOMEIMAGE_NOREADTERMIDS	@"noReadTermIds"
#define TB_SUBHOMEIMAGE_ORDERINDEX		@"orderIndex"

//tbAllSubscribe
/*
 CREATE TABLE tbAllSubscribe (ID INTEGER PRIMARY KEY,pubTypeName TEXT,subId TEXT,subType TEXT,pubId TEXT,pubType TEXT,pubSubscribe TEXT,pubInfo TEXT,pubName TEXT,pubIcon TEXT,lastTermLink TEXT,iconPath TEXT,defaultPush TEXT,defaultSub TEXT);
 */
#define	TB_ALLSUBSCRIBE				@"tbAllSubscribe"
//字段
#define TB_ALLSUBSCRIBE_ID				@"ID"
#define TB_ALLSUBSCRIBE_PUBTYPENAME		@"pubTypeName"
#define TB_ALLSUBSCRIBE_SUBID			@"subId"
#define TB_ALLSUBSCRIBE_SUBTYPE			@"subType"
#define TB_ALLSUBSCRIBE_PUBID			@"pubId"
#define TB_ALLSUBSCRIBE_PUBTYPE			@"pubType"
#define TB_ALLSUBSCRIBE_PUBSUBSCRIBE	@"pubSubscribe"
#define TB_ALLSUBSCRIBE_PUBINFO			@"pubInfo"
#define TB_ALLSUBSCRIBE_PUBNAME			@"pubName"
#define TB_ALLSUBSCRIBE_PUBICON			@"pubIcon"
#define TB_ALLSUBSCRIBE_LASTTERMLINK	@"lastTermLink"
#define TB_ALLSUBSCRIBE_ICONPATH		@"iconPath"
#define TB_ALLSUBSCRIBE_DFTPUSH			@"defaultPush"
#define TB_ALLSUBSCRIBE_DFTSUB			@"defaultSub"

//tbNewspaper
/*
	CREATE TABLE tbNewspaper (ID INTEGER PRIMARY KEY,subId TEXT,pubId TEXT,termId TEXT,termName TEXT,termTitle TEXT,termLink TEXT,termZip TEXT,termTime TEXT,newspaperPath TEXT,readFlag TEXT,downloadFlag TEXT);
*/
#define TB_NEWSPAPER				@"tbNewspaper"
//字段
#define TB_NEWSPAPER_ID				@"ID"
#define TB_NEWSPAPER_SUBID			@"subId"
#define TB_NEWSPAPER_PUBID			@"pubId"
#define TB_NEWSPAPER_TERMID			@"termId"
#define TB_NEWSPAPER_TERMNAME		@"termName"
#define TB_NEWSPAPER_TERMTITLE		@"termTitle"
#define TB_NEWSPAPER_TERMLINK		@"termLink"
#define TB_NEWSPAPER_TERMZIP		@"termZip"
#define TB_NEWSPAPER_TERMTIME		@"termTime"
#define TB_NEWSPAPER_NEWSPAPERPATH	@"newspaperPath"
#define TB_NEWSPAPER_READFLAG		@"readFlag"
#define TB_NEWSPAPER_DOWNLOADFLAG	@"downloadFlag"
#define TB_NEWSPAPER_DOWNLOADTIME	@"downloadTime"
#define TB_NEWSPAPER_NORMALLOGO     @"normalLogo"
#define TB_NEWSPAPER_NIGHTLOGO      @"nightLogo"
#define TB_NEWSPAPER_PUBLISHTIME    @"publishTime"
//tbNewsChannel 
/*
	CREATE TABLE tbNewsChannel (ID INTEGER PRIMARY KEY,name TEXT,channelId TEXT);
 */
#define TB_NEWSCHANNEL				@"tbNewsChannel"
//字段
#define TB_NEWSCHANNEL_ID			@"ID"
#define TB_NEWSCHANNEL_CHANNELNAME	@"name"
#define TB_NEWSCHANNEL_CHANNELID	@"channelID"
#define TB_NEWSCHANNEL_CHANNELICON  @"channelIcon"
#define TB_NEWSCHANNEL_CHANNELTYPE  @"channelType"
#define TB_NEWSCHANNEL_IS_SUBED     @"isChannelSubed"
#define TB_NEWSCHANNEL_CHANNELPOSITION @"channelPosition"
#define TB_NEWSCHANNEL_CHANNELTOP @"channelTop"
#define TB_NEWSCHANNEL_CHANNELTOPTIME @"channelTopTime"
#define TB_NEWSCHANNEL_CHANNEL_LAST_MODIFY @"lastModify"
#define TB_NEWSCHANNEL_CHANNEL_ISSELECTED    @"isSelected"
#define TB_NEWSCHANNEL_CHANNEL_CURRPOSITION  @"currPosition"
#define TB_NEWSCHANNEL_CHANNEL_LOCALTYPE    @"localType"
#define TB_NEWSCHANNEL_CHANNEL_ISRECOM       @"isRecom"
#define TB_NEWSCHANNEL_CHANNEL_TIPS          @"tips"
#define TB_NEWSCHANNEL_CHANNEL_TIPSINTERVAL  @"tipsInterval"
#define TB_NEWSCHANNEL_CHANNEL_LINK         @"link"
#define TB_NEWSCHANNEL_CHANNEL_GBCODE       @"gbcode"
#define TB_NEWSCHANNEL_CHANNEL_SERVERVERSION    @"serverVersion"
#define TB_NEWSCHANNEL_CHANNEL_CATEGORY_NAME    @"channelCategoryName"
#define TB_NEWSCHANNEL_CHANNEL_CATEGORY_ID    @"channelCategoryID"
#define TB_NEWSCHANNEL_CHANNEL_ICON_FLAG    @"channelIconFlag"
#define TB_NEWSCHANNEL_CHANNEL_SHOWTYPE    @"channelShowType"
#define TB_NEWSCHANNEL_CHANNEL_ISMIXSTREAM    @"isMixStream"

// tbWeiboHotChannel
#define TB_WEIBOHOTCHANNEL                  @"tbWeiboHotChannel"
// 字段
#define TB_WEIBOHOTCHANNEL_ID               @"ID"
#define TB_WEIBOHOTCHANNEL_CHANNELNAME      @"name"
#define TB_WEIBOHOTCHANNEL_CHANNELID        @"channelID"
#define TB_WEIBOHOTCHANNEL_CHANNELICON      @"channelIcon"
#define TB_WEIBOHOTCHANNEL_CHANNELTYPE      @"channelType"
#define TB_WEIBOHOTCHANNEL_IS_SUBED         @"isChannelSubed"
#define TB_WEIBOHOTCHANNEL_CHANNELPOSITION  @"channelPosition"
#define TB_WEIBOHOTCHANNEL_CHANNELTOP       @"channelTop"
#define TB_WEIBOHOTCHANNEL_CHANNELTOPTIME   @"channelTopTime"


//tbNewsArticle
/*
	CREATE TABLE tbNewsArticle (ID INTEGER PRIMARY KEY,subId TEXT,pubId TEXT,termId TEXT,newsId TEXT,type TEXT,title TEXT,time TEXT,source TEXT,commentNum TEXT,digNum TEXT,content  TEXT,link TEXT,readFlag TEXT,nextName TEXT,nextId TEXT,preName TEXT,preId TEXT,shareContent TEXT);
 */
#define TB_NEWSARTICLE				@"tbNewsArticle"
//字段
#define TB_NEWSARTICLE_ID			@"ID"
#define TB_NEWSARTICLE_SUBID		@"subId"
#define TB_NEWSARTICLE_CHANNELID    @"channelId"
#define TB_NEWSARTICLE_PUBID		@"pubId"
#define	TB_NEWSARTICLE_TERMID		@"termId"
#define TB_NEWSARTICLE_NEWSID		@"newsId"
#define TB_NEWSARTICLE_TYPE			@"type"
#define TB_NEWSARTICLE_TITLE		@"title"
#define TB_NEWSARTICLE_NEWSMARK     @"newsMark"
#define TB_NEWSARTICLE_ORIGINFROM   @"originFrom"
#define TB_NEWSARTICLE_ORIGINTITLE  @"originTitle"
#define TB_NEWSARTICLE_TIME			@"time"
#define TB_NEWSARTICLE_UPDATETIME   @"updateTime"
#define TB_NEWSARTICLE_FROM			@"source"
#define TB_NEWSARTICLE_COMMENTNUM	@"commentNum"
#define TB_NEWSARTICLE_DIGNUM		@"digNum"
#define TB_NEWSARTICLE_CONTENT		@"content"
#define TB_NEWSARTICLE_LINK			@"link"
#define TB_NEWSARTICLE_READFLAG		@"readFlag"
#define TB_NEWSARTICLE_NEXTNAME		@"nextName"
#define TB_NEWSARTICLE_NEXTID		@"nextId"
#define TB_NEWSARTICLE_NEXTNEWSLINK @"nextNewsLink"
#define TB_NEWSARTICLE_NEXTNEWSLINK2 @"nextNewsLink2"
#define TB_NEWSARTICLE_PRENAME		@"preName"
#define TB_NEWSARTICLE_PREID		@"preId"
#define TB_NEWSARTICLE_SHARECONTENT	@"shareContent"
#define TB_NEWSARTICLE_SUBID        @"subId"
#define TB_NEWSARTICLE_ACTION       @"action"
#define TB_NEWSARTICLE_OPERATORS    @"operators"
#define TB_NEWSARTICLE_IS_PUBLISH   @"isPublished"
#define TB_NEWSARTICLE_EDIT_LINK    @"editNewsLink"
#define TB_NEWSARTICLE_CMTSTATUS    @"cmtStatus"
#define TB_NEWSARTICLE_CMTHINT      @"cmtHint"
#define TB_NEWSARTICLE_CMTREAD      @"cmtRead"
#define TB_NEWSARTICLE_LOGOURL      @"logoUrl"
#define TB_NEWSARTICLE_LINKURL      @"linkUrl"
#define TB_NEWSARTICLE_FAVOUR       @"favour"
#define TB_NEWSARTICLE_NEWSTYPE     @"newsType"
#define TB_NEWSARTICLE_H5LINK       @"h5link"
#define TB_NEWSARTICLE_OPENTYPE     @"openType"
#define TB_NEWSARTICLE_FAVICON      @"favIcon"
#define TB_NEWSARTICLE_MEDIANAME    @"mediaName"
#define TB_NEWSARTICLE_MEDIALINK    @"mediaLink"
#define TB_NEWSARTICLE_OPTIMIZEREAD @"optimizeRead"
#define TB_NEWSARTICLE_TAGCHANNELS  @"tagChannelsStr"
#define TB_NEWSARTICLE_STOCKS       @"stocksStr"

//tbNewsImage
/*
  CREATE TABLE tbNewsImage (ID INTEGER PRIMARY KEY,termId TEXT,newsId TEXT,imageId TEXT,type TEXT,time TEXT,link TEXT,url TEXT,path TEXT);
 */
#define TB_NEWSIMAGE				@"tbNewsImage"
//字段
#define TB_NEWSIMAGE_ID				@"ID"
#define TB_NEWSIMAGE_TERMID			@"termId"
#define TB_NEWSIMAGE_NEWSID			@"newsId"
#define TB_NEWSIMAGE_IMAGEID		@"imageId"
#define TB_NEWSIMAGE_TYPE			@"type"
#define TB_NEWSIMAGE_TIME			@"time"
#define TB_NEWSIMAGE_LINK			@"link"
#define TB_NEWSIMAGE_URL			@"url"
#define TB_NEWSIMAGE_PATH			@"path"
#define TB_NEWSIMAGE_TITLE			@"title"
#define TB_NEWSIMAGE_WIDTH          @"width"
#define TB_NEWSIMAGE_HEIGHT         @"height"

//tbGallery
/*
  CREATE TABLE tbGallery (ID INTEGER PRIMARY KEY,termId TEXT,newsId TEXT,title TEXT,time TEXT,type TEXT,commentNum TEXT,digNum TEXT,shareContent TEXT,nextId TEXT,nextName TEXT,preId TEXT,preName TEXT,source TEXT);
 */
#define TB_GALLERY					@"tbGallery"
//字段
#define	TB_GALLERY_ID				@"ID"
#define	TB_GALLERY_TERMID			@"termId"
#define	TB_GALLERY_NEWSID			@"newsId"
#define	TB_GALLERY_TITLE			@"title"
#define TB_GALLERY_NEWSMARK         @"newsMark"
#define TB_GALLERY_ORIGINFROM       @"originFrom"
#define	TB_GALLERY_TIME				@"time"
#define	TB_GALLERY_UPDATETIME       @"updateTime"
#define	TB_GALLERY_TYPE				@"type"
#define	TB_GALLERY_COMMENTNUM		@"commentNum"
#define	TB_GALLERY_DIGNUM			@"digNum"
#define TB_GALLERY_SHARECONTENT		@"shareContent"
//add 20111221
#define TB_GALLERY_NEXTID           @"nextId"
#define TB_GALLERY_NEXTNEWSLINK     @"nextNewsLink"
#define TB_GALLERY_NEXTNEWSLINK2    @"nextNewsLink2"
#define TB_GALLERY_NEXTNAME         @"nextName"
#define TB_GALLERY_PREID            @"preId"
#define TB_GALLERY_PRENAME          @"preName"
#define TB_GALLERY_FROM             @"source"

#define TB_GALLERY_ISLIKE           @"isLike"
#define TB_GALLERY_LIKECOUNT        @"likeCount"
#define TB_GALLERY_SUBID            @"subId"
//20131118
#define TB_GALLERY_CMTHINT          @"cmtHint"
#define TB_GALLERY_CMTSTATUS        @"cmtStatus"
#define TB_GALLERY_CMTREAD          @"cmtRead"

#define TB_GALLERY_H5LINK           @"h5link"
#define TB_GALLERY_FAVICON          @"faveIcon"
#define TB_GALLERY_MEDIANAME        @"mediaName"
#define TB_GALLERY_MEDIALINK        @"mediaLink"


//tbPhoto
/*
 CREATE TABLE tbPhoto (ID INTEGER PRIMARY KEY,termId TEXT,newsId TEXT,abstract TEXT,ptitle TEXT,shareLink TEXT,url TEXT,path TEXT,time TEXT);
 */
#define TB_PHOTO					@"tbPhoto"
//字段
#define TB_PHOTO_ID					@"ID"
#define TB_PHOTO_TERMID				@"termId"
#define TB_PHOTO_NEWSID				@"newsId"
#define TB_PHOTO_ABSTRACT			@"abstract"
#define TB_PHOTO_PTITLE				@"ptitle"
#define TB_PHOTO_SHARELINK			@"shareLink"
#define TB_PHOTO_URL				@"url"
#define TB_PHOTO_PATH				@"path"
#define TB_PHOTO_TIME				@"time"

//tbRecommendGallery add 20111221
/*
 CREATE TABLE tbRecommendGallery (ID INTEGER PRIMARY KEY,rTermId TEXT,rNewsId TEXT,termId TEXT,newsId TEXT,title TEXT,time TEXT,type TEXT,iconUrl TEXT,iconPath TEXT);
 */
//
#define TB_RECOMMENDGALLERY             @"tbRecommendGallery"
//字段
#define TB_RECOMMENDGALLERY_ID           @"ID"
#define TB_RECOMMENDGALLERY_RTERMID      @"rTermId"
#define TB_RECOMMENDGALLERY_RNEWSID      @"rNewsId"
#define TB_RECOMMENDGALLERY_TERMID       @"termId"
#define TB_RECOMMENDGALLERY_NEWSID       @"newsId"
#define TB_RECOMMENDGALLERY_TITLE        @"title"
#define TB_RECOMMENDGALLERY_TIME         @"time"
#define TB_RECOMMENDGALLERY_TYPE         @"type"
#define TB_RECOMMENDGALLERY_ICONURL      @"iconUrl"
#define TB_RECOMMENDGALLERY_ICONPATH     @"iconPath"


//tbRollingNewsList
/*
 CREATE TABLE tbRollingNewsList (ID INTEGER PRIMARY KEY,channelId TEXT,pubId TEXT,pubName TEXT,newsId TEXT,type TEXT,title TEXT,description TEXT,time TEXT,commentNum TEXT,digNum TEXT,listPic TEXT,link TEXT, readFlag TEXT,downloadFlag TEXT);
 */

#define TB_ROLLINGNEWSLIST					@"tbRollingNewsList"
//字段
#define TB_ROLLINGNEWSLIST_ID				@"ID"
#define TB_ROLLINGNEWSLIST_CHANNELID		@"channelId"
#define TB_ROLLINGNEWSLIST_SUBID            @"subId"
#define TB_ROLLINGNEWSLIST_PUBID			@"pubId"
#define TB_ROLLINGNEWSLIST_PUBNAME			@"pubName"
#define TB_ROLLINGNEWSLIST_NEWSID			@"newsId"
#define TB_ROLLINGNEWSLIST_TYPE				@"type"
#define TB_ROLLINGNEWSLIST_TITLE			@"title"
#define TB_ROLLINGNEWSLIST_DESCRIPTION		@"description"
#define TB_ROLLINGNEWSLIST_TIME				@"time"
#define TB_ROLLINGNEWSLIST_COMMENTNUM		@"commentNum"
#define TB_ROLLINGNEWSLIST_DIGNUM			@"digNum"
#define TB_ROLLINGNEWSLIST_LISTPIC			@"listPic"
#define TB_ROLLINGNEWSLIST_LINK				@"link"
#define TB_ROLLINGNEWSLIST_READFLAG			@"readFlag"
#define TB_ROLLINGNEWSLIST_DOWNLOADFLAG		@"downloadFlag"
#define TB_ROLLINGNEWSLIST_FORM             @"form"
#define TB_ROLLINGNEWSLIST_LISTPICSNUMBER   @"listPicsNumber"
#define TB_ROLLINGNEWSLIST_TIMELINEINDEX    @"timelineIndex"
#define TB_ROLLINGNEWSLIST_HASVIDEO         @"hasVideo"
#define TB_ROLLINGNEWSLIST_HASAUDIO         @"hasAudio"
#define TB_ROLLINGNEWSLIST_HASVOTE          @"hasVote"
#define TB_ROLLINGNEWSLIST_UPDATETIME       @"updateTime"
#define TB_ROLLINGNEWSLIST_EXPIRED          @"expired"

#define TB_ROLLINGNEWSLIST_ICONTYPEDAY      @"icontypeday"
#define TB_ROLLINGNEWSLIST_ICONTYPENIGHT    @"icontypenight"
#define TB_ROLLINGNEWSLIST_RECOMICONDAY     @"recomiconday"
#define TB_ROLLINGNEWSLIST_RECOMICONNIGHT   @"recomiconnight"

#define TB_ROLLINGNEWSLIST_MEDIA            @"media"

#define TB_ROLLINGNEWSLIST_ISWEATHER        @"isWeather"
#define TB_ROLLINGNEWSLIST_CITY             @"city"
#define TB_ROLLINGNEWSLIST_TEMPHIGH         @"tempHigh"
#define TB_ROLLINGNEWSLIST_TEMPLOW          @"tempLow"
#define TB_ROLLINGNEWSLIST_WEATHER          @"weather"
#define TB_ROLLINGNEWSLIST_WEAK             @"weak"
#define TB_ROLLINGNEWSLIST_LIVETEMPERTURE   @"liveTemperature"
#define TB_ROLLINGNEWSLIST_PM25             @"pm25"
#define TB_ROLLINGNEWSLIST_QUALITY          @"quality"
#define TB_ROLLINGNEWSLIST_WEATHERIOC       @"weatherIoc"
#define TB_ROLLINGNEWSLIST_ISRECOM          @"isRecom"
#define TB_ROLLINGNEWSLIST_RECOMTYPE        @"recomType"
#define TB_ROLLINGNEWSLIST_LIVESTATUS       @"liveStatus"
#define TB_ROLLINGNEWSLIST_LOCAL            @"local"
#define TB_ROLLINGNEWSLIST_WIND             @"wind"
#define TB_ROLLINGNEWSLIST_GBCODE           @"gbcode"
#define TB_ROLLINGNEWSLIST_THIRDPARTURL     @"thirdPartUrl"
#define TB_ROLLINGNEWSLIST_DATE             @"date"
#define TB_ROLLINGNEWSLIST_LOCALIOC         @"localIoc"
#define TB_ROLLINGNEWSLIST_TEMPLATEID       @"templateId"
#define TB_ROLLINGNEWSLIST_TEMPLATETYPE     @"templateType"
#define TB_ROLLINGNEWSLIST_DATASTRING       @"dataString"
#define TB_ROLLINGNEWSLIST_PLAYTIME         @"playTime"
#define TB_ROLLINGNEWSLIST_LIVETYPE         @"liveType"
#define TB_ROLLINGNEWSLIST_ISFLASH          @"isFlash"
#define TB_ROLLINGNEWSLIST_TOKEN            @"token"
#define TB_ROLLINGNEWSLIST_POSITION         @"position"
#define TB_ROLLINGNEWSLIST_STATSTYPE        @"statsType"
#define TB_ROLLINGNEWSLIST_ADTYPE           @"adType"
#define TB_ROLLINGNEWSLIST_ADABPOSITION     @"adAbPosition"
#define TB_ROLLINGNEWSLIST_ADPOSITION       @"adPosition"
#define TB_ROLLINGNEWSLIST_ADREFRESHCOUNT   @"refreshCount"
#define TB_ROLLINGNEWSLIST_ADLOADMORECOUNT  @"loadMoreCount"
#define TB_ROLLINGNEWSLIST_ADSCOP           @"scope"
#define TB_ROLLINGNEWSLIST_ADAPPCHANNEL     @"appChannel"
#define TB_ROLLINGNEWSLIST_ADNEWSCHANNEL    @"newsChannel"
#define TB_ROLLINGNEWSLIST_MOREPAGENUM      @"morePageNum"
#define TB_ROLLINGNEWSLIST_HASSPONSORSHIPS  @"isHasSponsorships"
#define TB_ROLLINGNEWSLIST_ICONTEXT         @"iconText"
#define TB_ROLLINGNEWSLIST_NEWSTYPETEXT     @"newsTypeText"
#define TB_ROLLINGNEWSLIST_SPONSORSHIPS     @"sponsorships"
#define TB_ROLLINGNEWSLIST_CURSOR           @"cursor"
#define TB_ROLLINGNEWSLIST_ADREPORTSTATE    @"adReportState"

#define TB_ROLLINGNEWSLIST_TOPNEWS          @"topNews"
#define TB_ROLLINGNEWSLIST_LATEST           @"isLatest"

#define TB_ROLLINGNEWSLIST_RECOMREASONS    @"recomReasons"
#define TB_ROLLINGNEWSLIST_RECOMTIME       @"recomTime"

#define TB_ROLLINGNEWSLIST_BLUETITLE       @"blueTitle"

//红包字段
#define TB_ROLLINGNEWSLIST_REDPACKETTITLE       @"redPacketTitle"
#define TB_ROLLINGNEWSLIST_REDPACKETBGPIC       @"redPacketBgPic"
#define TB_ROLLINGNEWSLIST_REDPACKETSPONSORICON @"redPacketSponsorIcon"
#define TB_ROLLINGNEWSLIST_REDPACKETBID        @"redPacketID"

//add by cui
#define TB_ROLLINGNEWSLIST_TVPLAYNUM        @"tvPlayNum"
#define TB_ROLLINGNEWSLIST_TVPLAYTIME        @"tvPlayTime"
#define TB_ROLLINGNEWSLIST_VID       @"vid"
#define TB_ROLLINGNEWSLIST_TVURL       @"tvUrl"
#define TB_ROLLINGNEWSLIST_SOURCENAME @"sourceName"
#define TB_ROLLINGNEWSLIST_SITE         @"SITE"

//推荐流上报参数
#define TB_ROLLINGNEWSLIST_RECOMINFO       @"recomInfo"
#define TB_ROLLINGNEWSLIST_TRAINCARDID      @"trainCardId"

//adType,adAbPosition,adPosition,refreshCount,loadMoreCount,scope,appChannel,newsChannel
//tbNewsComment
/*
 CREATE TABLE tbNewsComment (ID INTEGER PRIMARY KEY,newsId TEXT,commentId TEXT,type TEXT,ctime TEXT,author TEXT,content TEXT);
*/
#define	TB_NEWSCOMMENT					@"tbNewsComment"
//字段
#define TB_NEWSCOMMENT_ID				@"ID"
#define TB_NEWSCOMMENT_NEWSID			@"newsId"
#define TB_NEWSCOMMENT_CID				@"commentId"
#define TB_NEWSCOMMENT_TYPE				@"type"
#define	TB_NEWSCOMMENT_CTIME			@"ctime"
#define TB_NEWSCOMMENT_AUTHOR			@"author"
#define TB_NEWSCOMMENT_CONTENT			@"content"
#define TB_NEWSCOMMENT_DIGNUM           @"digNum"
#define TB_NEWSCOMMENT_HADDING          @"hadDing"
#define TB_NEWSCOMMENT_IMAGEPATH        @"imagePath"
#define TB_NEWSCOMMENT_AUTHORIMAGE      @"authorImage"
#define TB_NEWSCOMMENT_AUDIOPATH        @"audioPath"
#define TB_NEWSCOMMENT_AUDIODUR         @"audioDuration"
#define TB_NEWSCOMMENT_USER_CID         @"userComtId"

//tbGroupPhoto
/*
 CREATE TABLE tbGroupPhoto (
 ID integer  PRIMARY KEY DEFAULT NULL,
 newsId TEXT,
 title TEXT,
 time TEXT,
 commentNum TEXT  DEFAULT NULL,
 favoriteNum TEXT DEFAULT NULL,
 imageNum TEXT DEFAULT NULL,
 type TEXT,
 typeId TEXT);
 */
#define	TB_GROUPPHOTO				@"tbGroupPhoto"

//字段
#define	TB_GROUPPHOTO_ID                @"ID"
#define	TB_GROUPPHOTO_NEWSID            @"newsId"
#define	TB_GROUPPHOTO_TITLE             @"title"
#define TB_GROUPPHOTO_TIME              @"time"
#define	TB_GROUPPHOTO_COMMENTNUM        @"commentNum"                    
#define TB_GROUPPHOTO_FAVORITENUM       @"favoriteNum"
#define TB_GROUPPHOTO_IMAGENUM          @"imageNum"
#define	TB_GROUPPHOTO_TYPE              @"type"
#define TB_GROUPPHOTO_TYPEID            @"typeId"
#define TB_GROUPPHOTO_TIMELINEINDEX     @"timelineIndex"
#define TB_GROUPPHOTO_READFLAG		    @"readFlag"
#define TB_GROUPPHOTO_SUBLINK		    @"sublink"


//tbGroupPhotoUrl
/*
 CREATE TABLE tbGroupPhotoUrl (
 ID integer  PRIMARY KEY DEFAULT NULL,
 url TEXT,
 newsId TEXT)
 */

#define	TB_GROUPPHOTOURL			   @"tbGroupPhotoUrl"
//字段
#define	TB_GROUPPHOTOURL_ID            @"ID"
#define	TB_GROUPPHOTOURL_NEWSID	       @"newsId"
#define	TB_GROUPPHOTOURL_URL	       @"url"

//tbTag
/*
 CREATE TABLE tbTag (
 ID integer  PRIMARY KEY DEFAULT NULL,
 tagId integer,
 tagName TEXT,
 groupName TEXT)
 */
#define	TB_TAG			               @"tbTag"
//字段
#define	TB_TAGID	                   @"tagId"
#define	TB_TAGNAME	                   @"tagName"
#define	TB_TAGGROUPNAME	               @"groupName"

//tbTag
/*
 CREATE TABLE tbCategory (
 ID integer  PRIMARY KEY DEFAULT NULL,
 categoryId integer,
 name TEXT,
 icon TEXT)
 */
#define	TB_CATEGORY			               @"tbCategory"
//字段
#define	TB_CATEGORYID	                   @"categoryId"
#define	TB_CATEGORYNAME	                   @"name"
#define	TB_ICON                            @"icon"
#define	TB_POSITION                        @"position"
#define	TB_TOP                             @"top"
#define	TB_TOPTIME                         @"topTime"
#define TB_CATEGORY_IS_SUBED               @"isSubed"
#define TB_CATEGORY_LAST_MODIFY            @"lastModify"

//tbAnalyticsEvent
/*
CREATE TABLE tbAnalyticsEvent (
                               ID integer  PRIMARY KEY AUTOINCREMENT DEFAULT NULL,
                               eventId Varchar DEFAULT NULL,
                               label Varchar DEFAULT NULL,
                               eventCount Varchar,
                               isUpload Smallint DEFAULT NULL)
*/
#define	TB_ANALYTICEVENT			       @"tbAnalyticsEvent"
//字段
#define	TB_ANALYTICEVENT_ID                @"ID"
#define	TB_EVENTID                         @"eventId"
#define	TB_LABEL                           @"label"
#define	TB_EVENTCOUNT                      @"eventCount"
#define	TB_ISUPLOAD                        @"isUpload"

//tbHomeV3SubscribeHomeInitialMySubscribe表
#define TB_HOME_V3_SUBSCRIBE_HOME_INITIAL_MY_SUBSCRIBE                          @"tbHomeV3SubscribeHomeInitialMySubscribe"

//tbHomeV3SubscribeHomeMySubscribe表
#define TB_HOME_V3_SUBSCRIBE_HOME_MY_SUBSCRIBE                                   @"tbHomeV3SubscribeHomeMySubscribe"

#define TB_SUB_HOME_ID                                                           @"ID"
#define TB_SUB_HOME_DEFAULT_SUB                                                  @"defaultSub"
#define TB_SUB_HOME_SUBSCRIBE_TYPE_NAME                                          @"subscribeTypeName"
#define TB_SUB_HOME_SUB_ID                                                       @"subId"
#define TB_SUB_HOME_SUB_KIND                                                     @"subKind"
#define TB_SUB_HOME_SUB_NAME                                                     @"subName"
#define TB_SUB_HOME_SUB_ICON                                                     @"subIcon"
#define TB_SUB_HOME_SUB_INFO                                                     @"subInfo"
#define TB_SUB_HOME_PUB_IDS                                                      @"pubIds"
#define TB_SUB_HOME_TERM_ID                                                      @"termId"
#define TB_SUB_HOME_LASTTERM_LINK                                                @"lastTermLink"
#define TB_SUB_HOME_MY_PUSH                                                      @"myPush"
#define TB_SUB_HOME_MORE_INFO                                                    @"moreInfo"
//my subscribe
#define TB_SUB_HOME_MY_SUB_ORDER_INDEX                                           @"orderIndex"
#define TB_SUB_HOME_MY_SUB_STATUS                                                @"status"
#define TB_SUB_HOME_MY_SUB_DOWNLOADED                                            @"downloaded"

//tbHomeV3SubscribeHomeInitialAllSubscribe表
#define TB_HOME_V3_SUBSCRIBE_HOME_INITIAL_ALL_SUBSCRIBE                          @"tbHomeV3SubscribeHomeInitialAllSubscribe"
//tbHomeV3SubscribeHomeAllSubscribe表
#define TB_HOME_V3_SUBSCRIBE_HOME_ALL_SUBSCRIBE                                  @"tbHomeV3SubscribeHomeAllSubscribe"
//all subscribe
#define TB_SUB_HOME_ALL_SUB_DEFAULT_PUSH                                         @"defaultPush"
#define TB_SUB_HOME_ALL_SUB_IS_SUBSCRIBED                                        @"isSubscribed"
#define TB_SUB_HOME_ALL_SUB_PUBLISH_TIME                                         @"publishTime"
#define TB_SUB_HOME_ALL_SUB_SUB_PERSON_COUNT                                     @"subPersonCount"
#define TB_SUB_HOME_ALL_SUB_TOP_NEWS                                             @"topNews"

// version 3.2 subscriber center
// tbHomeV32SubscribeAllSubscribe table
#define TB_SUB_CENTER_ALL_SUBSCRIBE                                               @"tbSubscribeCenterAllSubscribe"
// 字段
#define TB_SUB_CENTER_ALL_SUB_DEFAULT_SUB                                         @"defaultSub"
#define TB_SUB_CENTER_ALL_SUB_SUB_ID                                              @"subId"
#define TB_SUB_CENTER_ALL_SUB_SUB_NAME                                            @"subName"
#define TB_SUB_CENTER_ALL_SUB_SUB_ICON                                            @"subIcon"
#define TB_SUB_CENTER_ALL_SUB_SUB_INFO                                            @"subInfo"
#define TB_SUB_CENTER_ALL_SUB_MORE_INFO                                           @"moreInfo"
#define TB_SUB_CENTER_ALL_SUB_PUB_IDS                                             @"pubIds"
#define TB_SUB_CENTER_ALL_SUB_TERM_ID                                             @"termId"
#define TB_SUB_CENTER_ALL_SUB_LAST_TERM_LINK                                      @"lastTermLink"
#define TB_SUB_CENTER_ALL_SUB_IS_PUSH                                             @"isPush"
#define TB_SUB_CENTER_ALL_SUB_DEFAULT_PUSH                                        @"defaultPush"
#define TB_SUB_CENTER_ALL_SUB_PUBLISH_TIME                                        @"publishTime"
#define TB_SUB_CENTER_ALL_SUB_UN_READ_COUNT                                       @"unReadCount"
#define TB_SUB_CENTER_ALL_SUB_PERSON_COUNT                                        @"subPersonCount"
#define TB_SUB_CENTER_ALL_SUB_TOP_NEWS                                            @"topNews"
#define TB_SUB_CENTER_ALL_SUB_TOP_NEWS2                                           @"topNews2"
#define TB_SUB_CENTER_ALL_SUB_IS_SUBSCRIBED                                       @"isSubscribed"
#define TB_SUB_CENTER_ALL_SUB_IS_DOWNLOADED                                       @"isDownloaded"
#define TB_SUB_CENTER_ALL_SUB_IS_TOP                                              @"isTop"
#define TB_SUB_CENTER_ALL_SUB_TOP_TIME                                            @"topTime"
#define TB_SUB_CENTER_ALL_SUB_INDEX_VALUE                                         @"indexValue"
#define TB_SUB_CENTER_ALL_SUB_GRADE_LEVEL                                         @"starGrade"
#define TB_SUB_CENTER_ALL_SUB_COMMENT_COUNT                                       @"commentCount"
#define TB_SUB_CENTER_ALL_SUB_OPEN_TIMES                                          @"openTimes"
#define TB_SUB_CENTER_ALL_SUB_BACK_PROMOTION                                      @"backPromotion"
#define TB_SUB_CENTER_ALL_SUB_TEMPLATE_TYPE                                       @"templeteType"
#define TB_SUB_CENTER_ALL_SUB_IS_ON_RANK                                          @"isOnRank"
#define TB_SUB_CENTER_ALL_SUB_STATUS                                              @"status"
#define TB_SUB_CENTER_ALL_SUB_ISSELECTED                                          @"isSelected"
#define TB_SUB_CENTER_ALL_SUB_LINK                                                @"link"
#define TB_SUB_CENTER_ALL_SUB_SUB_SHOW_TYPE                                       @"subShowType"
#define TB_SUB_CENTER_ALL_SUB_STICKTOP                                            @"stickTop"
#define TB_SUB_CENTER_ALL_SUB_BUTTONTXT                                           @"buttonTxt"
#define TB_SUB_CENTER_ALL_SUB_NEED_LOGIN                                          @"needLogin"
#define TB_SUB_CENTER_ALL_SUB_CAN_OFFLINE                                         @"canOffline"
#define TB_SUB_CENTER_ALL_SUB_USERINFO                                            @"UserInfo"
#define TB_SUB_CENTER_ALL_SUB_SHOW_COMMENT                                        @"showComment"
#define TB_SUB_CENTER_ALL_SUB_SHOW_RECOMMEND_SUB                                  @"showRecmSub"
#define TB_SUB_CENTER_ALL_SUB_TOP_NEWS_ABSTRACT                                   @"topNewsAbstracts"
#define TB_SUB_CENTER_ALL_SUB_TOP_NEWS_LINK                                       @"topNewsLink"
#define TB_SUB_CENTER_ALL_SUB_TOP_NEWS_PICS                                       @"topNewsPicsString"
#define TB_SUB_CENTER_ALL_SUB_MY_SUB_SORT_INDEX                                   @"sortIndex"
#define TB_SUB_CENTER_ALL_SUB_TOPNEWS                                             @"topNewsString"
#define TB_SUB_CENTER_ALL_COUNT_SHOW_TEXT                                         @"countShowText"

// subscriber type list
#define TB_SUB_CENTER_SUB_TYPES                                      @"tbSubscribeCenterSubTypes"
// 字段
#define TB_SUB_CENTER_TYPES_TYPE_ID                                 @"typeId"
#define TB_SUB_CENTER_TYPES_TYPE_NAME                               @"typeName"
#define TB_SUB_CENTER_TYPES_TYPE_ICON                               @"typeIcon"
#define TB_SUB_CENTER_TYPES_SUB_ID                                  @"subId"
#define TB_SUB_CENTER_TYPES_SUB_NAME                                @"subName"

// 刊物分类--刊物 关系表
#define TB_SUB_CENTER_RELATION_SUB_TYPE                             @"tbSubscribeCenterSubTypeRelation"
// 字段
#define TB_SUB_CENTER_RELATION_TYPE_ID                              @"typeId"
#define TB_SUB_CENTER_RELATION_SUB_ID                               @"subId"

// sub home data -- adlist
#define TB_SUB_CENTER_AD_LIST                                       @"tbSubscriveCenterHomeAdList"
// 字段
#define TB_SUB_CENTER_AD_LIST_AD_NAME                               @"adName"
#define TB_SUB_CENTER_AD_LIST_AD_IMG                                @"adImg"
#define TB_SUB_CENTER_AD_LIST_AD_TYPE                               @"adType"
#define TB_SUB_CENTER_AD_LIST_REF_ID                                @"refId"
#define TB_SUB_CENTER_AD_LIST_REF_TEXT                              @"refText"
#define TB_SUB_CENTER_AD_LIST_REF_LINK                              @"refLink"
#define TB_SUB_CENTER_AD_LIST_TYPE                                  @"type"
#define TB_SUB_CENTER_AD_LIST_ADID                                  @"adId"

// 刊物评论 sub comment
#define TB_SUB_CENTER_SUB_COMMENT                                   @"tbSubscribeCenterSubComment"
#define TB_SUB_CENTER_SUB_COMMENT_SUB_ID                            @"subId"
#define TB_SUB_CENTER_SUB_COMMENT_AUTHOR                            @"author"
#define TB_SUB_CENTER_SUB_COMMENT_CTIME                             @"ctime"
#define TB_SUB_CENTER_SUB_COMMENT_CONTENT                           @"content"
#define TB_SUB_CENTER_SUB_COMMENT_STAR_GRADE                        @"starGrade"
#define TB_SUB_CENTER_SUB_COMMENT_CITY                              @"city"

// sharelist table
#define TB_SHARE_LIST                   @"tbShareList"
// 字段
#define TB_SHARE_ID                     @"ID"
#define TB_SHARE_STATUS                 @"status"
#define TB_SHARE_APP_LEVEL              @"appLevel"
#define TB_SHARE_APP_ID                 @"appID"
#define TB_SHARE_APP_NAME               @"appName"
#define TB_SHARE_APP_ICON               @"appIconUrl"
#define TB_SHARE_APP_ICON_GRAY          @"appGrayIconUrl"
#define TB_SHARE_USER_NAME              @"userName"
#define TB_SHARE_REQUEST_URL            @"requestUrl"
#define TB_SHARE_OPENID                 @"openId"

// livingGame table
#define TB_LIVING_GAME                  @"tbLivingGame"
// 字段
#define TB_LIVING_GAME_ID               @"ID"
#define TB_LIVING_GAME_FLAG             @"flag"
#define TB_LIVING_GAME_IS_TODAY         @"isToday"
#define TB_LIVING_GAME_IS_FOCUS         @"isFocus"
#define TB_LIVING_GAME_LIVE_ID          @"liveId"
#define TB_LIVING_GAME_LIVE_PIC         @"livePic"
#define TB_LIVING_GAME_IS_HOT           @"isHot"
#define TB_LIVING_GAME_LIVE_CAT         @"liveCat"
#define TB_LIVING_GAME_LIVE_SUB_CAT     @"liveSubCat"
#define TB_LIVING_GAME_LIVE_TYPE        @"liveType"
#define TB_LIVING_GAME_TITLE            @"title"
#define TB_LIVING_GAME_STATUS           @"status"
#define TB_LIVING_GAME_LIVE_TIME        @"liveTime"
#define TB_LIVING_GAME_LIVE_DAY         @"liveDay"
#define TB_LIVING_GAME_LIVE_DATE        @"liveDate"

#define TB_LIVING_GAME_VISITOR_ID       @"visitorId"
#define TB_LIVING_GAME_VISITOR_NAME     @"visitorName"
#define TB_LIVING_GAME_VISITOR_PIC      @"visitorPic"
#define TB_LIVING_GAME_VISITOR_INFO     @"visitorInfo"
#define TB_LIVING_GAME_VISITOR_TOTAL    @"visitorTotal"

#define TB_LIVING_GAME_HOST_ID          @"hostId"
#define TB_LIVING_GAME_HOST_NAME        @"hostName"
#define TB_LIVING_GAME_HOST_PIC         @"hostPic"
#define TB_LIVING_GAME_HOST_INFO        @"hostInfo"
#define TB_LIVING_GAME_HOST_TOTAL       @"hostTotal"

#define TB_LIVING_GAME_MEDIA_TYPE       @"mediaType"
#define TB_LIVING_GAME_PUB_TYPE         @"pubType"

//tbNewsComment
#define	TB_COMMENTJSON					@"tbCommentJson"
//字段
#define TB_COMMENTJSON_ID				@"ID"
#define TB_COMMENTJSON_CID				@"commentId"
#define	TB_COMMENTJSON_CTIME			@"ctime"
#define TB_COMMENTJSON_CONTENT			@"commentJson"
#define TB_COMMENTJSON_NID              @"newsId"
#define TB_COMMENTJSON_TYPE             @"type"
#define TB_COMMENTJSON_TOPICID          @"topicId"
#define TB_COMMENTJSON_NEWSTYPE         @"newsType"
#define TB_COMMENTJSON_DIGNUM           @"digNum"
#define TB_COMMENTJSON_HADDING          @"hadDing"

#define	TB_ADS                          @"tbAds"
#define	TB_ADS_TITLE                    @"title"
#define	TB_ADS_BIGPICURL                @"bigPicUrl"
#define	TB_ADS_SMALLPICURL              @"smallPicUrl"
#define	TB_ADS_STARTTIME                @"startTime"
#define	TB_ADS_ENDTIME                  @"endTime"
#define	TB_ADS_LINK                     @"link"
#define	TB_ADS_POSITION                 @"position"
#define	TB_ADS_VERSION                  @"version"

//tbSpecialNewsList表
#define TB_SPECIALNEWSLIST              @"tbSpecialNewsList"
#define TB_SPECIALNEWSLIST_ID           @"ID"
#define TB_SPECIALNEWSLIST_TERMID       @"termId"
#define TB_SPECIALNEWSLIST_TERMNAME     @"termName"
#define TB_SPECIALNEWSLIST_NEWSID       @"newsId"
#define TB_SPECIALNEWSLIST_NEWSTYPE     @"newsType"
#define TB_SPECIALNEWSLIST_TITLE        @"title"
#define TB_SPECIALNEWSLIST_PICLIST      @"pic_list"
#define TB_SPECIALNEWSLIST_ABSTRACT     @"abstract"
#define TB_SPECIALNEWSLIST_ISFOCUSDISAP @"isFocusDisp"
#define TB_SPECIALNEWSLIST_LINK         @"link"
#define TB_SPECIALNEWSLIST_ISREAD       @"isRead"
#define TB_SPECIALNEWSLIST_FORM         @"form"
#define TB_SPECIALNEWSLIST_GROUPNAME    @"groupName"
#define TB_SPECIALNEWSLIST_HAS_VIDEO    @"hasVideo"
#define TB_SPECIALNEWSLIST_UPDATETIME   @"updateTime"
#define TB_SPECIALNEWSLIST_EXPIRED      @"expired"

//tbMyFavourites
#define TB_MYFAVOURITES                     @"tbMyFavourites"
#define TB_MYFAVOURITES_ID                  @"ID"
#define TB_MYFAVOURITES_TITLE               @"title"
#define TB_MYFAVOURITES_MYFAVOURITEREFER    @"myFavouriteRefer"
#define TB_MYFAVOURITES_CONTENTLEVELONEID   @"contentLeveloneID"
#define TB_MYFAVOURITES_CONTENTLEVELTWOID   @"contentLeveltwoID"
#define TB_MYFAVOURITES_ISREAD              @"isRead"
#define TB_MYFAVOURITES_IMAGEURL            @"imgURL"
#define TB_MYFAVOURITES_PUBDATE             @"pubDate"
#define TB_MYFAVOURITES_USERID              @"userId"

//tbCloudSave
#define TB_CLOUDSAVES                       @"tbCloudSaves"
#define TB_CLOUDSAVES_ID                    @"ID"
#define TB_CLOUDSAVES_TITLE                 @"title"
#define TB_CLOUDSAVES_LINK                  @"link"
#define TB_CLOUDSAVES_COLLECTTIME           @"collecttime"
#define TB_CLOUDSAVES_USERID                @"userid"
#define TB_CLOUDSAVES_MYFAVOURITEREFER      @"myFavouriteRefer"
#define TB_CLOUDSAVES_CONTENTLEVELONEID     @"contentLeveloneID"
#define TB_CLOUDSAVES_CONTENTLEVELTWOID     @"contentLeveltwoID"

//tbLocalChannel
/*
#define TB_LOCALCHANNEL                     @"tbLocalChannel"
#define TB_LOCALCHANNEL_ID                  @"ID"
#define TB_LOCALCHANNEL_USERID              @"userid"
#define TB_LOCALCHANNEL_TYPE                @"type" //2代表新闻频道 3代表组图频道
#define TB_LOCALCHANNEL_TIMESTAMP           @"timestamp"
#define TB_LOCALCHANNEL_CONTENT             @"content" //实际需要发送的内容*/

// tbWeatherReports
#define TB_WEATHER                      @"tbWeatherReports"
#define TB_WEATHER_CITY                 @"city"
#define TB_WEATHER_CITY_CODE            @"cityCode"
#define TB_WEATHER_CITY_GBCODE          @"cityGbcode"
#define TB_WEATHER_SHARE_LINK           @"shareLink"
#define TB_WEATHER_INDEX                @"weatherIndex"
#define TB_WEATHER_CHUANYI              @"chuanyi"
#define TB_WEATHER_DATE                 @"date"
#define TB_WEATHER_CHINESE_DATE         @"chineseDate"
#define TB_WEATHER_GANMAO               @"ganmao"
#define TB_WEATHER_JIAOTONG             @"jiaotong"
#define TB_WEATHER_LVYOU                @"lvyou"
#define TB_WEATHER_PLATFORMID           @"platformId"
#define TB_WEATHER_TEMPHIGH             @"tempHigh"
#define TB_WEATHER_TEMPLOW              @"tempLow"
#define TB_WEATHER_WEATHER              @"weather"
#define TB_WEATHER_WEATHERICON          @"weatherIconUrl"
#define TB_WEATHER_WEATHERICONLOCAL     @"weatherLocalIconUrl"
#define TB_WEATHER_WIND                 @"wind"
#define TB_WEATHER_WURAN                @"wuran"
#define TB_WEATHER_YUNDONG              @"yundong"
#define TB_WEATHER_PM25                 @"pm25"
#define TB_WEATHER_QUALITY              @"quality"
#define TB_WEATHER_SHARECONTENT         @"shareContent"
#define TB_WEATHER_MORELINK             @"morelink"
#define TB_WEATHER_COPYWRITING          @"copywriting"

// tbNickName
#define TB_NICKNAME                     @"tbNickName"
#define TB_NICKNAME_ID                  @"ID"
#define TB_NICKNAME_NICKNAME            @"nickName"

// tbRecommendNews
#define TB_RECOMMEND_NEWS               @"tbRecommendNews"
#define TB_NEWS_ID                      @"ID"
#define TB_NEWS_TITLE                   @"title"
#define TB_NEWS_LINK                    @"link"
#define TB_RELATED_NEWSID               @"relatedNewsID"
#define TB_NEWS_TYPE                    @"newsType"
#define TB_NEWS_ICON                    @"icon"
#define TB_NEWS_ICON_NIGHT              @"iconNight"

// tbVotesInfo
#define TB_VOTES_INFO                   @"tbVotesInfo"
#define TB_VOTES_NEWS_ID                @"newsID"
#define TB_VOTES_TOPIC_ID               @"topicID"
#define TB_VOTES_IS_VOTED               @"isVoted"
#define TB_VOTES_XML_STR                @"voteXML"
#define TB_VOTES_IS_OVER                @"isOver"

// tbWeiboHotItem
#define TB_WEIBOHOT_ITEM                @"tbWeiboHotItem"
#define TB_WEIBOHOT_ITEM_ID             @"weiboId"
#define TB_WEIBOHOT_ITEM_NICK           @"nick"
#define TB_WEIBOHOT_ITEM_HEAD_URL       @"head"
#define TB_WEIBOHOT_ITEM_IS_VIP         @"isVip"
#define TB_WEIBOHOT_ITEM_TIME           @"time"
#define TB_WEIBOHOT_ITEM_TITLE          @"title"
#define TB_WEIBOHOT_ITEM_TYPE           @"type"
#define TB_WEIBOHOT_ITEM_COMMENT_NUM    @"commentCount"
#define TB_WEIBOHOT_ITEM_CONTENT        @"content"
#define TB_WEIBOHOT_ITEM_ABSTRACT       @"abstract"
#define TB_WEIBOHOT_ITEM_FOCUS_PIC      @"focusPic"
#define TB_WEIBOHOT_ITEM_WEIGHT         @"weight"
#define TB_WEIBOHOT_ITEM_USER_JSON      @"userJson"
#define TB_WEIBOHOT_ITEM_PAGENO         @"pageNo"
#define TB_WEIBOHOT_ITEM_READ_MARK      @"readMark"
#define TB_WEIBOHOT_ITEM_ICON           @"icon"

// tbWeiboHotDetail
#define TB_WEIBOHOT_DETAIL                @"tbWeiboHotDetail"
#define TB_WEIBOHOT_DETAIL_ID             @"weiboId"
#define TB_WEIBOHOT_DETAIL_NICK           @"nick"
#define TB_WEIBOHOT_DETAIL_IS_VIP         @"isVip"
#define TB_WEIBOHOT_DETAIL_HEAD_URL       @"head"
#define TB_WEIBOHOT_DETAIL_HOME_URL       @"homeUrl"
#define TB_WEIBOHOT_DETAIL_TITLE          @"title"
#define TB_WEIBOHOT_DETAIL_TIME           @"time"
#define TB_WEIBOHOT_DETAIL_TYPE           @"weiboType"
#define TB_WEIBOHOT_DETAIL_COMMENT_NUM    @"commentCount"
#define TB_WEIBOHOT_DETAIL_CONTENT        @"content"
#define TB_WEIBOHOT_DETAIL_NEWSID         @"newsId"
#define TB_WEIBOHOT_DETAIL_WAP_URL        @"wapUrl"
#define TB_WEIBOHOT_DETAIL_RESOURCE_JSON  @"resourceJSON"
#define TB_WEIBOHOT_DETAIL_SHARE          @"shareContent"
#define TB_WEIBOHOT_DETAIL_HEIGHT         @"cellHeight"
#define TB_WEIBOHOT_DETAIL_SOURCE         @"source"

// tbWeiboHotComment
#define TB_WEIBOHOT_Comment                @"tbWeiboHotComment"
#define TB_WEIBOHOT_Comment_ID             @"commentId"
#define TB_WEIBOHOT_Comment_NICK           @"nick"
#define TB_WEIBOHOT_Comment_HEAD_URL       @"head"
#define TB_WEIBOHOT_Comment_IS_VIP         @"isVip"
#define TB_WEIBOHOT_Comment_TIME           @"time"
#define TB_WEIBOHOT_Comment_CONTENT        @"content"
#define TB_WEIBOHOT_Comment_TYPE           @"type"
#define TB_WEIBOHOT_Comment_HOME_URL       @"homeUrl"
#define TB_WEIBOHOT_Comment_HEIGHT         @"cellHeight"
#define TB_WEIBOHOT_Comment_GENDER         @"gender"

#define TB_SEARCH_HISTORY                  @"tbSearchHistory"
#define TB_SEARCH_HISTORY_CONTENT          @"content"
#define TB_SEARCH_HISTORY_TIME             @"time"

#define TB_NEWS_AUDIO                       @"tbNewsAudio"

//
#define TB_CREATEAT_COLUMN              @"createAt"

//tbNotification
#define TB_NOTIFICATION                 @"tbNotification"
#define TB_NOTIFICATION_PID             @"pid"
#define TB_NOTIFICATION_MSGID           @"msgid"
#define TB_NOTIFICATION_TYPE            @"type"
#define TB_NOTIFICATION_ALERT           @"alert"
#define TB_NOTIFICATION_DATA_PID        @"dataPid"
#define TB_NOTIFICATION_NICK_NAME       @"nickName"
#define TB_NOTIFICATION_HEAD_URL        @"headUrl"
#define TB_NOTIFICATION_TIME            @"time"

// share read circle data set
#define TB_SHARE_READ_CIRCLE                @"tbShareReadCircle"
#define TB_SHARE_READ_CIRCLE_TYPE           @"type"
#define TB_SHARE_READ_CIRCLE_CONTENT_ID     @"contentId"
#define TB_SHARE_READ_CIRCLE_JSON           @"json"

// read circle timeline
#define TB_READCIRCLE_TIMELINE              @"tbReadcircleTimeline"
#define TB_READCIRCLE_TIMELINE_TYPE         @"type"
#define TB_READCIRCLE_TIMELINE_SHARE_ID     @"shareId"
#define TB_READCIRCLE_TIMELINE_PID          @"pid"
#define TB_READCIRCLE_TIMELINE_JSON         @"json"

// newspaper read flag
#define TB_PAPER_READFLAG              @"tbNewspaperReadFlag"
#define TB_PAPER_READFLAG_LINK2        @"link2"
#define TB_PAPER_READFLAG_READ         @"readFlag"
#define TB_PAPER_READFLAG_CREATE       @"createAt"

//视频下载表
#define TB_VIDEOS_DOWNLOAD                                  @"tbVideosDownload"
#define TB_VIDEOS_DOWNLOAD_ID                               @"id"
#define TB_VIDEOS_DOWNLOAD_VID                              @"vid"
#define TB_VIDEOS_DOWNLOAD_NAME                             @"name"
#define TB_VIDEOS_DOWNLOAD_TITLE                            @"title"
#define TB_VIDEOS_DOWNLOAD_POSTER                           @"poster"
#define TB_VIDEOS_DOWNLOAD_VIDEO_SOURCES                    @"videoSources"
#define TB_VIDEOS_DOWNLOAD_DOWNLOADURL                      @"downloadURL"
#define TB_VIDEOS_DOWNLOAD_VIDEOTYPE                        @"videoType"
#define TB_VIDEOS_DOWNLOAD_LOCAL_RELATIVEPATH               @"localRelativePath"
#define TB_VIDEOS_DOWNLOAD_LOCAL_M3U8URL                    @"localM3U8URL"
#define TB_VIDEOS_DOWNLOAD_TOTALBYTES                       @"totalBytes"
#define TB_VIDEOS_DOWNLOAD_STATE                            @"state"
#define TB_VIDEOS_DOWNLOAD_BEGIN_DOWNLOAD_TIMEINTERVAL      @"beginDownloadTimeInterval"
#define TB_VIDEOS_DOWNLOAD_FINISH_DOWNLOAD_TIMEINTERVAL     @"finishDownloadTimeInterval"

//视频timeline表
#define TB_VIDEO_TIMELINE                                   @"tbVideoTimeline"
#define TB_VIDEO_TIMELINE_INDEX                             @"timelineindex"
#define TB_VIDEO_TIMELINE_CHANNELID                         @"channelId"
#define TB_VIDEO_TIMELINE_ID                                @"id"
#define TB_VIDEO_TIMELINE_VID                               @"vid"
#define TB_VIDEO_TIMELINE_COLUMN_ID                         @"columnId"
#define TB_VIDEO_TIMELINE_COLUMN_NAME                       @"columnName"
#define TB_VIDEO_TIMELINE_PIC                               @"pic"
#define TB_VIDEO_TIMELINE_PIC_4_3                           @"pic_4_3"
#define TB_VIDEO_TIMELINE_SMALL_PIC                         @"smallPic"
#define TB_VIDEO_TIMELINE_URL                               @"url"
#define TB_VIDEO_TIMELINE_TITLE                             @"title"
#define TB_VIDEO_TIMELINE_PLAYURL_MP4S                      @"playurl_mp4s"
#define TB_VIDEO_TIMELINE_PLAYURL_MP4                       @"playurl_mp4"
#define TB_VIDEO_TIMELINE_PLAYURL_M3U8                      @"playurl_m3u8"
#define TB_VIDEO_TIMELINE_AUTHOR_NAME                       @"author_name"
#define TB_VIDEO_TIMELINE_AUTHOR_ID                         @"author_id"
#define TB_VIDEO_TIMELINE_AUTHOR_TYPE                       @"author_type"
#define TB_VIDEO_TIMELINE_AUTHOR_ICON                       @"author_icon"
#define TB_VIDEO_TIMELINE_SHARE_CONTENT                     @"share_content"
#define TB_VIDEO_TIMELINE_SHARE_H5URL                       @"share_h5url"
#define TB_VIDEO_TIMELINE_SHARE_UGCWORDLIMIT                @"share_ugcWordLimit"
#define TB_VIDEO_TIMELINE_SITE_NAME                         @"siteName"
#define TB_VIDEO_TIMELINE_SITE_ID                           @"siteId"
#define TB_VIDEO_TIMELINE_SITE                              @"site"
#define TB_VIDEO_TIMELINE_SITE2                             @"site2"
#define TB_VIDEO_TIMELINE_ADSERVER                          @"adServer"
#define TB_VIDEO_TIMELINE_PLAYBYID                          @"playById"
#define TB_VIDEO_TIMELINE_PLAYAD                            @"playAd"
#define TB_VIDEO_TIMELINE_LINK2                             @"link2"
#define TB_VIDEO_TIMELINE_DOWNLOAD                          @"download"
#define TB_VIDEO_TIMELINE_DURATION                          @"duration"
#define TB_VIDEO_TIMELINE_MULTIPLETYPE                      @"multipleType"
#define TB_VIDEO_TIMELINE_TEMPLATEPIC                       @"templatePic"
#define TB_VIDEO_TIMELINE_CONTENT                           @"content"
#define TB_VIDEO_TIMELINE_PLAYTYPE                          @"playType"
#define TB_VIDEO_TIMELINE_MEDIALINK                         @"mediaLink"
#define TB_VIDEO_TIMELINE_APPCONTENT                        kTimelineAppContent
#define TB_VIDEO_TIMELINE_OFFLINE_PLAY                      @"offlinePlay"
#define TB_VIDEO_TIMELINE_FINISH_DOWNLOAD_TIMEINTERVAL      @"finishDownloadTimeInterval"
#define TB_VIDEO_TIMELINE_UNINTERINST                       @"uninterinst"
#define TB_VIDEO_TIMELINE_BANNER_DATA                       @"banner_data"
#define TB_VIDEO_TIMELINE_ENTRY_DATA                        @"entry_data"

//离线视频表，用于存储视频播放页离线播放时需要的数据
#define TB_VIDEO_PLAYINOFFLINE                              @"tbVideoPlayInOffline"
#define CL_VIDEO_PLAYINOFFLINE_VID                          @"vid"
#define CL_VIDEO_PLAYINOFFLINE_CHANNEL_ID                   @"channelId"
#define CL_VIDEO_PLAYINOFFLINE_MESSAGE_ID                   @"messageId"
#define CL_VIDEO_PLAYINOFFLINE_TITLE                        @"title"
#define CL_VIDEO_PLAYINOFFLINE_SUBTITLE                     @"subTitle"
#define CL_VIDEO_PLAYINOFFLINE_COLUMN_NAME                  @"columnName"
#define CL_VIDEO_PLAYINOFFLINE_AUTHOR_TYPE                  @"authorType"
#define CL_VIDEO_PLAYINOFFLINE_AUTHOR_NAME                  @"authorName"
#define CL_VIDEO_PLAYINOFFLINE_SITE_NAME                    @"siteName"
#define CL_VIDEO_PLAYINOFFLINE_POSTER                       @"poster"
#define CL_VIDEO_PLAYINOFFLINE_VIDEO_LINK2                  @"videoLink2"
#define CL_VIDEO_PLAYINOFFLINE_PLAY_TYPE                    @"playType"
#define CL_VIDEO_PLAYINOFFLINE_VIDEO_URL_FOR_PLAYING_IN_NATIVE_PLAYER   @"videoURLForPlayingInNativePlayer"
#define CL_VIDEO_PLAYINOFFLINE_VIDEO_URL_FOR_PLAYING_IN_INNER_WEB       @"videoURLForPlayingInInnerWeb"
#define CL_VIDEO_PLAYINOFFLINE_MEDIA_LINK                   @"mediaLink"
#define CL_VIDEO_PLAYINOFFLINE_CONTENT_FOR_SHARING_SHOW     @"contentForSharingShow"
#define CL_VIDEO_PLAYINOFFLINE_CONTENT_FOR_SHARING_TO       @"contentForSharingTo"
#define CL_VIDEO_PLAYINOFFLINE_H5_URL_FOR_SHARING_TO        @"h5URLForSharingTo"

//视频channel频道表
#define TB_VIDEO_CHANNEL                                    @"tbVideoChannel"
#define TB_VIDEO_CHANNEL_INDEX                              @"channelindex"
#define TB_VIDEO_CHANNEL_ID                                 @"id"
#define TB_VIDEO_CHANNEL_STATUS                             @"status"
#define TB_VIDEO_CHANNEL_SORT                               @"sort"
#define TB_VIDEO_CHANNEL_TITLE                              @"title"
#define TB_VIDEO_CHANNEL_CTIME                              @"ctime"
#define TB_VIDEO_CHANNEL_UTIME                              @"utime"
#define TB_VIDEO_CHANNEL_DESCN                              @"descn"
#define TB_VIDEO_CHANNEL_SORTABLE                           @"sortable"
#define TB_VIDEO_CHANNEL_UP                                 @"up"

// 视频 热播栏目
#define TB_VIDEO_COLUMN                                     @"tbVideoColumn"
#define TB_VIDEO_COLUMN_INDEX                               @"id"
#define TB_VIDEO_COLUMN_ID                                  @"columnId"
#define TB_VIDEO_COLUMN_TITLE                               @"title"
#define TB_VIDEO_COLUMN_IS_SUB                              @"isSub"
#define TB_VIDEO_COLUMN_READ_COUNT                          @"readCount"

// 直播 分类
#define TB_LIVE_CATEGORY                                    @"tbLiveCategory"
#define TB_LIVE_CATEGORY_SUBID                              @"subId"
#define TB_LIVE_CATEGORY_NAME                               @"name"
#define TB_LIVE_CATEGORY_LINK                               @"link"

// 直播 邀请
#define TB_LIVE_INVITE                                      @"tbLiveInvite"
#define TB_LIVE_INDEX                                       @"id"
#define TB_LIVE_INVITE_LIVEID                               @"liveId"
#define TB_LIVE_INVITE_PASSPORT                             @"passport"
#define TB_LIVE_INVITE_STATUS                               @"inviteStatus"
#define TB_LIVE_INVITE_SHOWMSG                              @"showmsg"
#define TB_LIVE_INVITE_CREATE                               @"createAt"

//视频 断点续播
#define TB_VIDEO_BREAKPOINT                                 @"tbVideoBreakpoint"
#define TB_VIDEO_BREAKPOINT_VID                             @"vid"
#define TB_VIDEO_BREAKPOINT_BREAKPOINT                      @"breakpoint"
#define TB_VIDEO_BREAKPOINT_CREATE                          @"createAt"
#define TB_VIDEO_BREAKPOINT_CONTEXT                         @"context"

// 广告数据
#define TB_AD_INFO_TABLE                                    @"tbAdInfos"
#define TB_AD_INFO_ID                                       @"ID"
#define TB_AD_INFO_TYPE                                     @"type"
#define TB_AD_INFO_DATA_ID                                  @"dataId"
#define TB_AD_INFO_CATEGORY_ID                              @"categoryId"
#define TB_AD_INFO_JSON_STRING                              @"jsonString"

