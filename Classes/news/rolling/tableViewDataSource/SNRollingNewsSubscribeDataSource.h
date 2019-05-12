//
//  SNRollingNewsSubscribeDataSource.h
//  sohunews
//
//  Created by lhp on 10/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNNewsDataSource.h"
#import "SNSubscribeNewsModel.h"
#import "SNMyConcernViewController.h"

@interface SNRollingNewsSubscribeDataSource : SNNewsDataSource {
    
}

@property(nonatomic, strong)SNSubscribeNewsModel *newsModel;
@property(nonatomic, weak) SNMyConcernViewController *myConcernController;

- (id)initWithChannelId:(NSString *)channelId;

@end
