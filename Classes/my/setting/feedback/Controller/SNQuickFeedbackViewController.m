//
//  SNQuickFeedbackViewController.m
//  sohunews
//
//  Created by 李腾 on 2016/10/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNQuickFeedbackViewController.h"
#import "SNSelectImageCollectionViewCell.h"
#import "SNUserManager.h"
#import "SNPlaceholderTextView.h"
#import "SNWaitingActivityView.h"
#import "SNChatFeedbackController.h"
#import "SNNetDiagnoService.h"
#import "SNScreenshotRequest.h"
#import "NSString+Utilities.h"
#import "SNNewAlertView.h"
#import "SNSendFeedBackRequest.h"

#define NFBContent    @"NewFBContent"  // 反馈内容
#define NFBImages     @"NFBImages"     // 反馈图片
#define NFBTypeID     @"NFBTypeID"     // 反馈类型ID
#define NFBPhoneNum   @"NFBPhoneNum"   // 联系方式
#define kIconFBTianJia                @"icofeedback_tianjia_v5.png"
#define kIconFBScreenShot             @"icofeedback_screenshot_v5.png"

#define kSideMargin  14.0f

#define kTipText          @"联系方式"
#define kTipToastMsg      @"限定150字以内"
#define kTipPhoneToastMsg @"请输入有效的联系方式"
#define kTipEnterTextMsg  @"选填，方便与您进行联系"
#define kLimitCount  150
#define kLimitPhoneCount 30

#define kLastNetDate      @"lastNetDiagDate"

@interface SNQuickFeedbackViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SNSelectImageCollectionViewCellDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *imagesArr;

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, weak) SNPlaceholderTextView *editeTextView;                 // 反馈内容

@property (nonatomic, weak) UILabel *limitLabel;

@property (nonatomic, weak) UILabel *countLabel;

@property (nonatomic, weak) UIButton *sendBtn;

@property (nonatomic, copy) NSString *typeID;                         // 反馈ID

@property (nonatomic, weak) UITextField *phoneTF;                     // 联系方式

@property (nonatomic, assign) BOOL haveSceenShot;                     // 是否是截图反馈

@property (nonatomic, weak) UIView *middleView;

@property (nonatomic, weak) UIScrollView  *scrollView;

@property (nonatomic, assign) NSInteger oldTextLength;               // 记录上一次输入后文字个数
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation SNQuickFeedbackViewController

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
        
        if ([[query objectForKey:kScreenShotSwitch] length] > 0) {
            self.typeID = [[query objectForKey:kScreenShotSwitch] description];
            
        }
        if ([query objectForKey:kFeedBackScreenshot]) {
            self.haveSceenShot = YES;
            UIImage *screenshotImage = query[kFeedBackScreenshot];
            [self.imagesArr insertObject:screenshotImage atIndex:self.imagesArr.count - 1];
        }
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    scrollView.backgroundColor = SNUICOLOR(kBackgroundColor);
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    CGFloat offset = kAppScreenHeight;
    if ([UIDevice currentDevice].platformTypeForScreen == UIDevice5SiPhone) {
        offset += 80;
    } else if ([UIDevice currentDevice].platformTypeForScreen == UIDevice4SiPhone) {
        offset += 168;
    } else if ([UIDevice currentDevice].platformTypeForScreen == UIDevice6iPhone) {
        offset += 18;
    }
    scrollView.contentSize = CGSizeMake(0, offset);
    _scrollView = scrollView;
    [self.view addSubview:scrollView];
    [self addHeaderView];
    NSString *title = @"意见反馈";
    [self.headerView setSections:@[title]];
    self.headerView.delegate = self;
    
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(0, self.headerView.height-2, titleSize.width, 2)];
    
    [self addToolbar];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.tag = 1001;
    UIImage *btnImage = [UIImage themeImageNamed:@"feedBack_send_button_disable.png"];
    sendBtn.frame = CGRectMake(kAppScreenWidth - btnImage.size.width - 6, 4,
                               btnImage.size.width, btnImage.size.height);
    [sendBtn setImage:btnImage forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendFeedBack) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.layer.cornerRadius = 4;
    self.sendBtn = sendBtn;
    [self.toolbarView addSubview:sendBtn];
    //    [self isEnableSendFeedBack];
    
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(dismissImagePickController) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = SNUICOLOR(kBackgroundColor);
    [self addEditView];
    [self createBottomView];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:NFBContent]) {
        self.editeTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:NFBContent];
        [self textViewDidChange:self.editeTextView];
        self.editeTextView.placeHolderLabel.alpha = 0;
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:NFBPhoneNum]) {
        self.phoneTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:NFBPhoneNum];
        if (self.phoneTF.text.length > kLimitPhoneCount) {
            self.phoneTF.text = [self.phoneTF.text substringToIndex:kLimitPhoneCount - 1];
        }
    }
    
    [self setSendBtnState];
    
}

- (void)viewWillDisappear:(BOOL)animated  {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}


- (void)addEditView {
    UIView *editView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderTotalHeight + 1, kAppScreenWidth, 88)];
    editView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [self.scrollView addSubview:editView];
    
    UILabel *limitLabel = [[UILabel alloc] init];
    limitLabel.text = [NSString stringWithFormat:@"0/%zd",kLimitCount];
    limitLabel.textAlignment = NSTextAlignmentRight;
    limitLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [limitLabel sizeToFit];
    limitLabel.width = editView.width;
    limitLabel.right = kAppScreenWidth - kSideMargin;
    limitLabel.bottom = editView.height;
    limitLabel.textColor = SNUICOLOR(kThemeText3Color);
    self.limitLabel = limitLabel;
    [editView addSubview:limitLabel];
    
    SNPlaceholderTextView *textView = [[SNPlaceholderTextView alloc] initWithFrame:CGRectMake(kSideMargin, 10, kAppScreenWidth - kSideMargin * 2, editView.height - limitLabel.height - 10)];
    textView.textColor = SNUICOLOR(kThemeText2Color);
    textView.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    textView.placeholder = @"请简要描述您的问题和建议";
    textView.placeholderColor = SNUICOLOR(kThemeText3Color);
    self.editeTextView = textView;
    textView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    //    textView.inputAccessoryView = [self addEditInputAccessoryView];
    //    [textView becomeFirstResponder];
    [editView addSubview:textView];
    
    
    UIView *middleView = [[UIView alloc] init];
    middleView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    middleView.top = editView.bottom +  kSideMargin;
    middleView.height = 116;
    middleView.left = 0;
    middleView.width = kAppScreenWidth;
    [self.scrollView addSubview:middleView];
    _middleView = middleView;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, kAppScreenWidth, 18)];
    tipLabel.backgroundColor = SNUICOLOR(kThemeBg4Color);
    tipLabel.text = @"上传问题截图(选填)";
    tipLabel.textColor = SNUICOLOR(kThemeText2Color);
    tipLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    [middleView addSubview:tipLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    _countLabel = countLabel;
    countLabel.text = @"0/3";
    _countLabel.backgroundColor = SNUICOLOR(kThemeBg4Color);
    countLabel.textColor = SNUICOLOR(kThemeText3Color);
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [countLabel sizeToFit];
    countLabel.origin = CGPointMake(kAppScreenWidth - kSideMargin - countLabel.width, 10);
    [middleView addSubview:countLabel];
    
    CGFloat margin = 14.0f;
    CGFloat itemW = 60.0f;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemW, itemW);
    flowLayout.minimumLineSpacing = margin;
    flowLayout.minimumInteritemSpacing = 0.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, margin, 0, 0);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(margin, tipLabel.bottom + 16, kAppScreenWidth - 2 *margin, itemW + 10) collectionViewLayout:flowLayout];
    collectionView.bounces = NO;
    collectionView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [middleView addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView registerClass:[SNSelectImageCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([SNSelectImageCollectionViewCell class])];
    
}

- (void)createBottomView {
    
    UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, self.middleView.bottom + 13 , kAppScreenWidth, 42)];
    contactView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [self.scrollView addSubview:contactView];
    
    CGSize textSize = [kTipText textSizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeD]];
    UITextField *textF = [[UITextField alloc] initWithFrame:CGRectMake(textSize.width + kSideMargin * 2, 0, kAppScreenWidth - kSideMargin * 3 - textSize.width, contactView.height)];
    textF.height = [kTipEnterTextMsg textSizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeD]].height;
    textF.centerY = contactView.height/2;
    textF.textColor = SNUICOLOR(kThemeText3Color);
    textF.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    textF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kTipEnterTextMsg attributes:@{NSForegroundColorAttributeName:SNUICOLOR(kThemeText3Color)}];
    textF.delegate = self;
    textF.returnKeyType = UIReturnKeyDone;
    textF.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [textF addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    _phoneTF = textF;
    [contactView addSubview:textF];
    
    /// 添加此view的原因是:TextField输入超过其宽度后,继续输入会出现向左闪的情况;这样做只是为了挡住它.
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 2 * kSideMargin, 42)];
    coverView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [contactView addSubview:coverView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSideMargin, 0, textSize.width, textSize.height)];
    titleLabel.text = kTipText;
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    titleLabel.textColor = SNUICOLOR(kThemeText2Color);
    titleLabel.backgroundColor = SNUICOLOR(kThemeBg4Color);
//    [titleLabel sizeToFit];
    titleLabel.centerY = contactView.height/2;
    [contactView addSubview:titleLabel];
 
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectImage = info[UIImagePickerControllerOriginalImage];
    // MARK: - 处理图片
    CGSize imgSize = selectImage.size;
    //所有上传照片最大像素等比例压缩
    CGFloat maxPix = 2208/3;
    
    if (imgSize.width > imgSize.height) {
        CGFloat  scale = imgSize.height/imgSize.width;
        if (imgSize.width > maxPix) {
            imgSize.width = maxPix;
            imgSize.height = scale * maxPix;
        }
    }else {
        CGFloat  scale = imgSize.width/imgSize.height;
        if (imgSize.height > maxPix) {
            imgSize.height = maxPix;
            imgSize.width = scale * maxPix;
        }
    }
    selectImage = [UIImage imageWithImage:selectImage scaledToSize:imgSize];
    if (!self.haveSceenShot) {
        if (self.imagesArr.count == 1) {
            [self.imagesArr addObject:[UIImage imageNamed:kIconFBTianJia]];
            [self.imagesArr removeObjectAtIndex:0];
        }
    }
    [self.imagesArr insertObject:selectImage atIndex:self.imagesArr.count - 1];
    [self setSendBtnState];
    [self.collectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.imagesArr.count > 3) {
        return 3;
    }
    return self.imagesArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SNSelectImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SNSelectImageCollectionViewCell class]) forIndexPath:indexPath];
    if (indexPath.item != self.imagesArr.count - 1) {
        
        cell.imageView.image = [UIImage imageWithImage:self.imagesArr[indexPath.item] scaledToSize:CGSizeMake(60, 60)];
        if ([SNThemeManager sharedThemeManager].isNightTheme) {
            cell.imageView.alpha = 0.5;
        } else {
            cell.imageView.alpha = 1;
        }
        
    } else {
        
        cell.imageView.image = self.imagesArr[indexPath.item];
        
    }
    cell.delegate = self;
    if (indexPath.item != self.imagesArr.count - 1) {
        cell.delBtn.hidden = NO;
    } else {
        cell.delBtn.hidden = YES;
    }
    return  cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.imagesArr.count - 1) {
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
            if (!self.imagePickerController) {
                self.imagePickerController = [[UIImagePickerController alloc] init];
                self.imagePickerController.delegate = self;
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            [self.view endEditing:YES];
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    }
}

#pragma mark - SNSelectImageCollectionViewCellDelegate
- (void)removeImageWithCell:(SNSelectImageCollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self.imagesArr removeObjectAtIndex:indexPath.item];
    if (self.imagesArr.count == 1) {
        
        [self.imagesArr addObject:[UIImage imageNamed:kIconFBScreenShot]];
        [self.imagesArr removeObjectAtIndex:0];
    }
    [self.collectionView reloadData];
    [self setSendBtnState];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (textView.markedTextRange != nil) {
        return YES;
    }
    if (textView.text.length + text.length > kLimitCount) {
        SNCenterToast *toast = [SNCenterToast shareInstance];
        toast.verticalOffset = 120;
        [toast showCenterToastWithTitle:kTipToastMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        return NO;
    }
    
//    NSString *tem = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
//    if (![text isEqualToString:tem]) {
//        return NO;
//        
//    }
    return YES;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    [self setSendBtnState];
    NSInteger editeInt = textView.text.length;
    
    if (textView.markedTextRange == nil) {
        if (textView.text.length > kLimitCount) {
            textView.text = [textView.text substringToIndex:kLimitCount];
            SNCenterToast *toast = [SNCenterToast shareInstance];
            toast.verticalOffset = 120;
            [toast showCenterToastWithTitle:kTipToastMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
    if (editeInt > kLimitCount) {
        editeInt = kLimitCount;
    }
    self.limitLabel.text = [NSString stringWithFormat:@"%zd/%zd",editeInt,kLimitCount];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField.markedTextRange != nil) {
        return YES;
    }
    if (textField.text.length + string.length > kLimitPhoneCount) {
        SNCenterToast *toast = [SNCenterToast shareInstance];
        toast.verticalOffset = 120;
        [toast showCenterToastWithTitle:kTipPhoneToastMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        return NO;
    }
    
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidChanged:(UITextField *)textField {

    if (textField.markedTextRange == nil) {
        if (textField.text.length > kLimitPhoneCount) {
            textField.text = [textField.text substringToIndex:kLimitPhoneCount];
            SNCenterToast *toast = [SNCenterToast shareInstance];
            toast.verticalOffset = 120;
            [toast showCenterToastWithTitle:kTipPhoneToastMsg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
}

// MARK: - -------------------- 发送反馈 START ------------------------
- (void)sendFeedBack {
   
    [[NSUserDefaults standardUserDefaults] setObject:self.phoneTF.text forKey:NFBPhoneNum];
    [self.view endEditing:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 网络诊断
        NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970];
        NSString *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastNetDate];
        if (lastDate != nil && lastDate.length > 0) {
            if ((currentDate - lastDate.doubleValue) > 60*60) { // 时间大于一个小时
                
                [[SNNetDiagnoService sharedInstance] startNetDiagnosis];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",currentDate] forKey:kLastNetDate];
            [[SNNetDiagnoService sharedInstance] startNetDiagnosis];
        }
        
        // H5debug开关 2017.3.12
        if ([[NSUserDefaults standardUserDefaults] stringForKey:SNH5DebugSwitchKey]) {
            NSString *switchKey = [[NSUserDefaults standardUserDefaults] stringForKey:SNH5DebugSwitchKey];
            if (0 == switchKey.integerValue) {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SNH5DebugSwitchKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",currentDate] forKey:SNH5DebugSwitchKeepTime];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SNH5DebugSwitchKey];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",currentDate] forKey:SNH5DebugSwitchKeepTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
    
    CGFloat activityViewW = 12.0f;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *coverV = [[UIView alloc] initWithFrame:window.bounds];
    coverV.backgroundColor = [UIColor clearColor];
    [window addSubview:coverV];
    SNWaitingActivityView *waitingActivityView = [[SNWaitingActivityView alloc] initWithFrame:CGRectMake((kAppScreenWidth - activityViewW) / 2, (kAppScreenHeight - activityViewW) / 2, activityViewW, activityViewW)];
    [coverV addSubview:waitingActivityView];
    [waitingActivityView startAnimating];
    
    NSMutableDictionary *paramM = [NSMutableDictionary dictionary];
    NSString *contentText = [self.editeTextView.text trim];
    if (contentText.length > 0) {
        BOOL containEmoji = [self.editeTextView.text isContainsEmoji];
        if (containEmoji) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送失败！内容描述暂不支持输入表情" toUrl:nil mode:SNCenterToastModeOnlyText];
            [waitingActivityView stopAnimating];
            [coverV removeFromSuperview];
            return;
        }
        NSString *utfStr = [self.editeTextView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [paramM setObject:utfStr forKey:@"content"];
    }
    if (self.phoneTF.text.length > 0) {
        [paramM setObject:self.phoneTF.text forKey:@"phone"];
    }
    if (self.typeID.length > 0) {
        [paramM setObject:self.typeID forKey:@"type"];
    }
    
    [[[SNSendFeedBackRequest alloc] initWithDictionary:paramM andImageArray:self.imagesArr.copy] send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject[@"statusCode"] isEqualToString:@"200"]) {
            // 记录反馈内容
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            if (contentText.length > 0) {
                [dict setObject:self.editeTextView.text forKey:@"content"];
            }
            if (self.imagesArr.count > 1) {
                [self.imagesArr removeObjectAtIndex:self.imagesArr.count - 1];
                [dict setObject:self.imagesArr forKey:@"images"];
            }
            
            [waitingActivityView stopAnimating];
            [coverV removeFromSuperview];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送成功" toUrl:nil mode:SNCenterToastModeSuccess];
            
            if (self.phoneTF.text.length > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:self.phoneTF.text forKey:NFBPhoneNum];
            }
            // 打开截屏权限
            [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kFbScreenShot];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:NFBContent];
            [NSKeyedArchiver archiveRootObject:nil toFile:[NSString writeToFileWithName:NFBImages]];
            UIViewController *viewController = self.flipboardNavigationController.previousViewController;
            if ([viewController isKindOfClass:[SNChatFeedbackController class]]) {
                
                SNChatFeedbackController *chatVC = (SNChatFeedbackController *)self.flipboardNavigationController.previousViewController;
                chatVC.feedbackDict = dict.copy;
                if ([self.delegate respondsToSelector:@selector(SendFeedBackSuccessWithDict:)]) {
                    [self.delegate SendFeedBackSuccessWithDict:dict.copy];
                }
                [self.flipboardNavigationController popViewController];
                
            } else {
                [self.flipboardNavigationController popViewControllerAnimated:NO];
                
                TTURLAction *urlAction = [[TTURLAction actionWithURLPath:@"tt://feedback"] applyAnimated:YES];
                NSMutableDictionary *query = [NSMutableDictionary dictionary];
                [query setObject:[NSNumber numberWithBool:YES] forKey:@"ScreenShotFeedBack"];
                [query setObject:dict forKey:@"feedBackDict"];
                [urlAction applyQuery:query.copy];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        }
        
        if ([responseObject[@"statusCode"] isEqualToString:@"405"]) {  // 达到反馈上限
            [waitingActivityView stopAnimating];
            [coverV removeFromSuperview];
            
            SNNewAlertView *tipAlert = [[SNNewAlertView alloc] initWithTitle:nil message:@"我们已收到您的反馈,如果您有紧急问题需要解决请拨打我们的客服电话\n400-052-0613" cancelButtonTitle:@"取消" otherButtonTitle:@"拨打电话"];
            [tipAlert show];
            [tipAlert actionWithBlocksCancelButtonHandler:nil otherButtonHandler:^{
                NSString *phoneNumber = [NSString stringWithFormat:@"telprompt://%@",@"400-052-0613"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }];
        }
        if ([responseObject[@"statusCode"] isEqualToString:@"999"]) {
            [waitingActivityView stopAnimating];
            [coverV removeFromSuperview];
            NSString *statusMsg = responseObject[@"statusMsg"];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:statusMsg toUrl:nil mode:SNCenterToastModeError];
        }
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self.view endEditing:YES];
        [waitingActivityView stopAnimating];
        [coverV removeFromSuperview];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"发送失败" toUrl:nil mode:SNCenterToastModeError];
    }];
}
// MARK: - -------------------- 发送反馈 END------------------------

#pragma mark - 发送按钮是否可点击
- (BOOL)isEnableSendFeedBack {
    NSString *text = [self.editeTextView.text trim];
    BOOL isEnableSend = self.imagesArr.count > 1 || (text.length > 0 && ![text isEqualToString:@""]);
    self.sendBtn.enabled = isEnableSend;
    return isEnableSend;
}

- (void)setSendBtnState {
    
    self.countLabel.text = [NSString stringWithFormat:@"%zd/3",self.imagesArr.count - 1];
    
    UIImage *btnImage = [UIImage imageNamed:([self isEnableSendFeedBack]?@"feedBack_send_button_enable.png":@"feedBack_send_button_disable.png")];
    [self.sendBtn setImage:btnImage forState:UIControlStateNormal];
}

#pragma mark - 点击返回提示是否保存
- (void)onBack:(id)sender {
    
    [self.view endEditing:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.phoneTF.text forKey:NFBPhoneNum];
    if (self.editeTextView.text.length == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:NFBContent];
    }
    [self handleSaveOrCancelWithSender:sender];
}


- (void)handleSaveOrCancelWithSender:(id)sender {
    
    if ([self isEnableSendFeedBack]) {
        
        SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:@"是否保存当前编辑内容?" cancelButtonTitle:@"取消" otherButtonTitle:@"保存"];
        [alertView show];
        [alertView actionWithBlocksCancelButtonHandler:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:NFBContent];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [NSKeyedArchiver archiveRootObject:nil toFile:[NSString writeToFileWithName:NFBImages]];
            });
            [super onBack:sender];
            [self.navigationController popViewControllerAnimated:YES];
            
        } otherButtonHandler:^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (self.editeTextView.text.length > 0) {
                [userDefaults setObject:self.editeTextView.text forKey:NFBContent];
            }
            if (self.imagesArr.count > 1) {
                NSMutableArray *arrM = [NSMutableArray array];
                
                for (NSInteger i = 0; i < self.imagesArr.count -1; i++) {
                    UIImage *image = self.imagesArr[i];
                    [arrM addObject:UIImagePNGRepresentation(image)];
                    
                }
                [NSKeyedArchiver archiveRootObject:arrM toFile:[NSString writeToFileWithName:NFBImages]];
            } else {
                [NSKeyedArchiver archiveRootObject:nil toFile:[NSString writeToFileWithName:NFBImages]];
            }
            if (self.typeID.length > 0) {
                [userDefaults setObject:self.typeID forKey:NFBTypeID];
            }
            [userDefaults synchronize];
            if (self.phoneTF.text.length > 0) {
                [userDefaults setObject:self.phoneTF.text forKey:NFBPhoneNum];
            }
            
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"保存成功" toUrl:nil mode:SNCenterToastModeSuccess];
            [super onBack:sender];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:NFBContent];
            [NSKeyedArchiver archiveRootObject:nil toFile:[NSString writeToFileWithName:NFBImages]];
        });
        [super onBack:sender];
    }
}


#pragma mark - NSNotifications

- (void)keyboardWillShow:(NSNotification *)noti {
    
    CGSize kbSize = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.toolbarView.transform = CGAffineTransformMakeTranslation(0, -kbSize.height + [SNToolbar toolbarHeight]- kToolbarHeight);
    }];
    if ([self.phoneTF isFirstResponder]) {
        [self scrollsToBottomAnimated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)noti {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self.toolbarView.transform = CGAffineTransformIdentity;
    }];
}

- (void)scrollsToBottomAnimated:(BOOL)animated{
    CGFloat offset = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    if (offset > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            
            [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
        }];
    }
}

- (BOOL)panGestureEnable {
    return NO;
}

- (NSMutableArray *)imagesArr {
    if (nil == _imagesArr ) {
        _imagesArr = [NSMutableArray arrayWithCapacity:4];
        
        if (!self.haveSceenShot) {
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString writeToFileWithName:NFBImages]];
            if (array.count > 0) {
                for (NSData *ImgData in array) {
                    [_imagesArr addObject:[UIImage imageWithData:ImgData]];
                }
                [_imagesArr addObject:[UIImage imageNamed:kIconFBTianJia]];
                
            } else {
                [_imagesArr addObject:[UIImage imageNamed:kIconFBScreenShot]];
            }
        } else {
            [_imagesArr addObject:[UIImage imageNamed:kIconFBTianJia]];
        }
        //        [self isEnableSendFeedBack];
        
    }
    return _imagesArr;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (![viewController isKindOfClass:NSClassFromString(@"PUUIAlbumListViewController")] && ![viewController isKindOfClass:NSClassFromString(@"PUUIPhotosAlbumViewController")] && ![viewController isMemberOfClass:[UIViewController class]] && ![viewController isKindOfClass:NSClassFromString(@"PUUIMomentsGridViewController")] && ![viewController isKindOfClass:NSClassFromString(@"PLUIPrivacyViewController")]) {
        navigationController.navigationBarHidden = YES;
    } else {
        navigationController.navigationBarHidden = NO;
    }
    if ([viewController isKindOfClass:[self class]]) {
        [navigationController popViewControllerAnimated:NO];
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self.imagesArr insertObject:[SNScreenshotRequest sharedInstance].screenShotImage atIndex:self.imagesArr.count - 1];
            [self setSendBtnState];
            [self.collectionView reloadData];
        }];
        return;
    }
    
}

- (void)dismissImagePickController {
    if (self.imagePickerController) {
        [self.imagePickerController dismissViewControllerAnimated:NO completion:^{}];
    }
}

- (void)dealloc {
    if (self.imagePickerController) {
        self.imagePickerController.delegate = nil;
        self.imagePickerController = nil;
    }
    [SNNotificationManager removeObserver:self];
}


@end
