//
//  SNLiveRoomBaseCell.h
//  sohunews
//
//  Created by Chen Hong on 4/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLabel.h"
#import "SNLiveRoomTableViewController.h"
#import "SNTableViewCell.h"

@class SNLiveRoomBaseObject;

@interface SNLiveRoomBaseCell : SNTableViewCell<SNLabelDelegate> {
    SNLiveRoomBaseObject *_object;
    SNLiveRoomTableViewController *__weak _tableViewController;
}

@property(nonatomic,strong)SNLiveRoomBaseObject *object;
@property(nonatomic,weak)SNLiveRoomTableViewController *tableViewController;

@end
