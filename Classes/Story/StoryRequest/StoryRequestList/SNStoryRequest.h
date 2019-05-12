//
//  SNStoryRequest.h
//  sohunews
//
//  这么做请求，会造成和主线紧密耦合，但ATS及主线查找请求修改方便，就这样做了
//
//  Created by chuanwenwang on 2016/12/13.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"
#import "SNStoryPublicLinks.h"

@interface SNStoryDetailRequest : SNDefaultParamsRequest

@end

@interface SNStoryChapterListRequest : SNDefaultParamsRequest

@end

@interface SNStoryChapterContentRequest : SNDefaultParamsRequest

@end

@interface SNStoryPurchaseChapterContentRequest : SNDefaultParamsRequest

@end

@interface SNStoryDownloadAvailableChapterContentRequest : SNDefaultParamsRequest

@end

@interface SNStoryHotWordsSearchRequest : SNDefaultParamsRequest

@end

@interface SNBookAddShelfRequest : SNDefaultParamsRequest

@end

@interface SNDelBookFromShelfRequest : SNDefaultParamsRequest

@end

@interface SNGetShelfBooksRequest : SNDefaultParamsRequest

@end

@interface SNShelfBookRemindRequest : SNDefaultParamsRequest

@end

@interface SNBookHadReadRequest : SNDefaultParamsRequest

@end

@interface SNStoryBookAdd_AnchorRequest : SNDefaultParamsRequest

@end

@interface SNStoryBookGet_AnchorRequest : SNDefaultParamsRequest

@end

