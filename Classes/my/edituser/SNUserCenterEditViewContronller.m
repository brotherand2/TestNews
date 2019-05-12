//
//  SNCircleUserCenterEditViewContronller.m
//  sohunews
//
//  Created by Diaochunmeng on 13-7-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//


#import "SNUserCenterEditViewContronller.h"
#import "SNStatusBarMessageCenter.h"
#import "SNDatabase.h"
#import "SNImagePickerController.h"
#import "SNUserManager.h"
#import "SNUserinfoMediaObject.h"
#import "SNBindMobileNumViewController.h"

#import "SNRollingNewsPublicManager.h"

#define USERCENTER_EDIT_TAG_HEAD            (101)
#define USERCENTER_EDIT_TAG_USERNAME        (102)
#define USERCENTER_EDIT_TAG_BASEINFO        (103)
#define USERCENTER_EDIT_TAG_GROUP1          (104)
#define USERCENTER_EDIT_TAG_GROUP2          (105)
#define USERCENTER_EDIT_TAG_GROUP3          (106)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation SNCircleUserCenterEditViewContronller
@synthesize model = _model;
@synthesize tableView = _tableView;
@synthesize dataArray = _dataArray;
@synthesize image = _image;
@synthesize uploadView = _uploadView;

- (SNCCPVPage)currentPage {
    return profile_user_edit;
}

-(void)dealloc
{
     //(_model);
     //(_tableView);
     //(_dataArray);
     //(_image);
     //(_uploadView);
    
    //Items
     //(_headerImage);
     //(_userNameLabel);
     //(_genderLabel);
     //(_locationLabel);
     //(_mobileBindLabel);
     //(_pendingUserinfo);
     //(_activityIndicatorView);
    
    _model.updateUserinfoDelegate = nil;
    _model.postHeaderDelegate = nil;
}

-(id)initWithModel:(id)aModel
{
    self = [super init];
    if(self)
    {
        self.model = aModel;
        _pendingUserinfo = [[SNUserinfoEx alloc] init];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    [self addToolbar];
    
    [self addHeaderView];
    NSString *title = @"账号管理";
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setSections:[NSArray arrayWithObjects:title, nil]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kHeaderTotalHeight, kAppScreenWidth, kAppScreenHeight-kToolbarHeight-kHeaderTotalHeight) style:UITableViewStylePlain];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator= NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [self.view addSubview:_tableView];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
        
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    tap.delegate = self;
    [self.tableView addGestureRecognizer:tap];
    
    [self createSubView];
    [self createUploadView];
    [self updateTheme];
    [self addSwipeGesture];
}

-(void)viewDidUnload
{
     //(_tableView);
     //(_image);
     //(_uploadView);
    
    //Items
     //(_headerImage);
     //(_userNameLabel);
     //(_genderLabel);
     //(_locationLabel);
     //(_mobileBindLabel);
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _model.updateUserinfoDelegate = self;
    _model.postHeaderDelegate = self;
    [self updateRowButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    _model.updateUserinfoDelegate = nil;
//    _model.postHeaderDelegate = nil;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Row button
/*
-(void)createRowButton
{
     //(_headerImage);
    _headerImage = [[SNWebImageView alloc] initWithFrame:CGRectZero];
    _headerImage.userInteractionEnabled = NO;
    _headerImage.layer.masksToBounds   = YES;
    _headerImage.layer.cornerRadius = 2;
    _headerImage.showFade = NO;
    
    SNUserAccountManageView* view = [[SNUserAccountManageView alloc] initWithFrame:CGRectMake(11, 0, kAppScreenWidth-22, 0)];
    view.tag = USERCENTER_EDIT_TAG_GROUP1;
    [view addItemImage:_headerImage text:@"上传头像"];
    view.delegate = self;
    
    UITableViewCell* cell1 = [[UITableViewCell alloc] initWithFrame:view.frame];
    cell1.backgroundColor = [UIColor clearColor];
    cell1.selectionStyle = UITableViewCellSelectionStyleNone;
    cell1.frame = view.frame;
    [cell1 addSubview:view];
    [view release];
    
    //信息修改
     //(_userNameLabel);
    _userNameLabel= [[UITextField alloc] initWithFrame:CGRectZero];
    _userNameLabel.delegate = self;
     //(_genderLabel);
    _genderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
     //(_locationLabel);
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
     //(_mobileBindLabel);
    _mobileBindLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    //Info
    SNUserAccountManageView* view2 = [[SNUserAccountManageView alloc] initWithFrame:CGRectMake(11, 5, kAppScreenWidth-22, 0)];
    view2.tag = USERCENTER_EDIT_TAG_GROUP2;
    [view2 addItemTextField:_userNameLabel leftText:@"昵称"];
    [view2 addItemLeftRightText:@"性别" rightText:_genderLabel];
    [view2 addItemLeftRightText:@"所在地" rightText:_locationLabel];
    [view2 addItemLeftRightText:@"手机绑定" rightText:_mobileBindLabel];
    view2.delegate = self;
    
    
    UITableViewCell* cell2 = [[UITableViewCell alloc] initWithFrame:view2.frame];
    cell2.backgroundColor = [UIColor clearColor];
    cell2.selectionStyle = UITableViewCellSelectionStyleNone;
    cell2.frame = view2.frame;
    [cell2 addSubview:view2];
    [view2 release];
    
    self.dataArray = [NSArray arrayWithObjects:cell1, cell2, nil];
    [cell1 release];
    [cell2 release];
}
*/
-(void)createSubView
{
    int height = kHeaderTotalHeight;
    
     //(_headerImage);
    _headerImage = [[SNWebImageView alloc] initWithFrame:CGRectZero];
    _headerImage.userInteractionEnabled = NO;
    _headerImage.layer.masksToBounds   = YES;
    _headerImage.layer.cornerRadius = 2;
    _headerImage.showFade = NO;
//    _headerImage.alpha = themeImageAlphaValue();
    _maskViewForHeaderImage = [SNUtility addMaskForImageViewWithRadius:27 width:54 height:54];
    [_headerImage addSubview:_maskViewForHeaderImage];
    
    SNUserAccountManageView* view = [[SNUserAccountManageView alloc] initWithFrame:CGRectMake(0, height, kAppScreenWidth, 82)];
    view.tag = USERCENTER_EDIT_TAG_GROUP1;
    [view addItemImage:_headerImage text:@"上传头像"];
    view.delegate = self;
    [view drawSeperateLine:CGRectMake(82, 81.5, kAppScreenWidth-82, 0.5)];
    [self.view addSubview:view];
    
    _activityIndicatorView = [[SNActivityIndicatorView alloc] init];
    _activityIndicatorView.frame = CGRectMake(268, 32.5, 20, 20);
    if ([SNThemeManager sharedThemeManager].isNightTheme) {
        _activityIndicatorView.color = [UIColor grayColor];
    }
    else {
        _activityIndicatorView.color = [UIColor lightGrayColor];
    }
    
    [view addSubview:_activityIndicatorView];
    _activityIndicatorView.hidden = YES;
    
    height += 82;
    
    //信息修改
     //(_userNameLabel);
    _userNameLabel= [[UITextField alloc] initWithFrame:CGRectZero];
    _userNameLabel.delegate = self;
     //(_genderLabel);
    _genderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
     //(_locationLabel);
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
     //(_mobileBindLabel);
    _mobileBindLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    //Info
    SNUserAccountManageView* view2 = [[SNUserAccountManageView alloc] initWithFrame:CGRectMake(0, height, kAppScreenWidth, 231)];
    view2.tag = USERCENTER_EDIT_TAG_GROUP2;
    [view2 addItemTextField:_userNameLabel upText:@"昵称"];
    [view2 addItemUpDownText:@"性别" downText:_genderLabel];
    [view2 addItemUpDownText:@"所在地" downText:_locationLabel];
    [view2 addItemUpDownText:@"手机绑定" downText:_mobileBindLabel];
    view2.delegate = self;
    [self.view addSubview:view2];
    
    height += view2.frame.size.height+17;
    
    SNUserAccountManageView* view3 = [[SNUserAccountManageView alloc] initWithFrame:CGRectMake(0, height, kAppScreenWidth, 60)];
    view3.tag = USERCENTER_EDIT_TAG_GROUP3;
    [view3 drawSeperateLine:CGRectMake(82, 0.5, kAppScreenWidth-82, 0.5)];
    view3.delegate = self;
    SNUserinfoEx* userInfo = [SNUserinfoEx userinfoEx];
    if(!userInfo.isShowManage)
    {
        NSArray* mediaArray = [userInfo getPersonMediaObjects];
        if(mediaArray.count > 0)
        {
            [view3 addSingleItem:@"管理我的媒体帐号"];
        }
        else
        {
            if(userInfo.cmsRegUrl.length > 0)
            {
                [view3 addSingleItem:@"申请开通媒体帐号"];
            }
        }
    }
    [self.view addSubview:view3];
    
}

-(void)updateRowButton
{
    UIImage* defaultimage = nil;
    if([@"1" isEqualToString:_model.usrinfo.gender]) {
        defaultimage = [UIImage imageNamed:@"userinfo_default_headimage_man.png"];
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            _maskViewForHeaderImage.alpha = 0.7;
        }
        else {
            _maskViewForHeaderImage.alpha = 0;
        }
    }
    else if([@"2" isEqualToString:_model.usrinfo.gender]) {
        defaultimage = [UIImage imageNamed:@"userinfo_default_headimage_woman.png"];
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            _maskViewForHeaderImage.alpha = 0.7;
        }
        else {
            _maskViewForHeaderImage.alpha = 0;
        }
    }
    else {
        defaultimage = [UIImage imageNamed:@"bgseeme_defaultavatar_v5.png"];
        _maskViewForHeaderImage.alpha = 0;
    }
    _headerImage.defaultImage = defaultimage;
    _headerImage.urlPath = nil;
    if(_model!=nil && _model.usrinfo!=nil && (_model.usrinfo.tempHeader!=nil || [_model.usrinfo.headImageUrl length]>0)) {
        if(_model.usrinfo.tempHeader!=nil) {
            _headerImage.urlPath = nil;
            _headerImage.defaultImage = _model.usrinfo.tempHeader;
        }
        else {
            _headerImage.defaultImage = defaultimage;
            [_headerImage loadUrlPath:_model.usrinfo.headImageUrl];
            if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
                _maskViewForHeaderImage.alpha = 0.7;
            }
            else {
                _maskViewForHeaderImage.alpha = 0;
            }
        }
    }
    _userNameLabel.text = [_model.usrinfo getNickname];
    _genderLabel.text = [_model.usrinfo getGender];
    if ([_model.usrinfo getPlace].length == 0) {
        _locationLabel.text = @"请选择";
    }
    else {
        _locationLabel.text = [_model.usrinfo getPlace];
    }
    _mobileBindLabel.text = [_model.usrinfo getMobileNum];
    [_tableView reloadData];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SNUserAccountManageDelegate

- (void)tapUILabelIndex:(NSInteger)index tag:(NSInteger)aTag {
    if([_userNameLabel isFirstResponder])
    {
        [_userNameLabel resignFirstResponder];
        return;
    }
    
    if(aTag==USERCENTER_EDIT_TAG_GROUP1 && !_userNameLabel.isFirstResponder)
        [self uploadHeader];
    else if(aTag==USERCENTER_EDIT_TAG_GROUP2 && index==0)
        [self updateNick];
    else if(aTag==USERCENTER_EDIT_TAG_GROUP2 && index==1 && !_userNameLabel.isFirstResponder)
        [self updateGender];
    else if(aTag==USERCENTER_EDIT_TAG_GROUP2 && index==2 && !_userNameLabel.isFirstResponder)
        [self updatePlace];
    else if (aTag == USERCENTER_EDIT_TAG_GROUP2 && index == 3 && !_userNameLabel.isFirstResponder)
        [self updateMobileNum];
    else if (aTag==USERCENTER_EDIT_TAG_GROUP3)
        [self openMediaAccount];
}

-(void)openMediaAccount
{
    SNUserinfoEx* userinfoEx = [SNUserinfoEx userinfoEx];
    NSArray* mediaArray = [userinfoEx getPersonMediaObjects];
    if(!userinfoEx.isShowManage)
    {
        if(mediaArray.count == 0)
        {
            if(userinfoEx.cmsRegUrl.length > 0)
            {
                NSDictionary* dic  = [NSDictionary dictionaryWithObjectsAndKeys:userinfoEx.cmsRegUrl,@"address", nil];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        }
        else
        {
            SNUserinfoMediaObject* object = [mediaArray objectAtIndex:0];
            if(object && object.mediaLink)
            {
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:object.mediaLink, @"address",nil];
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://h5WebBrowser"] applyAnimated:YES] applyQuery:dic];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        }
    }

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Table

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row<[_dataArray count])
    {
        UITableViewCell* cell = (UITableViewCell*)[_dataArray objectAtIndex:indexPath.row];
        return cell.height;
    }
    else
        return 0;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row<[_dataArray count])
    {
        UITableViewCell* cell = (UITableViewCell*)[_dataArray objectAtIndex:indexPath.row];
        return cell;
    }
    else
        return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Tap Gesture
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    UITextField* nickTextField = _userNameLabel;
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] && ![nickTextField isFirstResponder])
        return NO;
    else if ([touch.view isKindOfClass:[UIButton class]] && ![nickTextField isFirstResponder])
        return NO;
    
    return YES;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//actionSheet
-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        if (buttonIndex ==2) {
            return;
        }
      
        NSInteger currentIndex = -1;
        if(_model!=nil && _model.usrinfo!=nil && _model.usrinfo.gender!=nil)
            currentIndex = [_model.usrinfo.gender intValue] - 1;
        
        if(buttonIndex>=0 && buttonIndex!=currentIndex)
        {
            NSString* sex = [NSString stringWithFormat:@"%ld", buttonIndex+1];
            [_pendingUserinfo resetUserinfo];
            _pendingUserinfo.gender = sex;
            if(_model!=nil && [SNUserManager getUserId]!=nil)
            {
                NSString* username = [SNUserManager getUserId];
                if(username!=nil && [_model updateUserInfo:username key:@"gender" value:sex key2:nil value2:nil])
                    [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
            }
        }
        return;
    }
    
    if(buttonIndex==0) //拍照
    {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        else
            [[SNStatusBarMessageCenter sharedInstance] setAlpha:0];
        
        SNImagePickerController* imagePicker = [[SNImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = YES;
        [[TTNavigator navigator].topViewController presentViewController:imagePicker animated:YES completion:nil];
    }
    else if(buttonIndex==1) //选取
    {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = YES;
        [[TTNavigator navigator].topViewController presentViewController:imagePicker animated:YES completion:nil];
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//网络回调

-(void)notifyUpdateUserinfoSuccess
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"保存成功!" toUrl:nil mode:SNCenterToastModeSuccess];
    
    [_model.usrinfo copyEditUserinfo:_pendingUserinfo];
    
    SNUserinfoEx* currentUser = [SNUserinfoEx userinfoEx];
    [currentUser copyEditUserinfo:_pendingUserinfo];
    [currentUser saveUserinfoToUserDefault];
    
    //updateHeader
    [self updateRowButton];
    //Update
    _userNameLabel.text = [_model.usrinfo getNickname];
    _genderLabel.text = [_model.usrinfo getGender];
//    _locationLabel.text = [_model.usrinfo getPlace];
    if ([_model.usrinfo getPlace].length != 0) {
        _locationLabel.text = [_model.usrinfo getPlace];
    }
    _mobileBindLabel.text = [_model.usrinfo getMobileNum];
    [_tableView reloadData];
}

-(void)notifyUpdateUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [SNNotificationCenter hideLoading];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
}
-(void)notifyUpdateUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    SNDebugLog(@"notifyUpdateUserinfoFailure");
    [SNNotificationCenter hideLoading];
    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
}

-(void)notifyPostHeaderSuccess:(NSString*)imageUrl
{
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = YES;
    _headerImage.defaultImage = self.image;
    _headerImage.urlPath = nil;
    
    //_model.usrinfo._tempHeader = self.image;
    _model.usrinfo.date = [NSDate date];
    _model.usrinfo.headImageUrl = imageUrl;
    
    SNUserinfoEx* currentUser = [SNUserinfoEx userinfoEx];
    currentUser.headImageUrl = imageUrl;
    [currentUser saveUserinfoToUserDefault];
    self.image = nil;
    
    [self performSelector:@selector(fadeOutLoadView) withObject:nil afterDelay:0.4f];
    [self performSelector:@selector(showMessage) withObject:nil afterDelay:0.4f];
}


-(void)notifyPostHeaderFailure:(NSInteger)aStatus msg:(NSString*)aMsg
{
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = YES;
    self.image = nil;
    [self performSelector:@selector(fadeOutLoadView) withObject:nil afterDelay:0.4f];
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:aMsg toUrl:nil mode:SNCenterToastModeWarning];
}

-(void)notifyPostHeaderFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = YES;
    self.image = nil;
    [self performSelector:@selector(fadeOutLoadView) withObject:nil afterDelay:0.4f];
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
}


//-(void)notifyGetUserinfoSuccess:(NSArray*)mediaArray
//{
//    [SNNotificationCenter hideLoading];
//    
//    //Save
//    _model._usrinfo._date = [NSDate date];
//    [_model saveCurrentUserinfoToUserDefaults];
//    
//    [self.tableView reloadData];
//}
//
//-(void)notifyGetUserinfoFailure:(NSInteger)aStatus msg:(NSString*)aMsg
//{
//    
//}
//
//-(void)notifyGetUserinfoFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
//{
//    
//}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Image picker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
    self.image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.image =[UIImage rotateImage:self.image];
    
    [self performSelector:@selector(saveImage:) withObject:_image afterDelay:0.3];
    [[SNStatusBarMessageCenter sharedInstance] setAlpha:1];
    
    [_activityIndicatorView startAnimating];
    _activityIndicatorView.hidden = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//City picker

-(void)notifyCitySelected:(NSString*)aCity province:(NSString*)aProvince
{
    if(aCity!=nil && [aCity length]>0 && aProvince!=nil && [aProvince length]>0)
    {
        NSString* province = @"";
        if(_model.usrinfo.province != nil)
            province = _model.usrinfo.province;
        NSString* city = @"";
        if(_model.usrinfo.city != nil)
            city = _model.usrinfo.city;
        
        if(_model!=nil && [SNUserManager getUserId]!=nil && (![province isEqualToString:aProvince] || ![city isEqualToString:aCity]))
        {
            [_pendingUserinfo resetUserinfo];
            _pendingUserinfo.province = aProvince;
            _pendingUserinfo.city = aCity;
            NSString* username = [SNUserManager getUserId];
            if(username!=nil && [_model updateUserInfo:username key:@"city" value:aCity  key2:@"province" value2:aProvince])
                [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Alert
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger currentIndex = -1;
    if(_model!=nil && _model.usrinfo!=nil && _model.usrinfo.gender!=nil)
        currentIndex = [_model.usrinfo.gender intValue] - 1;
    
    if(buttonIndex>=0 && buttonIndex!=currentIndex)
    {
        NSString* sex = [NSString stringWithFormat:@"%ld", buttonIndex+1];
        [_pendingUserinfo resetUserinfo];
        _pendingUserinfo.gender = sex;
        
        if(_model!=nil && [SNUserManager getUserId]!=nil)
        {
            NSString* username = [SNUserManager getUserId];
            if(username!=nil && [_model updateUserInfo:username key:@"gender" value:sex key2:nil value2:nil])
                [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//修改项被触发
-(void)uploadHeader
{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles: @"拍照", @"用户相册", nil];
//    [sheet showInView:self.tabBarController.tabBar];
//    [sheet release];
//    SNSheetFloatView* sheet = [[SNSheetFloatView alloc] init];
//    [sheet addSheetItemWithTitle:@"拍一张" andBlock:^{
//        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
//            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        else
//            [[SNStatusBarMessageCenter sharedInstance] setAlpha:0];
//        
//        SNImagePickerController* imagePicker = [[SNImagePickerController alloc] init];
//        imagePicker.delegate = self;
//        imagePicker.sourceType = sourceType;
//        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//        imagePicker.allowsEditing = YES;
//        [[TTNavigator navigator].topViewController presentViewController:imagePicker animated:YES completion:nil];
//    } layOut:NO];
//    [sheet addSheetItemWithTitle:@"从手机相册选择" andBlock:^{
//        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
//        imagePicker.delegate = self;
//        imagePicker.sourceType = sourceType;
//        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//        imagePicker.allowsEditing = YES;
//        [[TTNavigator navigator].topViewController presentViewController:imagePicker animated:YES completion:nil];
//    } layOut:NO];
//    if (![SNBaseFloatView isFloatViewShowed]) {
//        [sheet show];
//    }
}

-(void)updateNick
{
    [_userNameLabel becomeFirstResponder];
}

-(void)updateGender
{
//    SNSheetFloatView* sheet = [[SNSheetFloatView alloc] init];
//    [sheet addSheetItemWithTitle:@"男" andBlock:^{
//        if(![_model.usrinfo.gender isEqualToString:@"1"])
//        {
//            NSString* sex = @"1";
//            [_pendingUserinfo resetUserinfo];
//            _pendingUserinfo.gender = @"1";
//            if(_model!=nil && [SNUserManager getUserId]!=nil)
//            {
//                NSString* username = [SNUserManager getUserId];
//                if(username!=nil && [_model updateUserInfo:username key:@"gender" value:sex key2:nil value2:nil])
//                    [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
//            }
//        }
//    } layOut:YES];
//    [sheet addSheetItemWithTitle:@"女" andBlock:^{
//        if(![_model.usrinfo.gender isEqualToString:@"2"])
//        {
//            NSString* sex = @"2";
//            [_pendingUserinfo resetUserinfo];
//            _pendingUserinfo.gender = sex;
//            if(_model!=nil && [SNUserManager getUserId]!=nil)
//            {
//                NSString* username = [SNUserManager getUserId];
//                if(username!=nil && [_model updateUserInfo:username key:@"gender" value:sex key2:nil value2:nil])
//                    [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
//            }
//        }
//    } layOut:YES];
//    if (![SNBaseFloatView isFloatViewShowed]) {
//        [sheet show];
//    }
}

-(void)updatePlace
{
    SNCitySelectorController* selector = [[SNCitySelectorController alloc] init];
    selector._citySelectorControllerDelegate = self;
    [self.flipboardNavigationController pushViewController:selector animated:YES];
}

- (void)updateMobileNum {
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle",nil];
    TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
    [[TTNavigator navigator] openURLAction:_urlAction];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//内部函数
-(void)createUploadView
{
    if(_uploadView==nil)
    {
        UIImage* bg = [UIImage imageNamed:@"userinfo_upload_bg.png"];
        _uploadView = [[UIImageView alloc] initWithImage:bg];
        
        CGRect toolBarFrame = self.toolbarView.frame;
        _uploadView.frame = CGRectMake(0, toolBarFrame.origin.y-55+5, 320, 55);
        _uploadView.userInteractionEnabled = YES;
        _uploadView.hidden = YES;
//        [self.view addSubview:_uploadView];
        
        UIImage* mark = [UIImage imageNamed:@"userinfo_upload_img.png"];
        UIImageView* markView = [[UIImageView alloc] initWithImage:mark];
        markView.frame = CGRectMake(16.5, 19, 23, 17);
        [self.uploadView addSubview:markView];
        
        UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tipLabel.frame = CGRectMake(45.5, 10, 200, 35);
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.userInteractionEnabled = NO;
        tipLabel.text = NSLocalizedString(@"图片上传中", nil);
        [self.uploadView addSubview:tipLabel];
        
        CGRect baseRect = CGRectMake(290, 10, 30, 30);
        UIButton* cancelButton = [[UIButton alloc] initWithFrame:baseRect];
        cancelButton.backgroundColor = [UIColor clearColor];
        //[cancelButton setBackgroundImage:image forState:UIControlStateNormal];
        //[cancelButton setBackgroundImage:imagehl forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(onCannelUploadImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.uploadView addSubview:cancelButton];
    }
}

-(void)updateTheme
{
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
    [_tableView setSeparatorColor:grayColor];
    
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    [self.view setBackgroundColor:_tableView.backgroundColor];
    
    [self.headerView updateTheme];
    [_tableView reloadData];
    
    [self throughWidgetUpdateTheme];
}

- (void)throughWidgetUpdateTheme {
    _userNameLabel.textColor = SNUICOLOR(kThemeText1Color);
    _genderLabel.textColor = SNUICOLOR(kThemeText1Color);
    _locationLabel.textColor = SNUICOLOR(kThemeText1Color);
    _mobileBindLabel.textColor = SNUICOLOR(kThemeText1Color);
    
    SNUserAccountManageView *accountView1 = (SNUserAccountManageView *)[self.view viewWithTag:USERCENTER_EDIT_TAG_GROUP1];
    for (UIView *view in accountView1.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = SNUICOLOR(kThemeText1Color);
        }
        else if([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)view;
            imageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        }
    }
    
    SNUserAccountManageView *accountView2 = (SNUserAccountManageView *)[self.view viewWithTag:USERCENTER_EDIT_TAG_GROUP2];
    for (UIView *view in accountView2.subviews) {
        if ([view isKindOfClass:[UILabel class]] && (view.tag == NICK_NAME_TAG || view.tag == GENDER_TAG || view.tag == LOCATION_TAG || view.tag == MOBILE_BIND_TAG)) {
            UILabel *label = (UILabel *)view;
            label.textColor = SNUICOLOR(kThemeText4Color);
        }
    }
    
    SNUserAccountManageView *accountView3 = (SNUserAccountManageView *)[self.view viewWithTag:USERCENTER_EDIT_TAG_GROUP3];
    for (UIView *view in accountView3.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = SNUICOLOR(kThemeBlue1Color);
        }
        else if([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)view;
            imageView.image = [[UIImage imageNamed:@"divider_line_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        }
    }
}

-(void)updateTheme:(NSNotification*)notifiction
{
    [super updateTheme:notifiction];
    [self updateTheme];
}

-(void)setObjectIfNotNil:(NSString*)aObject key:(NSString*)aKey dic:(NSMutableDictionary*)aDic
{
    if(aObject.length>0 && aKey.length>0 && aDic!=nil)
       [aDic setObject:aObject forKey:aKey];
}

-(NSDictionary*)appendData:(NSDictionary*)aDictionary
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
    if([[dic objectForKey:@"title"] isEqualToString:@"上传头像"])
        [self setObjectIfNotNil:_model.usrinfo.headImageUrl key:@"headurl" dic:dic];
    else if([[dic objectForKey:@"title"] isEqualToString:@"昵称"])
        [self setObjectIfNotNil:[_model.usrinfo getNickname] key:@"content" dic:dic];
    else if([[dic objectForKey:@"title"] isEqualToString:@"性别"])
        [self setObjectIfNotNil:[_model.usrinfo getGender] key:@"content" dic:dic];
    else if([[dic objectForKey:@"title"] isEqualToString:@"所在地"])
        [self setObjectIfNotNil:[_model.usrinfo getPlace] key:@"content" dic:dic];
    
    return dic;
}

-(void)saveImage:(UIImage*)image
{
    if(_model!=nil && image!=nil)
    {
        [self fadeInLoadView];
        
        NSString* username = [SNUserManager getUserId];
        [_model performSelector:@selector(postImageRequest:image:) withObject:username withObject:image];
    }
}

-(void)showMessage
{
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"user_info_upload_tip",@"") toUrl:nil mode:SNCenterToastModeSuccess];
}

-(void)fadeInLoadView
{
    self.uploadView.alpha = 0;
    self.uploadView.hidden = NO;
    [UIView setAnimationDelegate:self];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    self.uploadView.alpha = 1.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(fadeInAnimationDidFinish) withObject:nil afterDelay:0.5f];
}

-(void)fadeInAnimationDidFinish
{
}

-(void)fadeOutLoadView
{
    self.uploadView.alpha = 1.0;
    [UIView setAnimationDelegate:self];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    self.uploadView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(fadeOutAnimationDidFinish) withObject:nil afterDelay:0.5f];
}

-(void)fadeOutAnimationDidFinish
{
    self.uploadView.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString* text = textField.text;
    text = [text trim];
    if([text length] == 0)
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"请输入合法昵称" toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    if([text length] > 12)
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"昵称长度不能超过12个字符" toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    NSString* current = @"";
    if(_model!=nil && _model.usrinfo!=nil && _model.usrinfo.nickName!=nil)
        current = _model.usrinfo.nickName;
    if(textField.text.length==0 && [current length]>0)
        textField.text = current;
    if([text isEqualToString:current])
    {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"新昵称不能跟之前昵称相同" toUrl:nil mode:SNCenterToastModeWarning];
        return NO;
    }
    if(_model!=nil)
    {
        NSString* username = [SNUserManager getUserId];
        if(username!=nil)
        {
            [textField resignFirstResponder];
            [_pendingUserinfo resetUserinfo];
            _pendingUserinfo.nickName = text;
            if([_model updateUserInfo:username key:@"nick" value:text key2:nil value2:nil])
                [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
        }
    }
    return YES;
}

-(void)viewTaped:(id)sender
{
    UITextField* nickTextField = _userNameLabel;
    [nickTextField resignFirstResponder];
    
//    NSString* current = @"";
//    if(_model!=nil && _model._usrinfo!=nil && _model._usrinfo._nickname!=nil)
//        current = _model._usrinfo._nickname;
//    
//    if(nickTextField.text.length==0 && [current length]>0)
//        nickTextField.text = current;
//    
//    if(_model!=nil && [nickTextField.text length]>0)
//    {
//        NSString* username = [_model getUserName];
//        if(username!=nil && ![nickTextField.text isEqualToString:current])
//        {
//            if([_model updateUserInfo:username key:@"nick" value:nickTextField.text key2:nil value2:nil])
//                [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
//        }
//    }
}

-(void)onCannelUploadImage:(id)sender
{
    [_model.postHeaderRequest cancel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutLoadView) object:nil];
    [self performSelector:@selector(fadeOutLoadView) withObject:nil afterDelay:0.4f];
}

- (void)addSwipeGesture {
    UISwipeGestureRecognizer *recognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture)];
    [recognizerUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:recognizerUp];
    
    UISwipeGestureRecognizer *recognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture)];
    [recognizerDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognizerDown];
}

- (void)handleSwipeGesture {
    [_userNameLabel resignFirstResponder];
}

@end
