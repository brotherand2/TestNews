//
//  SNRollingNewsImageFetcher.h
//  sohunews
//
//  Created by handy wang on 1/6/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CacheObjects.h"
#import "SNArticle.h"

@protocol SNNewsImageFetcherDelegate
@optional
- (void)finishedToFetchRollingNewsImagesInThread;
- (void)finishedToFetchImagesInThreadForNewsContent:(id)newsContent;
@end

@interface SNNewsImageFetcher : NSObject {
    id __weak _delegate;
}

@property(nonatomic, weak)id delegate;

+ (SNNewsImageFetcher *)sharedInstance;

- (void)fetchRollingNewsImagesInThread:(NSArray *)imageURLStringArray;
- (void)fetchImagesInThread:(NSArray *)imageURLStringArray forNewsContent:(id)newsContent;

@end
