//
//  SNProgressView.h
//  sohunews
//
//  Created by handy wang on 6/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNProgressView : UIView {
    UIImageView *_backgroundView;
    UIImageView *_trackImageView;
}

- (void)updateProgress:(CGFloat)progressValue animated:(BOOL)animated;

@end