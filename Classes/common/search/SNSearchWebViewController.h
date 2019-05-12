//
//  SNSearchWebViewController.h
//  sohunews
//
//  Created by tt on 15/4/19.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//



typedef enum {
    SNSearchReferDefault,   //默认
    SNSearchReferHomePage,  //首页
    SNSearchReferChannel,    //频道管理
    SNSearchReferArticle,    //正文蓝词
    SNSearchReferHotSearch = 6,//热词搜索
    SNSearchReferChannelMannagerBottomSearch = 7,//频道列表最下方的搜索入口
    SNSearchReferNovel = 8,    //小说
} SNSearchRefertype;


@protocol SNSearcbBarDelegate <NSObject>

- (void)searchBarEndSearch;

- (void)searchWebViewLoadView;

@end

@interface SNSearchWebViewController : SNBaseViewController

@property (strong, nonatomic, readonly) IBOutlet UITextField *textField;
@property (nonatomic, weak) id<SNSearcbBarDelegate> searchBarDelegate;
@property (nonatomic, assign) BOOL homeSearch;
@property (nonatomic, assign) int refertype;
@property (nonatomic, assign) int oldRefertype;
@property (nonatomic, assign) BOOL noAutoCorrection;//自动纠错功能

/**
 *  搜索
 *
 *  @param searchText     关键词
 *  @param autoCorrection 是否进行自动校正
 */
- (void)search:(NSString *)searchText;
- (void)toClearAllHistoryAction;
- (void)searchNoAutoCorrection:(NSString *)searchText;
- (void)beginSearchAndreloadHotWords;

- (NSString *)jsGetSearchHotWord;
- (void)jsSetSearchWord:(NSString *)keyWrods;
- (void)directSearch:(NSString *)keyWrods;
@end
