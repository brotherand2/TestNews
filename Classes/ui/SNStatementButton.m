//
//  SNStatementButton.m
//  sohunews
//
//  Created by guoyalun on 1/29/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNStatementButton.h"
#import "UIColor+ColorUtils.h"

@implementation SNStatementButton

- (id)init
{
    if (self = [super initWithFrame:CGRectMake(10, 0, 300, 37)]) {
        [self config];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(10, 0, frame.size.width, 37)]) {
        [self config];
    }
    
    return self;
}

- (void)config
{
    UIImage* image = [UIImage imageNamed:@"userinfo_cellbg.png"];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 49, 24)];
    else
        image = [image stretchableImageWithLeftCapWidth:24.5 topCapHeight:24.5];
    
    UIImage* imagehl = [UIImage imageNamed:@"userinfo_cellbg_hl.png"];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        imagehl = [imagehl resizableImageWithCapInsets:UIEdgeInsetsMake(0, 24, 49, 24)];
    else
        imagehl = [imagehl stretchableImageWithLeftCapWidth:24.5 topCapHeight:24.5];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:imagehl forState:UIControlStateHighlighted];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right.png"]];
    icon.frame = CGRectMake(self.frame.size.width-23, 12, icon.image.size.width, icon.image.size.height);
    [self addSubview:icon];
    
    [self setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kStatementButtonTextColor]] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:15];

}



@end
