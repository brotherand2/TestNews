//
//  SNGetRequestMonitor.h
//  sohunews
//
//  Created by WongHandy on 8/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNGetRequestMonitorKPI : NSObject
@property(nonatomic, assign) NSTimeInterval dnsResolveTimeCost;
@property(nonatomic, assign) NSTimeInterval conectTimeCost;
@property(nonatomic, assign) NSTimeInterval requestTimeCost;
@property(nonatomic, assign) NSTimeInterval responseTimeCost;
@property(nonatomic, assign) NSTimeInterval receiveDataTimeCost;
@property(nonatomic, copy) NSString *urlString;
@property(nonatomic, assign) NSInteger responseDataLengthInBytes;
@property(nonatomic, assign) NSInteger responseStatusCode;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SNGetRequestMonitor : NSObject
@property(nonatomic, strong, readonly) NSURL *url;
@property(nonatomic, strong, readonly) SNGetRequestMonitorKPI *kpi;

- (id)initWithURL:(NSURL *)url;
- (BOOL)start;
@end
