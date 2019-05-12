//
//  UIMenuController+Observe.h
//  sohunews
//
//  Created by jojo on 13-9-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSObject.h>


@interface UIMenuController (Observe)

- (NSString *)getMenuControllerKey;
- (void)setMenuControllerKeyWithString:(NSString *) keyString;

@end
