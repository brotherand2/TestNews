//
//  SNLocalChannelServicer.h
//  sohunews
//
//  Created by lhp on 3/27/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SNURLRequest.h"

@protocol SNLocalChannelServicerDelegate <NSObject>

- (void)requestDidFinishLoad;

@end

@interface SNLocalChannelService : NSObject {
    
    NSMutableArray *localChannels;
    NSMutableArray *searchedChannels;
    NSMutableDictionary *letterChannels; //按字母存储频道
    NSString *keyWord;
//    SNURLRequest *localRequest;
    id<SNLocalChannelServicerDelegate> __weak delegate;
}
@property(nonatomic,strong)NSMutableArray *localChannels;
@property(nonatomic,strong)NSMutableArray *originChannelArray;
@property(nonatomic,strong)NSMutableArray *searchedChannels;
@property(nonatomic,strong)NSMutableDictionary *letterChannels;
@property(nonatomic,strong)NSString *keyWord;
@property(nonatomic,weak)id<SNLocalChannelServicerDelegate> delegate;

- (void)sendGetChannelRequest:(NSString *)channelId;
- (NSArray *)titleArray;
- (NSArray *)titleSectionArray;

@end
