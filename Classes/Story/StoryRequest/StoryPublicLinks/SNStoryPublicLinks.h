//
//  SNStoryPublicLinks.h
//  sohunews
//
//  Created by chuanwenwang on 2016/12/13.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#ifndef SNStoryPublicLinks_h
#define SNStoryPublicLinks_h

#import "SNStoryUtility.h"

//小说H5相关
#define H5StoryReport(newsId,reportType) [NSString stringWithFormat:@"h5apps/newssdk.sohu.com/modules/report/report.html?newsId=%@&reportType=%@",newsId,reportType]//小说举报 reportType=4 newsId=小说章节id
#define StoryDetailShare(type,bookId) [NSString stringWithFormat:@"api/share/shareon.go?type=%@&on=all&bookId=%@",type,bookId]//小说详情分享文案请求 type=book&on=all&bookId=123
#define StoryDetailAllComments @"h5apps/novel.sohu.com/modules/noveldetails/allComments.html?"//小说详情全部评论 type=book&on=all&bookId=123
#define StoryH5FoundMore(type,tagId) [NSString stringWithFormat:@"h5apps/novel.sohu.com/modules/novel/novel.html?type=%@&tagId=%@",type,tagId]//小说发现更多(type 1:表示排行榜  2:分类)
#define StoryH5Detail(novelId) [NSString stringWithFormat:@"h5apps/novel.sohu.com/modules/noveldetails/noveldetails.html?novelId=%@",novelId]//小说详情
#define StoryH5Label(tagId,channelId,title) [NSString stringWithFormat:@"h5apps/novel.sohu.com/modules/novelpages/novelpages.html?tagId=%@&channelId=%@&title=%@",tagId,channelId,title]//小说运营标签

//小说请求相关
#define StoryDetailRequestURL                                        ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/tail.go"])//小说详情
#define StoryChapterListRequestURL                                   ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/querychapterindex.go"])//小说章节
#define StoryChapterContentRequestURL                                ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/querychaptercontent.go"])//小说章节内容
#define StoryPurchaseChapterContentRequestURL                        ([SNStoryUtility getStoryRequestUrlWithStr:@"api/payment/payInfo.go"])//购买付费章节
#define StoryDownloadAvailableChapterContentRequestURL               ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/download.go"])//下载全部可读章节
#define StoryHotWordsSearchRequestURL                                ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/hotwords.go"])//小说热词搜索
#define StoryAddToShelfRequestURL                                    ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/add_shelf.go"])// 小说添加到书架
#define StoryDelFromShelfRequestURL                                  ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/del_shelf.go"])// 小说从书架删除
#define StoryQueryShelfRequestURL                                    ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/query_shelf.go"])// 获取书架上的小说
#define StoryShelfRemindRequestURL                                   ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/shelf_remind.go"])// 书架书籍，开启提醒
#define StoryBookHasReadRequestURL                                   ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/hasread.go"])// 已读书籍
#define StoryBookAdd_AnchorRequestURL                                   ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/add_anchor.go"])//添加锚点
#define StoryBookGet_AnchorRequestURL                                   ([SNStoryUtility getStoryRequestUrlWithStr:@"api/book/get_anchor.go"])//获取锚点

#endif/* SNStoryPublicLinks_h */
