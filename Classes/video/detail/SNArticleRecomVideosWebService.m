//
//  SNArticleRecomVideosWebService.m
//  sohunews
//
//  Created by handy wang on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNArticleRecomVideosWebService.h"
#import "SNVideoObjects.h"
#import "SNVideoConst.h"
#import "SNVideoRecomRequest.h"

@interface SNArticleRecomVideosWebService()
@property (nonatomic, strong)SNASIRequest *request;
@end

@implementation SNArticleRecomVideosWebService

#pragma mark - Lifecycle
- (void)dealloc {
    [self.request clearDelegatesAndCancel];
    
}


#pragma mark - Public

- (void)startAsynchrously {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setValue:self.newsId forKey:@"newsId"];
    [params setValue:self.channelId forKey:@"channelId"];
    [params setValue:self.subId forKey:@"subId"];
    [[[SNVideoRecomRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try {
                NSMutableArray *___recommendVideos = [NSMutableArray array];
                
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    id _data = [responseObject objectForKey:@"data"];
                    if ([_data isKindOfClass:[NSArray class]]) {
                        NSArray *_recommendVideoDicArray = (NSArray *)_data;
                        
                        for (NSDictionary *_recommendVideoDic in _recommendVideoDicArray) {
                            SNVideoData *_videoModel            = [[SNVideoData alloc] init];
                            _videoModel.title                   = [_recommendVideoDic stringValueForKey:@"title" defaultValue:@""];
                            _videoModel.subtitle                = nil;
                            _videoModel.vid                     = [_recommendVideoDic stringValueForKey:@"vid" defaultValue:@""];
                            _videoModel.poster                  = [_recommendVideoDic stringValueForKey:@"pic" defaultValue:@""];
                            _videoModel.playType                = [_recommendVideoDic intValueForKey:@"playType" defaultValue:0];//如果是WSMVVideoPlayType_HTML5表明版权有问题只能在HTML中播放
                            _videoModel.downloadType            = [_recommendVideoDic intValueForKey:@"download" defaultValue:0];
                            _videoModel.wapUrl                  = [_recommendVideoDic stringValueForKey:@"url" defaultValue:@""];
                            _videoModel.share                   = [[SNVideoShare alloc] init];
                            _videoModel.share.content           = [_recommendVideoDic stringValueForKey:@"shareContent" defaultValue:@""];
                            _videoModel.share.h5Url             = [_recommendVideoDic stringValueForKey:@"h5Url" defaultValue:@""];
                            
                            _videoModel.siteInfo                = [[SNVideoSiteInfo alloc] init];
                            _videoModel.siteInfo.site           = [_recommendVideoDic stringValueForKey:SNVideoConst_kSite defaultValue:@""];
                            _videoModel.siteInfo.site2          = [_recommendVideoDic stringValueForKey:SNVideoConst_kSite2 defaultValue:@""];
                            _videoModel.siteInfo.siteName       = [_recommendVideoDic stringValueForKey:SNVideoConst_kSiteName defaultValue:@""];
                            _videoModel.siteInfo.siteId         = [_recommendVideoDic stringValueForKey:SNVideoConst_kSiteId defaultValue:@""];
                            _videoModel.siteInfo.playById       = [_recommendVideoDic stringValueForKey:SNVideoConst_kPlayById defaultValue:@""];
                            _videoModel.siteInfo.playAd         = [_recommendVideoDic stringValueForKey:SNVideoConst_kPlayAd defaultValue:@""];
                            _videoModel.siteInfo.adServer       = [_recommendVideoDic stringValueForKey:SNVideoConst_kAdServer defaultValue:@""];
                            
                            id _playURL = [_recommendVideoDic objectForKey:@"playUrl" defalutObj:nil];
                            if ([_playURL isKindOfClass:[NSDictionary class]]) {
                                NSString *_m3u8Source = [_playURL stringValueForKey:@"m3u8" defaultValue:@""];
                                NSArray  *_mp4sSource = [_playURL arrayValueForKey:@"mp4s" defaultValue:nil];
                                NSString *_mp4Source = [_playURL stringValueForKey:@"mp4" defaultValue:@""];
                                if (_m3u8Source.length > 0) {
                                    _videoModel.sources = [NSMutableArray arrayWithObject:_m3u8Source];
                                }
                                else if (_mp4sSource.count > 0) {
                                    _videoModel.sources = [_mp4sSource mutableCopy];
                                }
                                else if (_mp4Source.length > 0) {
                                    _videoModel.sources = [NSMutableArray arrayWithObject:_mp4Source];
                                }
                            }
                            [___recommendVideos addObject:_videoModel];
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecommendVideos:)]) {
                        [self.delegate didFinishLoadRecommendVideos:___recommendVideos];
                    }
                });
            } @catch (NSException *exception) {
                SNDebugLog(@"SNVideoRecomRequest exception reason--%@", exception.reason);
            } @finally {
                
            }
        });

    } failure:^(SNBaseRequest *request, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didFailLoadWithError:)]) {
            [self.delegate didFailLoadWithError:error];
        }
    }];
}

- (void)cancel {
    self.delegate = nil;
    [self.request clearDelegatesAndCancel];
    self.request = nil;
}

//#pragma mark - ASIHTTPRequestDelegate
//- (void)requestFinished:(ASIHTTPRequest *)request {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableArray *___recommendVideos = [NSMutableArray array];
//        
//        NSString *_responseString = request.responseString;
//        SNDebugLog(@"Response string \n %@ \n from %@", _responseString, request.url.absoluteString);
//        
//        id _rootData = [NSJSONSerialization JSONObjectWithString:_responseString
//                                                         options:NSJSONReadingMutableLeaves
//                                                           error:NULL];
//        
//        if ([_rootData isKindOfClass:[NSDictionary class]]) {
//            id _data = [_rootData objectForKey:@"data"];
//            if ([_data isKindOfClass:[NSArray class]]) {
//                NSArray *_recommendVideoDicArray = (NSArray *)_data;
//                
//                for (NSDictionary *_recommendVideoDic in _recommendVideoDicArray) {
//                    SNVideoData *_videoModel            = [[SNVideoData alloc] init];
//                    _videoModel.title                   = [_recommendVideoDic stringValueForKey:@"title" defaultValue:@""];
//                    _videoModel.subtitle                = nil;
//                    _videoModel.vid                     = [_recommendVideoDic stringValueForKey:@"vid" defaultValue:@""];
//                    _videoModel.poster                  = [_recommendVideoDic stringValueForKey:@"pic" defaultValue:@""];
//                    _videoModel.playType                = [_recommendVideoDic intValueForKey:@"playType" defaultValue:0];//如果是WSMVVideoPlayType_HTML5表明版权有问题只能在HTML中播放
//                    _videoModel.downloadType            = [_recommendVideoDic intValueForKey:@"download" defaultValue:0];
//                    _videoModel.wapUrl                  = [_recommendVideoDic stringValueForKey:@"url" defaultValue:@""];
//                    _videoModel.share                   = [[SNVideoShare alloc] init];
//                    _videoModel.share.content           = [_recommendVideoDic stringValueForKey:@"shareContent" defaultValue:@""];
//                    _videoModel.share.h5Url             = [_recommendVideoDic stringValueForKey:@"h5Url" defaultValue:@""];
//                    
//                    _videoModel.siteInfo                = [[SNVideoSiteInfo alloc] init];
//                    _videoModel.siteInfo.site           = [_recommendVideoDic stringValueForKey:SNVideoConst_kSite defaultValue:@""];
//                    _videoModel.siteInfo.site2          = [_recommendVideoDic stringValueForKey:SNVideoConst_kSite2 defaultValue:@""];
//                    _videoModel.siteInfo.siteName       = [_recommendVideoDic stringValueForKey:SNVideoConst_kSiteName defaultValue:@""];
//                    _videoModel.siteInfo.siteId         = [_recommendVideoDic stringValueForKey:SNVideoConst_kSiteId defaultValue:@""];
//                    _videoModel.siteInfo.playById       = [_recommendVideoDic stringValueForKey:SNVideoConst_kPlayById defaultValue:@""];
//                    _videoModel.siteInfo.playAd         = [_recommendVideoDic stringValueForKey:SNVideoConst_kPlayAd defaultValue:@""];
//                    _videoModel.siteInfo.adServer       = [_recommendVideoDic stringValueForKey:SNVideoConst_kAdServer defaultValue:@""];
//                    
//                    id _playURL = [_recommendVideoDic objectForKey:@"playUrl" defalutObj:nil];
//                    if ([_playURL isKindOfClass:[NSDictionary class]]) {
//                        NSString *_m3u8Source = [_playURL stringValueForKey:@"m3u8" defaultValue:@""];
//                        NSArray  *_mp4sSource = [_playURL arrayValueForKey:@"mp4s" defaultValue:nil];
//                        NSString *_mp4Source = [_playURL stringValueForKey:@"mp4" defaultValue:@""];
//                        if (_m3u8Source.length > 0) {
//                            _videoModel.sources = [NSMutableArray arrayWithObject:_m3u8Source];
//                        }
//                        else if (_mp4sSource.count > 0) {
//                            _videoModel.sources = [_mp4sSource mutableCopy];
//                        }
//                        else if (_mp4Source.length > 0) {
//                            _videoModel.sources = [NSMutableArray arrayWithObject:_mp4Source];
//                        }
//                    }
//                    [___recommendVideos addObject:_videoModel];
//                }
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([self.delegate respondsToSelector:@selector(didFinishLoadRecommendVideos:)]) {
//                [self.delegate didFinishLoadRecommendVideos:___recommendVideos];
//            }
//            
//            self.request.delegate = nil;
//            self.request = nil;
//        });
//    });
//}
//
//- (void)requestFailed:(ASIHTTPRequest *)request {
//    SNDebugLog(@"Failed to load article recommend videos with comming msg: %@", [request.error localizedDescription]);
//    
//    if ([self.delegate respondsToSelector:@selector(didFailLoadWithError:)]) {
//        [self.delegate didFailLoadWithError:request.error];
//    }
//    
//    self.request.delegate = nil;
//    self.request = nil;
//}
//
@end
