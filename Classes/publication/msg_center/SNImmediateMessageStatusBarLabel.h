//
//  SNImmediateMessageStatusBarLabel.h
//  sohunews
//
//  Created by handy wang on 7/13/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNImmediateMessageStatusBarLabel : UIView {

    UIImageView *_icon;
    
    UILabel *_messageLabel;

}

@property(nonatomic, copy)NSString *text;

-(void)updateTheme;
- (void)updateStausBarStyle:(NSString *)style;
@end