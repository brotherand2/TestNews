//
//  SNLiveFlowersFallView.h
//  sohunews
//
//  Created by Chen Hong on 7/7/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNLiveFlowersFallView : UIView {
    UIImage *_spriteImg;
    NSTimer *_timer;
}

- (void)strewFlowers;
- (void)stopTimer;

@end
