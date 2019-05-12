//
//  SNSubShakingCenter.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-23.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

//#import <Three20Network/Three20Network.h>
#import "Three20Network.h"
@protocol SNSubShakingCenterDelegate <NSObject>
@optional
-(void)notifySubRecomSuccess;
-(void)notifySubRecomFailure;
-(void)notifySubRecomRequestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface SNSubShakingCenter : NSObject<TTURLRequestDelegate>
{
    SNURLRequest* _request;
    NSMutableArray* _SubArray;
    id<SNSubShakingCenterDelegate> __weak _SubShakingCenterDelegate;
}

@property(nonatomic,strong)SNURLRequest* _request;
@property(nonatomic,strong)NSMutableArray* _SubArray;
@property(nonatomic,weak)id<SNSubShakingCenterDelegate> _SubShakingCenterDelegate;

-(BOOL)subRecomRequest;
-(BOOL)clearDataAndRequest;
-(void)clearRequestAndDelegate;
@end
