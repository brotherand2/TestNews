//
//  SNAppConfigTimeControl.h
//  sohunews
//
//  Created by Scarlett on 16/8/30.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigTimeControl : NSObject

@property (nonatomic, strong) NSDictionary *timeCtrlDict;

- (void)updateWithDict:(NSDictionary *)dict;

@end
