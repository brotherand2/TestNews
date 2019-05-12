//
//  SNDBManager.h
//  sohunewsipad
//
//  Created by ivan on 9/29/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDatabase.h"

@interface SNDBManager : NSObject
{
    //NSMutableDictionary	*s_cacheMgrInstanceDic;
    NSMutableArray		*s_downloadingNewsArticle;
}

- (BOOL)addDownloadingNewsArticle:(NewsArticleItem *)newsArticle;
- (BOOL)removeDownloadingNewsArticle:(NewsArticleItem *)newsArticle;
- (BOOL)isNewsArticleInDownloading:(NewsArticleItem *)newsArticle;

+ (SNDBManager *)sharedInstance;
+ (SNDatabase *)currentDataBase;
@end


#import "SNDatabase_Newspaper.h"
#import "SNDatabase_NewsChannel.h"
#import "SNDatabase_News.h"
#import "SNDatabase_NewsImage.h"
#import "SNDatabase_RollingNewsList.h"
#import "SNDatabase_Gallery.h"
#import "SNDatabase_Photo.h"
#import "SNDatabase_RecommendGallery.h"
#import "SNDatabase_NewsComment.h"
#import "SNDatabase_GroupPhoto.h"
#import "SNDatabase_Tag.h"
#import "SNDatabase_Category.h"
#import "SNDatabase_ShareList.h"
#import "SNDatabase_LivingGame.h"
#import "SNDatabase_FloorComment.h"
#import "SNDatabase_SpecialNewsList.h"
#import "SNDatabase_Weather.h"
#import "SNDatabase_MyFavourite.h"

#import "SNDatabase_NickNameObj.h"
#import "SNDatabase_Votes.h"
#import "SNDatabase_SubscribeCenter.h"
#import "SNDatabase_WeiboHotDetail.h"
#import "SNDatabase_WeiboHotItem.h"
#import "SNDatabase_WeiboHotChannel.h"
#import "SNDatabase_Cleaner.h"
#import "SNDatabase_SearchHistory.h"
#import "SNDatabase_ReadCircle.h"
#import "SNDatabase+ReadFlag.h"
#import "SNDatabase_VideoDownloadManager.h"
#import "SNDatabase+VideoTimeline.h"
#import "SNDatabase+VideoChannel.h"
#import "SNDatabase+VideoColumn.h"
#import "SNDatabase+VideoBreakpoint.h"

#import "SNDatabase_MyFavourite.h"
#import "SNDatabase_CloudSave.h"

#import "SNDatabase+adInfos.h"
#import "SNDatabase+LiveInvite.h"
