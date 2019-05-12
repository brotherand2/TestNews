//
//  SNSpecialNewsDelegate.h
//  sohunews
//
//  Created by handy wang on 7/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTableViewDragRefreshDelegate.h"

@class SNSpecialNewsModel;

@interface SNSpecialNewsDelegate : SNTableViewDragRefreshDelegate

- (BOOL)shouldReload;
- (SNSpecialNewsModel *)getSpecialNewsModel;

@end