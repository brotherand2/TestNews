//
//  SNRollingNewsModel+preload.m
//  sohunews
//
//  Created by jojo on 13-11-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsModel+preload.h"
#import "SNRollingNews.h"
#import "SNArticleDownloader.h"
#import "SNPhotoListDownloader.h"
#import "SNNewsListThumbnailDownloader.h"
#import "SNNewsType.h"

@implementation SNRollingNewsModel (preload)

- (void)startANewsArticleDownloadTask:(SNRollingNews *)rollingNews {
    SNArticleDownloader *dl = [SNArticleDownloader downloader];
    dl.newsId = rollingNews.newsId;
    dl.channelId = self.channelId;
    dl.linkParams = [SNUtility parseLinkParams:rollingNews.link];
    [dl startWorkInWifiPriority];
}

- (void)startAGroupPhotoDownloadTask:(SNRollingNews *)rollingNews {
    SNPhotoListDownloader *dl = [SNPhotoListDownloader downloader];
    dl.channelId = self.channelId;
    dl.newsId = rollingNews.newsId;
    [dl startWorkInWifiPriority];
}

- (void)startDownloadARollingNews:(SNRollingNews *)rollingNews {
    // 优先加载图片
//    if (rollingNews.picUrl) {
//        SNNewsListThumbnailDownloader *picDownloader = [SNNewsListThumbnailDownloader downloader];
//        picDownloader.imageUrl = rollingNews.picUrl;
//        [picDownloader startWorkInWifiPriority];
//    }
    
    int _type = [rollingNews.newsType intValue];
    switch (_type) {
        case SNNewsType_FocusNews:
        case SNNewsType_PhotoAndTextNews:
        case SNNewsType_TextNews:
        case SNNewsType_TitleNews:
        case SNNewsType_JokeNews:
        case SNNewsType_VoteNews: {
            [self startANewsArticleDownloadTask:rollingNews];
            break;
        }
        case SNNewsType_GroupPhotoNews: { // 组图新闻
//            // 优先加载图片
//            for (NSString *imageUrl in rollingNews.picUrls) {
//                SNNewsListThumbnailDownloader *picDownloader = [SNNewsListThumbnailDownloader downloader];
//                picDownloader.imageUrl = imageUrl;
//                [picDownloader startWorkInWifiPriority];
//            }
//            
          [self startAGroupPhotoDownloadTask:rollingNews];
            break;
        }
        case SNNewsType_OutterLinkNews: { // 外链新闻，暂不支持
            break;
        }
        case SNNewsType_LiveNews: { // 直播，暂不支持
            break;
        }
        case SNNewsType_SpecialNews: { // 专题新闻，暂不支持
            break;
        }
        case SNNewsType_NewspaperNews: { // 报纸，暂不支持
            break;
        }
        default:
            break;
    }
}

- (void)fetchNewsContentData {
    
    if (!isPreload || ![SNUtility getP1]) {
        return;
    }
    
    for (SNRollingNews *news in self.recommendNews) {
        [self startDownloadARollingNews:news];
    }
    
    for (int i = 0; i < self.rollingNews.count; i++) {
        [self startDownloadARollingNews:self.rollingNews[i]];
    }
}

@end
