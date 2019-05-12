//
//  SNCircleUserCenterEditViewContronller.h
//  sohunews
//
//  Created by Diaochunmeng on 13-7-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSettingCellWithTextOnly.h"
#import "SNCitySelectorController.h"
#import "SNUserAccountManageView.h"
#import "SNUserinfoService.h"
#import "SNActivityIndicatorView.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface SNCircleUserCenterEditViewContronller : SNBaseViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,                               UINavigationControllerDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,
    SNUserinfoServiceUpdateUserinfoDelegate,SNUserinfoServicePostHeaderDelegate, SNCitySelectorControllerDelegate, SNUserAccountManageDelegate>
{
    UIImage*        _image;
    NSArray*        _dataArray;
    UITableView*    _tableView;
    //上传背景框
    UIImageView*    _uploadView;
    //Items
    
    SNWebImageView* _headerImage;
    UITextField*    _userNameLabel;
    UILabel*        _genderLabel;
    UILabel*        _locationLabel;
    UILabel *_mobileBindLabel;
    SNUserinfoService* _model;
    SNUserinfoEx*   _pendingUserinfo;
    UIView *_maskViewForHeaderImage;
    SNActivityIndicatorView *_activityIndicatorView;
}

@property(nonatomic,strong)UIImage* image;
@property(nonatomic,strong)NSArray* dataArray;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)SNUserinfoService* model;
//上传背景框
@property(nonatomic,strong)UIImageView* uploadView;

-(id)initWithModel:(id)aModel;
//-(void)createRowButton;
-(void)updateRowButton;
@end
