//
//  SNWeatherCityAddCell.m
//  sohunews
//
//  Created by yanchen wang on 12-7-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherCityAddCell.h"
#import "SNThemeManager.h"
#import "UIColor+ColorUtils.h"

#define kIconSize   (44.0 / 2)

@implementation SNWeatherCityAddCell
@synthesize editBtn = _editBtn;
@synthesize cityInfoDic = _cityInfoDic;
@synthesize delegate = _delegate;
@synthesize bSubed = _bSubed;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(320, 0, kIconSize, kIconSize)];
        _editBtn.backgroundColor = [UIColor clearColor];
        [_editBtn addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_editBtn];

        _delImage = [UIImage imageNamed:@"weather_city_remove.png"];
    }
    return self;
}

- (void)dealloc {
     //(_editBtn);
     //(_cityInfoDic);
     //(_addImage);
     //(_delImage);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        self.alpha = 0.6;
    }
    else {
        self.alpha = 1.0;
    }
    if (_editBtn) {
        _editBtn.frame = CGRectMake(self.width - 40 - kIconSize, (self.height - kIconSize) / 2, kIconSize, kIconSize);
        [_editBtn setImage:_delImage forState:UIControlStateNormal];
    }
    self.textLabel.left = 15;
    
    self.textLabel.textColor= [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagNormalTextColor]];
}

- (void)setBSubed:(BOOL)bSubed {
    _bSubed = bSubed;
//    UIImage *image = _bSubed ? _delImage : _addImage;
//    [_editBtn setImage:image forState:UIControlStateNormal];
}

- (void)edit {
//    SEL sel = _bSubed ? @selector(delAction:) : @selector(addAction:);
    SEL sel = @selector(delAction:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelectorOnMainThread:sel withObject:self waitUntilDone:YES];
//        self.bSubed = !_bSubed;
    }
}

@end
