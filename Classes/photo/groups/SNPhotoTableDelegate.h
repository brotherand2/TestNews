//
//  SNHotTableDelegate.h
//  sohunews
//
//  Created by ivan on 3/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTableViewDragRefreshDelegate.h"

@interface SNPhotoTableDelegate : SNTableViewDragRefreshDelegate {
}

- (BOOL)shouldReload;

@end
