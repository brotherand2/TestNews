//
//  SNLinkButton.h
//  sohunews
//
//  Created by guoyalun on 7/1/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNLinkButton : UIButton
{
    UILabel  *titleLabel;
    NSString *url;
}
@property (nonatomic,strong) NSString *url;

- (void)setTitleFont:(UIFont *)font;

@end
