//
//  SNLocationManager.h
//  sohunews
//
//  Created by Diaochunmeng on 12-12-7.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@protocol SNLocationManagerDelegate <NSObject>
@optional
-(void)notifyLocation:(CGPoint)aLocation;
-(void)notifyFailWithError:(NSError*)aError;
-(void)notifyCanceled;
@end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@class CLLocationManager;
@interface SNLocationManager : NSObject<CLLocationManagerDelegate>
{
    BOOL _isLocating;
    CGPoint _Location;
    NSMutableArray* _listeners;
    CLLocationManager* _manager;
//    SNURLRequest* _request;
}

@property(nonatomic,assign) BOOL _isLocating;
@property(nonatomic,assign) CGPoint _Location;
@property(nonatomic,strong) NSMutableArray* _listeners;
@property(nonatomic,strong) CLLocationManager* _manager;
//@property(nonatomic,strong) SNURLRequest* _request;

+(SNLocationManager*)GetInstance;
-(void)addListener:(id<SNLocationManagerDelegate>)aListener;
-(void)removeListener:(id<SNLocationManagerDelegate>)aListener;

-(BOOL)isEnable;
-(BOOL)startLocating:(CGPoint*)aPt;
-(void)stopLocating;
-(BOOL)locationRequest;
@end
