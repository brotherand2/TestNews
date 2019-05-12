//
//  SNFileSystemSizeBar.h
//  sohunews
//
//  Created by handy wang on 10/12/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNFileSystemSizeBar : UIView
- (void)update:(unsigned long long)diskFreeSizeInBytes downloadedVideosInBytes:(unsigned long long)downloadedVideosInBytes;
@end