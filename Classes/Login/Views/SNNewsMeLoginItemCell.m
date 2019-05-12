//
//  SNNewsMeLoginItemCell.m
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsMeLoginItemCell.h"
#import "SNNewsMeLoginModel.h"

@interface SNNewsMeLoginItemCell ()

@property (nonatomic,strong) UIImageView* icon;
@property (nonatomic,strong) NSString* iconImageName;

@end

@implementation SNNewsMeLoginItemCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.icon = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.icon];
        
        //切换夜间模式 wangshun
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info{
    NSString* name = [info objectForKey:@""];
    
    if (info && [info isKindOfClass:[NSDictionary class]]) {
        self.dic = info;
    }
    
    NSString* imgName = [self.dic objectForKey:SNNewsMeLoginIcon];
    self.iconImageName = imgName;
    [self.icon setImage:[UIImage themeImageNamed:imgName]];
}

- (void)setImageViewStateWithHightlighted:(BOOL)hightlight andDict:(NSDictionary *)dict {
    if (hightlight) {
        NSString *imgName = [NSString stringWithFormat:@"%@press_v5.png",[[dict objectForKey:SNNewsMeLoginIcon] substringToIndex:[[dict objectForKey:SNNewsMeLoginIcon] length] - 7]];
        [self.icon setImage:[UIImage themeImageNamed:imgName]];
    } else {
        NSString* imgName = [self.dic objectForKey:SNNewsMeLoginIcon];
        [self.icon setImage:[UIImage themeImageNamed:imgName]];
    }
}

- (void)updateTheme{
    [self.icon setImage:[UIImage themeImageNamed:self.iconImageName]];
}


@end
