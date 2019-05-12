//
//  SNLiveRoomRollAdModel.h
//  sohunews
//
//  Created by lijian on 15-4-4.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNLiveRoomRollAdModelDelegate <NSObject>

@optional
- (void)liveRoomRollAdShouldThrowAdvertising:(NSArray *)array maxNumber:(NSUInteger)maxNum;
- (void)liveRoomRollAdShouldAddAdvertising:(NSArray *)array loadNum:(NSInteger)num;
- (void)liveRoomRollAdShouldInsertFirstLoadAdvertising:(NSArray *)array;

- (void)liveRoomRollAdDidFinishLoad;
- (void)liveRoomRollAdDidFailLoadWithError:(NSError *)error;
- (void)liveRoomRollAdDidCancelLoad;

@end

@interface SNLiveRoomRollAdModel : NSObject<TTURLRequestDelegate>

@property (nonatomic, copy) NSString *liveId;
@property (nonatomic, weak)id<SNLiveRoomRollAdModelDelegate> delegate;
@property (nonatomic, assign) BOOL isLoadMore;
@property (nonatomic, assign) NSInteger loadNum;
@property (nonatomic, assign) long long searchContentID;
@property (nonatomic, assign) BOOL isFirstLoad;


- (id)initWithLiveId:(NSString *)liveId;
- (void)requestAdvertising;

@end
