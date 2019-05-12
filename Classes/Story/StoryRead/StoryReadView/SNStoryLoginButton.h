//
//  SNStoryLoginButton.h
//  sohunews
//
//  Created by Huang Zhen on 13/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loginAndBuyBlock)();

@interface SNStoryLoginButton : UIView

- (instancetype)initWithFrame:(CGRect)frame loginBlock:(loginAndBuyBlock)loginBlock;

- (void)updateNovelTheme;

@end
