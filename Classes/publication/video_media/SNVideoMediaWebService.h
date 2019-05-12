//
//  SNVideoMediaWebService.h
//  sohunews
//
//  Created by handy wang on 12/7/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNVideoMediaWebService : NSObject
@property (nonatomic, weak)id delegate;
@property (nonatomic, strong)NSURL *url;
@property (nonatomic, strong)NSDictionary *userInfo;
@property (nonatomic, assign)BOOL isLoading;

- (void)loadAsynchronously;
- (void)cancel;
@end

@protocol SNVideoMediaWebServiceDelegate
- (void)didStartLoad;
- (void)didFinishedLoad:(NSString *)htmlData request:(ASIHTTPRequest *)request;
- (void)didFailedLoad;
@end
