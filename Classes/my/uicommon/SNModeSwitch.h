//
//  SNModeSwitch.h
//  sohunews
//
//  Created by qi pei on 5/24/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNModeSwitch : UIButton {
    BOOL _on;
    UIImage *imgOn;
    UIImage *imgOff;
}

@property (nonatomic,assign) BOOL on;

@end
