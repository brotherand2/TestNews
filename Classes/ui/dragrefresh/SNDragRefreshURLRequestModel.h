//
//  SNDragRefreshURLRequestModel.h
//  sohunews
//
//  Created by Dan on 8/23/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDragRefreshTableViewController.h"
#import "SNAppStateManager.h"

@interface SNDragRefreshURLRequestModel : TTURLRequestModel {
    BOOL isRefreshManually;
    BOOL isRefreshFromDrag;
}

@property (nonatomic, assign) BOOL isRefreshManually;
@property (nonatomic, assign) BOOL isRefreshFromDrag;
@property (nonatomic, strong) NSDate *refreshedTime;

@end
