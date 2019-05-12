//
//  SNNormalSearchView.m
//  sohunews
//
//  Created by Scarlett on 15/12/17.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNNormalSearchView.h"
#import "SNChannelManageContants.h"
#import "SNCustomTextField.h"

@interface SNNormalSearchView ()<UITextFieldDelegate> {
    UIImageView *_searchIconImageview;
    SNCustomTextField *_searchTextField;
    UIButton *_searchButton;
    UIImageView *_shadowImageView;
    id _delegate;
}

@end

@implementation SNNormalSearchView
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (id)initWithFrame:(CGRect)frame delegate:(id) delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        _delegate = delegate;
        [self initTextField];
        [self initSearchButton];
        [self showShadow];
    }
    return self;
}

- (void)initTextField {
    UIImage *searchImage = [UIImage imageNamed:@"icopersonal_search_v5.png"];
    CGFloat pointY = 0;
    CGSize searchSize = CGSizeMake(21.0, 21.0);
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        pointY = searchSize.height - 10.0;
    }
    else {
        pointY = searchSize.height + 10.0;
    }

    _searchIconImageview = [[UIImageView alloc] initWithFrame:CGRectMake(kIcoNormalSettingLeft, pointY, searchSize.width, searchSize.height)];
    _searchIconImageview.image = searchImage;
    [self addSubview:_searchIconImageview];
    
    CGSize size = [kPleaseInputSearchCity getTextSizeWithFontSize:kThemeFontSizeD];
    
    _searchTextField = [[SNCustomTextField alloc] initWithFrame:CGRectMake(_searchIconImageview.right + 6, pointY, kAppScreenWidth - _searchIconImageview.right - 60, size.height)];
    _searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    _searchTextField.placeholder = kPleaseInputSearchCity;
    _searchTextField.rightViewMode = UITextFieldViewModeUnlessEditing;
    _searchTextField.delegate = _delegate;
    _searchTextField.backgroundColor = [UIColor clearColor];
    _searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchTextField.textColor = SNUICOLOR(kThemeText1Color);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [_searchTextField addTarget:_delegate action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
#pragma clang diagnostic pop

    [self addSubview:_searchTextField];
    
    // 修改删图片
    UIButton *clearButton = [_searchTextField valueForKey:@"_clearButton"];
    if (clearButton && [clearButton isKindOfClass:[UIButton class]]) {
        
        UIImage *image = [UIImage imageWithBundleName:@"icosearch_delete_v5.png"];
        UIImage *image2 = [UIImage imageWithBundleName:@"icosearch_deletepress_v5.png"];
//        [clearButton setImage:[UIImage imageNamed:@"icosearch_delete_v5.png"] forState:UIControlStateNormal];
//        [clearButton setImage:[UIImage imageNamed:@"icosearch_deletepress_v5.png"] forState:UIControlStateHighlighted];
        [clearButton setImage:image forState:UIControlStateNormal];
        [clearButton setImage:image2 forState:UIControlStateHighlighted];
    }
}

- (void)initSearchButton {
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [_searchButton setTitle:kCancelText forState:UIControlStateNormal];
    [_searchButton sizeToFit];
    _searchButton.center = _searchTextField.center;
    _searchButton.right = kAppScreenWidth - kButtonRightDistance;
    _searchButton.hidden = YES;
    [_searchButton setTitleColor:SNUICOLOR(kThemeText4Color) forState:UIControlStateNormal];
    [_searchButton addTarget:_delegate action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_searchButton];
}

- (void)showSearchButton:(BOOL)isShow {
    NSString *title = nil;
    UIColor *color = nil;
    SEL cancelSelect = nil;
    SEL doSelect = nil;
    if (isShow) {
        title = kSearchText;
        color = SNUICOLOR(kThemeRed1Color);
        cancelSelect = @selector(cancelSearch);
        doSelect = @selector(doSearch);
    }
    else {
        title = kCancelText;
        color = SNUICOLOR(kThemeText4Color);
        cancelSelect = @selector(doSearch);
        doSelect = @selector(cancelSearch);
    }
    _searchButton.hidden = NO;
    [_searchButton setTitle:title forState:UIControlStateNormal];
    [_searchButton setTitleColor:color forState:UIControlStateNormal];
    [_searchButton removeTarget:_delegate action:cancelSelect forControlEvents:UIControlEventTouchUpInside];
    [_searchButton addTarget:_delegate action:doSelect forControlEvents:UIControlEventTouchUpInside];
}

- (void)showShadow {
    UIImage *image = [UIImage imageNamed:@"icotitlebar_shadow_v5.png"];
    image = [image stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    if (!_shadowImageView) {
        _shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 2)];
    }
    _shadowImageView.image = image;
    
    CGFloat bottom = 0;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        bottom = self.height - 20.0;
    }
    else {
        bottom = self.height;
    }
    
    _shadowImageView.top = bottom;
    [self addSubview:_shadowImageView];
}

- (void)closeKeyBoard {
    [_searchTextField resignFirstResponder];
    _searchButton.hidden = YES;
}

- (void)resetTextView {
    _searchTextField.text = nil;
}

- (NSString *)getSearchText {
    return _searchTextField.text;
}

- (BOOL)isSearching {
    if (_searchTextField.text && ![_searchTextField.text isEqualToString:@""]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)dealloc {
     //(_searchIconImageview);
    _searchTextField.delegate = nil;
     //(_searchTextField);
     //(_shadowImageView);
    
}
#pragma clang diagnostic pop
@end
