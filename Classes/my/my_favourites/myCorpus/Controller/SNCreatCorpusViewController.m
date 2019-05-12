//
//  SNCreatCorpusViewController.m
//  sohunews
//
//  Created by yangln on 15/8/26.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNCreatCorpusViewController.h"
#import "SNCustomTextField.h"
#import "SNFavoriteViewController.h"
#import "SNCorpusNewsViewController.h"
#import "SNMyCorpusViewController.h"
#import "SNCreatCorpusRequest.h"
#import "SNCorpusList.h"
#import "SNCorpusAlertObject.h"

#define kTextFieldTopDistance 33/2.0
#define kTextFieldLeftDistance 33/2.0
#define kTextFieldBackHeight 116/2.0
#define kCountLabelRightDistance 33/2.0
#define kCountLabelTopDistance 33/2.0
#define kProtectButtonRight 33/2.0
#define kLimitTextCount 10
#define kLimitTextTip @"限定10个字以内"

@interface SNCreatCorpusViewController () <UITextFieldDelegate>{
    UIView *_inputBackView;
    BOOL _isFromCorpusListCreat;
    BOOL _isMove;
    UIButton *_protectButton;
    BOOL _isKeyboardHidden;
}
@property (nonatomic, strong) SNCustomTextField *inputTextField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) id methodValue;
@property (nonatomic,   copy) NSString *idString;

@end

@implementation SNCreatCorpusViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    self = [super initWithNavigatorURL:URL query:query];
    if (self) {
        _isFromCorpusListCreat = [[query objectForKey:kIsFromCorpusListCreat] boolValue];
        _isMove = [[query objectForKey:kIsMoveCorpusList] boolValue];
        self.delegate = [query objectForKey:@"delegate"];
        self.methodValue = [query objectForKey:@"method"];
        self.idString = [query objectForKey:@"id"];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self addHeaderView];
    [self.headerView setSections:[NSArray arrayWithObjects:kCorpusNewFavourite, nil]];
    CGSize titleSize = [kCorpusNewFavourite sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    
    _inputBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderTotalHeight + kTextFieldTopDistance, kAppScreenWidth, kTextFieldBackHeight)];
    _inputBackView.backgroundColor = SNUICOLOR(kThemeBg3Color);
    [_inputBackView addSubview:self.inputTextField];
    [self.view addSubview:_inputBackView];
    [self.view addSubview:self.countLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 1)];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    lineView.bottom = _inputBackView.top;
    [self.view addSubview:lineView];
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 1)];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    lineView.top = _inputBackView.bottom;
    [self.view addSubview:lineView];
    
    [self addToolbar];
    _protectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _protectButton.backgroundColor = [UIColor clearColor];
    [_protectButton setTitle:kCorpusProtect forState:UIControlStateNormal];
    [_protectButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    _protectButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [_protectButton sizeToFit];
    _protectButton.right = kAppScreenWidth - kProtectButtonRight;
    _protectButton.top = (kToolbarHeight - _protectButton.height)/2;
    [_protectButton addTarget:self action:@selector(protectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:_protectButton];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(keyboardWillShow:)
                                  name:UIKeyboardWillShowNotification
                                object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(textFieldDidChange:)
                                  name:UITextFieldTextDidChangeNotification
                                object:_inputTextField];
    [SNNotificationManager addObserver:self
                              selector:@selector(receivePushNotification:)
                                  name:kNotifyDidReceive
                                object:nil];
    [SNNotificationManager addObserver:self
                              selector:@selector(receivePushNotification:)
                                  name:kOpenNewsFromWidgetNotification
                                object:nil];
}

- (UITextField *)inputTextField {
    if (!_inputTextField) {
        CGSize titleSize = [kCorpusFavouriteTitle sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeD]];
        SNCustomTextField *inputTextField = [[SNCustomTextField alloc] initWithFrame:CGRectMake(kTextFieldLeftDistance, (kTextFieldBackHeight - titleSize.height)/2, kAppScreenWidth - kTextFieldLeftDistance, titleSize.height)];
        _inputTextField = inputTextField;
        _inputTextField.backgroundColor = [UIColor clearColor];
        _inputTextField.placeholder = kCorpusFavouriteTitle;
        _inputTextField.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _inputTextField.textColor = SNUICOLOR(kThemeText4Color);
        _inputTextField.delegate = self;
        [_inputTextField becomeFirstResponder];
    }
    return _inputTextField;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        UILabel *countLabel = [[UILabel alloc] init];
        _countLabel = countLabel;
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor grayColor];
        _countLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        _countLabel.text = @"10/10";
        [_countLabel sizeToFit];
        _countLabel.top = _inputBackView.bottom + kCountLabelTopDistance;
        _countLabel.right = kAppScreenWidth - kCountLabelRightDistance;
        _countLabel.text = @"0/10";
    }
    return _countLabel;
}

#pragma mark UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _isKeyboardHidden = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length == 0) {
        return YES;
    }
    
    NSInteger length = 0;
    for (int i = 0; i< textField.text.length; i ++) {
        unichar c = [textField.text characterAtIndex:i];
        if (c != 0x2006) {//用于判拼音输入法，未点击汉字的空格，有别于正常空格
            length ++;
        }
    }
    if (textField.markedTextRange != nil) {
        return YES;
    }
    if (textField.text.length > kLimitTextCount) {
        SNCenterToast *toast = [SNCenterToast shareInstance];
        toast.verticalOffset = 120;
        [toast showCenterToastWithTitle:kLimitTextTip toUrl:nil mode:SNCenterToastModeOnlyText];
        return NO;
    }
    
    
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    int length = 0;
    for (int i = 0; i< textField.text.length; i ++) {
        unichar c = [textField.text characterAtIndex:i];
        if (c != 0x2006) {//用于判拼音输入法，未点击汉字的空格，有别于正常空格
            length ++;
        }
    }
    
    if (textField.markedTextRange == nil) {
        if (textField.text.length > 9) {
            textField.text = [textField.text substringToIndex:kLimitTextCount];
            SNCenterToast *toast = [SNCenterToast shareInstance];
            toast.verticalOffset = 120;
            [toast showCenterToastWithTitle:kLimitTextTip toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
    NSInteger count = textField.text.length;
    if (count > 9) {
        count = kLimitTextCount;
    }
    _countLabel.text = [NSString stringWithFormat:@"%d/10", count];
}

- (void)protectAction:(id)sender {
    NSString *temp = [_inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//判断空格
    if (_inputTextField.text.length == 0 || temp.length == 0) {
        SNCenterToast *toast = [SNCenterToast shareInstance];
        toast.verticalOffset = 120;
        [toast showCenterToastWithTitle:kCorpusNameEmpty toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        SNCenterToast *toast = [SNCenterToast shareInstance];
        toast.verticalOffset = 120;
        [toast showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    _protectButton.userInteractionEnabled = NO;
    
    NSString *entryString = nil;//统计用，收藏列表新建为1，浮层为2
    if (_isFromCorpusListCreat) {
        entryString = @"1";
    }
    else {
        entryString = @"2";
    }
    NSMutableDictionary *paraM = [NSMutableDictionary dictionaryWithCapacity:2];
    [paraM setObject:_inputTextField.text forKey:kCorpusFolderName];
    [paraM setObject:entryString forKey:@"entry"];
    [[[SNCreatCorpusRequest alloc] initWithDictionary:paraM] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
        
        if (status == 200) {
            [_inputTextField resignFirstResponder];
            
            NSString *corpusId = [responseObject stringValueForKey:kCorpusID defaultValue:nil];
            NSString *folderName = [responseObject objectForKey:kCorpusFolderName];
            if (!_isFromCorpusListCreat) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                [dict setValue:corpusId forKey:kCorpusID];
                [dict setValue:folderName forKey:kCorpusFolderName];

                if (_isMove) {
                    [SNNotificationManager postNotificationName:kMoveCorpusItemNotification object:nil userInfo:dict];
                }
                else {
                    if (_delegate && [_methodValue isKindOfClass:[NSValue class]] && [_delegate respondsToSelector:[_methodValue pointerValue]]) {
                        NSTimeInterval delay = 0.0;
                        if ([_delegate isKindOfClass:[SNCorpusAlertObject class]]) {
                            delay = 0.5;
                        }
                        [_delegate performSelector:[_methodValue pointerValue] withObject:dict afterDelay:delay];
                    }
                }
            }
            else {
                if (_idString.length > 0) {//移动操作
                    [self moveToNewCorpus:corpusId corpusName:folderName newID:_idString];
                }
            }
            [self resetToolBarOrigin];
            
            UIViewController *viewController = self.flipboardNavigationController.previousViewController;
            if (_inputTextField.text.length > 0) {
                BOOL isFromMycorpus = NO;
                NSArray *array = self.flipboardNavigationController.viewControllers.copy;
                for (UIViewController *controller in array) {
                    if ([controller isKindOfClass:[SNMyCorpusViewController class]]) {
                        isFromMycorpus = YES;
                    }
                }
                if (isFromMycorpus) {
                    [self.flipboardNavigationController popViewControllerAnimated:YES];
                    [SNNotificationManager postNotificationName:kReloadCorpus object:self userInfo:nil];
                } else {
                    
                    if ([viewController isKindOfClass:[SNCorpusNewsViewController class]]) {
                        
                        [SNNotificationManager postNotificationName:kReloadCorpus object:self userInfo:nil];
                        
                        for (UIViewController *controller in array) {
                            if ([controller isKindOfClass:[SNFavoriteViewController class]]) {
                                SNFavoriteViewController *favoriteVC = (SNFavoriteViewController *)controller;
                                [self.flipboardNavigationController popToViewController:favoriteVC animated:YES];
                            }
                        }
                    } else {
                        if ([viewController isKindOfClass:[SNFavoriteViewController class]]) {
                            
                            [SNNotificationManager postNotificationName:kReloadCorpus object:self userInfo:@{kCorpusID:corpusId}];
                        }
                        [self performSelector:@selector(onBack:) withObject:nil afterDelay:kCellAnimationDuration];
                        [SNCorpusList resaveCorpusList];
                    }
                }
//                if (!_isMove) {
//                    
//                }
            }
        }
        else {
            _protectButton.userInteractionEnabled = YES;
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kInpututRightCorpusName toUrl:nil mode:SNCenterToastModeWarning];
        }

    } failure:nil];
    
}


- (void)moveToNewCorpus:(NSString *)corpusID corpusName:(NSString *)corpusName newID:(NSString *)newsID{
    // 此方法应该是旧版的逻辑,先注掉代码;如果后期出现问题再打开 by Li Teng.
   /* NSString *urlString = [NSString stringWithString:SNLinks_Path_Corpus_BatchMove];
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?corpusId=%@&ids=%@", corpusID, newsID]];
    SNFeedBackNetRequest *netRequest = [[SNFeedBackNetRequest alloc] init];
    netRequest.url = urlString;
    netRequest.METHOD = HttpRequestTypeGet;
    netRequest.requestParams = nil;
    [netRequest sendAsynchronousSuccessBlock:^(NSDictionary *jsonDict) {
        NSInteger status = [(NSString *)[jsonDict objectForKey:kStatus] integerValue];

        if (status == 200) {
            [SNUtility showToastWithID:corpusID folderName:corpusName];
        }
        
    } failedBlock:^(NSError *error) {
        
    }];
    */
}

- (void)onBack:(id)sender {
    [_inputTextField resignFirstResponder];
    if (self.flipboardNavigationController) {
        [self.flipboardNavigationController popViewController];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (_isKeyboardHidden) {
        return;
    }
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    CGFloat pointY = kAppScreenHeight - bg.size.height - keyboardSize.height + 5;
    self.toolbarView.origin = CGPointMake(self.toolbarView.frame.origin.x, pointY);
}

- (void)receivePushNotification:(NSNotification *)notification {
    _isKeyboardHidden = YES;
    [_inputTextField resignFirstResponder];
    [self resetToolBarOrigin];
}

- (void)dealloc {
    
    [SNNotificationManager removeObserver:self];
}

@end
