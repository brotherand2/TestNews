//
//  SNQRFuncMenu.m
//  sohunews
//
//  Created by H on 16/5/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#define KFuncButtonsSpace               (55)
#define KFuncButtonWidth                (40)

#import "SNQRFuncMenu.h"
#import "UIFont+Theme.h"

@interface QRFuncButton : UIButton

@property (nonatomic, retain) UILabel * contentLabel;
@property (nonatomic, assign) QRFuncType funcType;

@end

@implementation QRFuncButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initButton];
    }
    return self;
}

- (void)initButton {
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.contentLabel.font = [UIFont systemFontOfSize:[UIFont fontSizeWithType:UIFontSizeTypeE]];
    self.contentLabel.textColor = SNUICOLOR(kThemeText5Color);
    [self addSubview:self.contentLabel];
    
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.contentLabel.textColor = SNUICOLOR(kThemeRed1Color);
    }else{
        self.contentLabel.textColor = SNUICOLOR(kThemeText5Color);
    }
    [super setSelected:selected];
}

@end


@interface SNQRFuncMenu ()

@property (nonatomic , retain) QRFuncButton * scanQrcodeButton;
@property (nonatomic , retain) QRFuncButton * scanImageButton;
@property (nonatomic , retain) QRFuncButton * lastSelectedButton;
@property (nonatomic , retain) UIView * selectedLine;

@end

@implementation SNQRFuncMenu

- (id) initWithFrame:(CGRect)frame funcType:(QRFuncType)type{
    if (self = [super initWithFrame:frame]) {
        [self initMenu:type];
    }
    return self;
}

- (void)initMenu:(QRFuncType)type{
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.6f;
    
    self.scanQrcodeButton = [[QRFuncButton alloc] initWithFrame:CGRectMake(0, 0, KFuncButtonWidth, self.height)];
    self.scanQrcodeButton.contentLabel.text = @"扫码";
    self.scanQrcodeButton.funcType = QRFuncTypeScanQrCode;
    self.scanQrcodeButton.left = (self.width - (KFuncButtonsSpace + 2*KFuncButtonWidth))/2.f;
    [self.scanQrcodeButton addTarget:self action:@selector(switchScanFunc:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.scanQrcodeButton];
    
    self.scanImageButton = [[QRFuncButton alloc] initWithFrame:CGRectMake(0, 0, KFuncButtonWidth, self.height)];
    self.scanImageButton.left = _scanQrcodeButton.right + KFuncButtonsSpace;
    self.scanImageButton.contentLabel.text = @"扫图";
    self.scanImageButton.funcType = QRFuncTypeScanImage;
    [self.scanImageButton addTarget:self action:@selector(switchScanFunc:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.scanImageButton];
    
    self.selectedLine = [[UIView alloc] initWithFrame:CGRectMake(_scanQrcodeButton.left, 0, KFuncButtonWidth, 2)];
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (isNightTheme) {
        self.selectedLine.backgroundColor = [UIColor colorWithRed:0.44f green:0.16f blue:0.16f alpha:1.00f];
    }else{
        self.selectedLine.backgroundColor = [UIColor colorWithRed:0.95f green:0.17f blue:0.00f alpha:1.00f];
        
    }

//    _selectedLine.backgroundColor = [UIColor colorWithRed:0.95f green:0.17f blue:0.00f alpha:1.00f];
    [self addSubview:self.selectedLine];
    
    [self setScanType:type];
}

- (void)setScanType:(QRFuncType)scanType {
    switch (scanType) {
        case QRFuncTypeScanQrCode:
        {
            self.scanQrcodeButton.selected = YES;
            self.scanImageButton.selected = NO;
            self.lastSelectedButton.selected = NO;
            self.lastSelectedButton = _scanQrcodeButton;
            [UIView animateWithDuration:0.2 animations:^{
                _selectedLine.centerX = _scanQrcodeButton.centerX;
            } completion:^(BOOL finished) {
                
            }];

            break;
        }
        case QRFuncTypeScanImage:
        {
            self.scanImageButton.selected = YES;
            self.scanQrcodeButton.selected = NO;
            self.lastSelectedButton.selected = NO;
            self.lastSelectedButton = _scanImageButton;
            [UIView animateWithDuration:0.2 animations:^{
                self.selectedLine.centerX = _scanImageButton.centerX;
            } completion:^(BOOL finished) {
                
            }];

            break;
        }
        default:
            break;
    }
}

- (void)switchScanFunc:(QRFuncButton *)button{
    if ([button.contentLabel.text isEqualToString:self.lastSelectedButton.contentLabel.text]) {
        return;
    }
    self.lastSelectedButton.selected = NO;
    button.selected = YES;
    self.lastSelectedButton = button;
    
    if (self.scanModeDelegate && [self.scanModeDelegate respondsToSelector:@selector(switchScanMode:)]) {
        [self.scanModeDelegate switchScanMode:button.funcType];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.selectedLine.centerX = button.centerX;
    } completion:^(BOOL finished) {
        
    }];
}

@end
