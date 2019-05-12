//
//  SNLocationManager.m
//  sohunews
//
//  Created by Diaochunmeng on 12-12-7.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLocationManager.h"
#import "SNLocationRequest.h"
@interface SNLocationManager ()
@property (nonatomic, strong) SNLocationRequest *localRequest;
@end

static SNLocationManager* g_LocationManager;


@implementation SNLocationManager
@synthesize _Location;
@synthesize _isLocating;
@synthesize _listeners;
@synthesize _manager;
//@synthesize _request;

//----------------------------------------------------------------------------------------------
//------------------------------------------- 系统回调 -------------------------------------------
//----------------------------------------------------------------------------------------------

+(SNLocationManager*)GetInstance
{
	if(g_LocationManager==nil)
	{
		g_LocationManager = [[SNLocationManager alloc]init];
	}
	return g_LocationManager;
}

-(void)dealloc
{
    if(self._listeners!=nil)
    {
//        [self._request cancel];
        [self._listeners removeAllObjects];
        [self._manager stopUpdatingLocation];
    }
}

-(id)init
{
    if(self=[super init])
    {
        _Location.x = 0.0f;
        _Location.y = 0.0f;
        self._listeners = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

-(void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
    self._isLocating = NO;
    [self._manager stopUpdatingLocation];
    
	if(newLocation.horizontalAccuracy>=0)
	{
        CLLocationCoordinate2D coord = [_manager.location coordinate];
        _Location.x = coord.latitude;
        _Location.y = coord.longitude;
        SNDebugLog(@"CLLocationManagerDelegate didUpdateToLocation %f %f", _Location.x, _Location.y);
        
        //上报地理位置信息
        [self locationRequest];
        
        if(self._listeners!=nil && [self._listeners count]>0)
        {
            for(NSInteger i=0; i<[self._listeners count]; i++)
            {
                id<SNLocationManagerDelegate> listener = (id<SNLocationManagerDelegate>)[self._listeners objectAtIndex:i];
                if([listener respondsToSelector:@selector(notifyLocation:)])
                    [listener notifyLocation:_Location];
            }
        }
	}
    else
    {
        NSError* error = [NSError errorWithDomain:@"locationManager.horizontalAccuracy<0" code:0 userInfo:nil];
        SNDebugLog(@"CLLocationManagerDelegate didUpdateToLocation error %@", error.description);
        
        for(NSInteger i=0; i<[self._listeners count]; i++)
        {
            id<SNLocationManagerDelegate> listener = (id<SNLocationManagerDelegate>)[self._listeners objectAtIndex:i];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if([listener respondsToSelector:@selector(notifyFailWithError)])
                [listener notifyFailWithError:error];
#pragma clang diagnostic pop
        }
	}
}

-(void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
	SNDebugLog(@"定位错误: %@",[error localizedDescription]);
    
    self._isLocating = NO;
	[_manager stopUpdatingLocation];
    
    for(NSInteger i=0; i<[self._listeners count]; i++)
    {
        id<SNLocationManagerDelegate> listener = (id<SNLocationManagerDelegate>)[self._listeners objectAtIndex:i];
        if([listener respondsToSelector:@selector(notifyFailWithError:)])
            [listener notifyFailWithError:error];
    }
}


-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager*)manager
{
    SNDebugLog(@"locationManagerDidPauseLocationUpdates");
}


//----------------------------------------------------------------------------------------------
//------------------------------------------- 用户接口 -------------------------------------------
//----------------------------------------------------------------------------------------------


-(void)addListener:(id<SNLocationManagerDelegate>)aListener
{
    if(aListener!=nil)
    {
        [self._listeners removeObject:aListener];
        [self._listeners addObject:aListener];
    }
}

-(void)removeListener:(id<SNLocationManagerDelegate>)aListener
{
    if(aListener!=nil)
        [self._listeners removeObject:aListener];
}

-(BOOL)isEnable
{
    return [CLLocationManager locationServicesEnabled];
}

-(BOOL)startLocating:(CGPoint*)aPt
{
    if([CLLocationManager locationServicesEnabled])
    {
        if(!_isLocating)
        {
            self._isLocating = YES;
            
            //定位功能开启的情况下进行定位
            if(self._manager == nil)
                _manager = [[CLLocationManager alloc] init];
            self._manager.distanceFilter = kCLDistanceFilterNone;
            self._manager.desiredAccuracy = kCLLocationAccuracyBest;
            self._manager.delegate = self;
            [self._manager stopUpdatingLocation];
            [self._manager startUpdatingLocation];
        }
        
        //CLLocationManager is enable
        *aPt = self._Location;
        return YES;
    }
    else
        return NO;
}

-(void)stopLocating
{
    if(_isLocating)
    {
        self._isLocating = NO;
        [self._manager stopUpdatingLocation];

        for(NSInteger i=0; i<[self._listeners count]; i++)
        {
            id<SNLocationManagerDelegate> listener = (id<SNLocationManagerDelegate>)[self._listeners objectAtIndex:i];
            if([listener respondsToSelector:@selector(notifyCanceled)])
                [listener notifyCanceled];
        }
    }
}

-(BOOL)locationRequest
{
    if(self._Location.x==0.0f || self._Location.y==0.0f) return NO;
    
    if (self.localRequest) {
        return NO;
    } else {
        self.localRequest = [[SNLocationRequest alloc] initWithLocation:_Location];
        __weak typeof(self)weakself = self;
        [self.localRequest send:^(SNBaseRequest *request, id responseObject) {
            weakself.localRequest = nil;
            SNDebugLog(@"%@",responseObject);
        } failure:^(SNBaseRequest *request, NSError *error) {
            weakself.localRequest = nil;
            SNDebugLog(@"%@",error.localizedDescription);
        }];
        return YES;
    }
}
@end
