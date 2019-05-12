//
//  SNShareMenuViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNShareMenuViewModel : NSObject

@property (nonatomic,strong) NSArray* shareIconsArr;

- (instancetype)initWithData:(NSDictionary*)dic;

@end
