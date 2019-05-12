//
//  SNLiveRoomTableViewController.h
//  sohunews
//
//  Created by chenhong on 13-4-19.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNThemeViewController.h"
#import "SNLiveRoomModel.h"
#import "FGalleryPhotoView.h"
#import "SNLiveRoomRollAdModel.h"

@class SNLiveCommentItem;
@class LivingGameItem;
@class SNLiveRoomViewController;

typedef enum {
    LIVE_MODE = 0,
    CHAT_MODE
}SNLiveContentViewMode;

@interface SNLiveRoomTableViewController : SNThemeViewController<UITableViewDataSource,UITableViewDelegate,SNLiveRoomModelDelegate,SNLiveRoomRollAdModelDelegate> {
    UITableView *_tableView;
    
    SNLiveRoomViewController *__weak _parentController;
    
    SNLiveContentMatchInfoObject *_infoObject;

}

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)LivingGameItem *livingGameItem;
@property(nonatomic, weak)SNLiveRoomViewController *parentController;
@property(nonatomic, strong)SNLiveContentMatchInfoObject *infoObject;

- (id)initWithMatchInfoObj:(SNLiveContentMatchInfoObject *)infoObj livingGameItem:(LivingGameItem *)gameItem mode:(SNLiveContentViewMode)mode;

- (void)showImageWithUrl:(NSString *)urlPath;

- (void)reloadRowByContentObj:(id)obj;

- (void)didEndDisplayingCell:(UITableViewCell *)cell;

- (void)destroyTimer;

- (void)addTableHeader:(float)height;

- (void)removeTableHeader;

@end
