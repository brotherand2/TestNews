//
//  SNNewsLoginKeyBoard.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsLoginKeyBoard : NSObject

@property (nonatomic,weak) SNToolbar* toolbarView;

-(instancetype)initWithToolbar:(SNToolbar*)toolbar;

- (void)createkeyboardNotification;
- (void)removeKeyBoardNotification;

@end
