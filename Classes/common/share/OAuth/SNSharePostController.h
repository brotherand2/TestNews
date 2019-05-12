//
//  SNSharePostController.h
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNShareManager.h"
#import "SNAlert.h"


@class SNTextView;

@interface SNSharePostController : SNBaseViewController<SNShareManagerDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, SNShareListDelegate,SNActionSheetDelegate> {
    SNAlert *_confirmAlertView;
    UIView *_contentHeaderView;
    SNTextView *_contentTextView;
    UILabel *_contentLengthView;
    UITableView *_sharelistTableView;
    UILabel *_tipLabel;
    UIButton *_refreshShareListMaskButton; // 没有分享列表的话，重新刷新
    
    int _width;
    int _height;
    NSInteger _canInputCount;

    NSArray *_shareListItems;
}

@property(nonatomic, strong)SNAlert *confirmAlertView;
@property(nonatomic, assign) BOOL bPresentFromWindowDelegate;
@property(nonatomic, copy)NSString *content;
@property(nonatomic, strong)NSString *shareComment;
@property(nonatomic, assign)SNShareContentType shareType;
@property(nonatomic, copy)NSString *imageUrl;
@property(nonatomic, copy)NSString *imagePath;
@property(nonatomic, copy)NSString *newsId;
@property(nonatomic, copy)NSString *groupId;

@property(nonatomic, weak)id delegate;
@property(nonatomic, assign)BOOL isDismissing;

@property(nonatomic, assign)BOOL isVideoShare;
@property(nonatomic, assign)BOOL isQianfanShare;
@property(nonatomic, assign)int sourceType;

+ (SNSharePostController *)sharePostControllerWithShareInfo:(NSDictionary *)shareInfo;

//virtual method
- (id)initWithShareInfo:(NSDictionary *)shareInfo;
- (void)creatView;
- (void)changeInputInfo;
- (void)hideKeyboard;

- (SNSharePostController *)initWithContent:(NSString *)content
                                  imageUrl:(NSString *)imageUrl
                                    newsId:(NSString *)newsId
                                   groupId:(NSString *)gid
                                 longitude:(long)longitude
                                  latitude:(long)latitude
                                  delegate:(id)delegate;


@end
