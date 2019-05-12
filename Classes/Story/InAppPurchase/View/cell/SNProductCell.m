//
//  SNProductCell.m
//  sohunews
//
//  Created by Huang Zhen on 2017/9/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNProductCell.h"

@interface SNProductCell ()

/**
 价格显示
 */
@property (nonatomic, copy) NSString * price;


@property (nonatomic, strong) UILabel * sb;
@property (nonatomic, strong) UILabel * rmb;

@end

@implementation SNProductCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = SNUICOLOR(kThemeBg4Color);
    
    self.sb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height/2.f)];
    self.sb.textColor = SNUICOLOR(kThemeRed1Color);
    self.sb.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    self.sb.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.sb];
    
    self.rmb = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height/2.f, self.width, self.height/2.f)];
    self.rmb.textColor = SNUICOLOR(kThemeRed1Color);
    self.rmb.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.rmb.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.rmb];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = SNUICOLORREF(kThemeBg1Color);
    self.layer.cornerRadius = 2;
    self.clipsToBounds = YES;
}

- (void)update:(NSDictionary *)updateInfo {
    /*
     "id": 101,
     "desc": "600书币",
     "price": "6.00"
     */
    if ([updateInfo isKindOfClass:[NSDictionary class]]) {
        self.sb.text = [updateInfo stringValueForKey:@"desc" defaultValue:@""];
        self.price = [updateInfo stringValueForKey:@"price" defaultValue:@""];
        self.productId = [updateInfo stringValueForKey:@"id" defaultValue:@"100"];
//        self.quantity = [updateInfo intValueForKey:@"standard" defaultValue:1];
        self.quantity = 1;
        self.rmb.text = [NSString stringWithFormat:@"%@元",self.price];
    }
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.backgroundColor = SNUICOLOR(kThemeRed1Color);
        self.rmb.textColor = SNUICOLOR(kThemeText5Color);
        self.sb.textColor = SNUICOLOR(kThemeText5Color);
        
    }else{
        self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        self.rmb.textColor = SNUICOLOR(kThemeRed1Color);
        self.sb.textColor = SNUICOLOR(kThemeRed1Color);
    }
    [super setSelected:selected];
}

@end
