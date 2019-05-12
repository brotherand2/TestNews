//
//  SNCorpusTableViewCell.m
//  sohunews
//
//  Created by Scarlett on 15/8/27.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNCorpusTableViewCell.h"
#import "SNNewAlertView.h"
#import "SNDeleteCorpusRequest.h"
#import "SNUpdateCorpusRequest.h"

@interface SNCorpusTableViewCell () <UITextFieldDelegate>{
    UIImageView *_itemImageView;
    UIImageView *_bgImageView;
    UIButton *_deleteButton;
}

@property (nonatomic, copy)NSString *corpusName;
@property (nonatomic, copy)NSString *corpusID;
@property (nonatomic, copy)NSString *oldCorpusName;

@end

@implementation SNCorpusTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kCorpusTableViewCellHeight)];
        _bgImageView.alpha = 0;
        [self.contentView addSubview:_bgImageView];
        
        _itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCorpusCellImageLeftDistance, (kCorpusTableViewCellHeight-kCorpusCellImageWidth)/2, kCorpusCellImageWidth, kCorpusCellImageWidth)];
        [self.contentView addSubview:_itemImageView];
        
        CGSize textSize = [kCorpusFolderName getTextSizeWithFontSize:kThemeFontSizeE];
        _itemTextField = [[UITextField alloc] initWithFrame:CGRectMake(0 , (kCorpusTableViewCellHeight - textSize.height)/2, kAppScreenWidth-kCorpusCellImageWidth-kCorpusCellImageLeftDistance-kCorpusCellImageRightDistance-kCorpusCellImageLeftDistance-30, textSize.height)];
        _itemTextField.left = _itemImageView.right+kCorpusCellImageRightDistance;
        _itemTextField.backgroundColor = [UIColor clearColor];
        _itemTextField.font = [UIFont systemFontOfSize:kThemeFontSizeE];
        _itemTextField.textColor = SNUICOLOR(kThemeText2Color);
        _itemTextField.userInteractionEnabled = NO;
        _itemTextField.delegate = self;
        _itemTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.contentView addSubview:_itemTextField];
        
        UIButton *clearButton = [_itemTextField valueForKey:@"_clearButton"];
        if (clearButton && [clearButton isKindOfClass:[UIButton class]]) {
            [clearButton setImage:[UIImage imageNamed:@"icosearch_delete_v5.png"] forState:UIControlStateNormal];
//            [clearButton setImage:[UIImage imageNamed:@"icosearch_deletepress_v5.png"] forState:UIControlStateHighlighted];
        }
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, kCorpusDeleteImageWidth, kCorpusDeleteImageWidth);
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"ico_shanchu_v5.png"] forState:UIControlStateNormal];
        _deleteButton.center = _itemImageView.center;
        _deleteButton.right = 0;
        [_deleteButton addTarget:self action:@selector(deleteCorpus:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
        
        [SNNotificationManager addObserver:self
                                  selector:@selector(textFieldDidChange:)
                                      name:UITextFieldTextDidChangeNotification
                                    object:_itemTextField];
        [SNNotificationManager addObserver:self
                                  selector:@selector(receivePushNotification:)
                                      name:kNotifyDidReceive
                                    object:nil];

    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self setHighlighted:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        _bgImageView.alpha = 1;
        _bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    }
    else {
        _bgImageView.alpha = 0;
        _bgImageView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setCellItemWithImagName:(NSString *)imageName text:(NSString *)text corpusID:(NSString *)corpusID isEditMode:(BOOL)isEditMode textColor:(NSString *)textColor {
    _itemImageView.image = [UIImage imageNamed:imageName];
    _itemTextField.text = text;
    self.corpusName = text;
    self.corpusID = corpusID;
    if (!([text isEqualToString:kCorpusMyFavourite] || [text isEqualToString:kCorpusMyShare])) {
        _deleteButton.hidden = NO;
    }
    else {
        _deleteButton.hidden = YES;
    }
    
    if (isEditMode) {
        [self cellDeleteMode:0];
    }
    else {
        [self cellNormalMode];
    }

    self.oldCorpusName = text;
}

- (void)deleteCorpus:(id)sender {
    [_itemTextField resignFirstResponder];
//    [SNNotificationManager postNotificationName:kDeleteCorpusClickNotification object:nil];
    if ([self.delegate respondsToSelector:@selector(resetToolBar)]) {
        [self.delegate resetToolBar];
    }
    
    NSString *temp = [_itemTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//判断空格
    if (_itemTextField.text.length == 0 || temp.length == 0) {
        _itemTextField.text = _oldCorpusName;
    }
    
    SNNewAlertView *delAlert = [[SNNewAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@\"%@\"%@", kCorpusDelete, _itemTextField.text, kCorpusDeleteTail] cancelButtonTitle:@"取消" otherButtonTitle:@"删除"];
    [delAlert show];
    [delAlert actionWithBlocksCancelButtonHandler:^{
       
    } otherButtonHandler:^{
        [self deleteConfirm];
    }];
    
}

- (void)deleteConfirm {
    //删除收藏夹
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:_corpusID forKey:kCorpusID];
    
    [[[SNDeleteCorpusRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
        
        if (status == 200) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:kDeleteSucceed toUrl:nil mode:SNCenterToastModeSuccess];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_corpusID, kCorpusID, _corpusName, kCorpusFolderName, nil];
            
            if ([self.delegate respondsToSelector:@selector(refreshCorpusListWithDict:)]) {
                [self.delegate refreshCorpusListWithDict:dict];
            }
            
            [SNNotificationManager postNotificationName:kReloadCorpus object:self userInfo:@{kCorpusID:@"0",kCorpusFolderName:kCorpusMyFavourite,kNotAutoPlay:[NSNumber numberWithBool:YES]}];
        }
    } failure:nil];
}

- (void)cellDeleteMode:(CGFloat)duration {
    if (!([_itemTextField.text isEqualToString:kCorpusMyFavourite] || [_itemTextField.text isEqualToString:kCorpusMyShare])) {
        _itemTextField.userInteractionEnabled = YES;
        
    }
    [UIView animateWithDuration:duration animations:^(void){
        _deleteButton.left = kCorpusCellImageLeftDistance;
        _itemImageView.left = kCorpusCellImageLeftDistance + _deleteButton.right;
        _itemTextField.left = _itemImageView.right+kCorpusCellImageRightDistance;

    } completion:^(BOOL finished){
        
    }];
}

- (void)cellNormalMode {
    _itemTextField.userInteractionEnabled = NO;
    [UIView animateWithDuration:kCellAnimationDuration animations:^(void){
        _deleteButton.right = 0;
        _itemImageView.left = kCorpusCellImageLeftDistance;
        _itemTextField.left = _itemImageView.right+kCorpusCellImageRightDistance;
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length == 0)
        return YES;
    
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength > 10) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.corpusBlock) {
        self.corpusBlock(self);
    }
}

- (void)textFieldDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *range = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:range.start offset:0];
        if (!position) {
            if (toBeString.length > 9) {
                textField.text = [toBeString substringToIndex:10];
            }
        }
    }
    else {
        if (toBeString.length > 9) {
            textField.text = [toBeString substringToIndex:10];
        }
    }
    
    NSString *temp = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//判断空格
    if (textField.text.length == 0 || temp.length == 0) {
        return;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *temp = [_itemTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//判断空格
    if (_itemTextField.text.length == 0 || temp.length == 0) {
        return;
    }
    [self updateCorpusName:textField.text];
}

- (void)receivePushNotification:(NSNotification *)notification {
    [_itemTextField resignFirstResponder];
    [SNNotificationManager removeObserver:self name:kNotifyDidReceive object:nil];
}

//- (void)finishedManage:(NSNotification *)notification {
//    NSString *temp = [_itemTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//判断空格
//    if (_itemTextField.text.length == 0 || temp.length == 0) {
//        _itemTextField.text = _oldCorpusName;
//    }
//    _itemTextField.userInteractionEnabled = NO;
//    _deleteButton.right = 0;
//    _itemImageView.left = kCorpusCellImageLeftDistance;
//    _itemTextField.left = _itemImageView.right+kCorpusCellImageRightDistance;
////    [self updateCorpusName:_itemTextField.text];
//}

- (void)finishManageCorpus {
    NSString *temp = [_itemTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//判断空格
    if (_itemTextField.text.length == 0 || temp.length == 0) {
        _itemTextField.text = _oldCorpusName;
    }
    _itemTextField.userInteractionEnabled = NO;
    _deleteButton.right = 0;
    _itemImageView.left = kCorpusCellImageLeftDistance;
    _itemTextField.left = _itemImageView.right+kCorpusCellImageRightDistance;
}

- (void)changeCorpusName {
    if (![self.oldCorpusName isEqualToString:_itemTextField.text]) {
        [self updateCorpusName:_itemTextField.text];
    }
}


- (void)updateCorpusName:(NSString *)name {
    if ([name isEqualToString:_corpusName]) {
        return;
    }

    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:2];
    [param setObject:_corpusID forKey:kCorpusID];
    [param setObject:name forKey:kCorpusFolderName];
    [[[SNUpdateCorpusRequest alloc] initWithDictionary:param] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
        
        if (status == 200) {
            _corpusName = name;

            if ([self.delegate respondsToSelector:@selector(updateCorpusNameWithDict:)]) {
                [self.delegate updateCorpusNameWithDict:param.copy];
            }
            
            [SNNotificationManager postNotificationName:kReloadCorpus
                                                 object:self
                                               userInfo:nil];
        }

    } failure:nil];
}

- (void)updateTheme {
    [super updateTheme];
    _bgImageView.alpha = themeImageAlphaValue();
    _itemTextField.textColor = SNUICOLOR(kThemeText1Color);
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"ico_shanchu_v5.png"] forState:UIControlStateNormal];
    _itemImageView.alpha = themeImageAlphaValue();
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}


@end
