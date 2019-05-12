//
//  SNDownloadSettingViewController.h
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//


#import "SNChannelModel.h"
#import "SNDownloadSettingSectionHeaderView.h"

#define kDownloadSettingTableViewInsetTop                               (58)
#define kDownloadSettingTableViewInsetBottom                            (54)

#define kDownloadSettingSubSectionDataTag                               (@"kDownloadSettingSubSectionDataTag")
#define kDownloadSettingNewsSectionDataTag                              (@"kDownloadSettingNewsSectionDataTag")

typedef enum {
    SNDownloadSettingCellOrder_Unknown = -1,
    SNDownloadSettingCellOrder_OnlyOne = 0,
    SNDownloadSettingCellOrder_First = 1,
    SNDownloadSettingCellOrder_Middle = 2,
    SNDownloadSettingCellOrder_Last = 3
} SNDownloadSettingCellOrder;

@interface SNDownloadSettingViewController : SNBaseViewController<UITableViewDataSource, UITableViewDelegate> {
    id _referfrom;
    NSString* _selectedWhenEnter;
    
    SNChannelModel *_channelModel;
    
    UITableView *_tableView;
    NSArray *_toBeDownloadedItems; //二维数组:第一个元素是待下载的刊物，第二个元素是待下载的频道;
    NSMutableArray *_toBeDownloadedItemsRow; //一维数组，上面数组合并
    
    SNDownloadSettingSectionHeaderView *_subSectionHeaderView;
    //SNDownloadSettingSectionHeaderView *_newsSectionHeaderView;
}
@end
