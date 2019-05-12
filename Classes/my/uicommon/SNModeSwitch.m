//
//  SNModeSwitch.m
//  sohunews
//
//  Created by qi pei on 5/24/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNModeSwitch.h"
#import "UIColor+ColorUtils.h"

@implementation SNModeSwitch
@synthesize on = _on;
- (id)init
{
	if((self = [super initWithFrame:CGRectMake(245,0,60,44)])){

        imgOn =  [UIImage  imageNamed:@"download_setting_all_selected.png"];
        imgOff  =  [UIImage  imageNamed:@"download_setting_atleastone_unselected.png"];
        
        self.showsTouchWhenHighlighted = YES;
    }
	return self;
}

-(void)setOn:(BOOL)on {
    _on = on;
    if (_on) {
        [self setImage:imgOn forState:UIControlStateNormal];
    } else {
        [self setImage:imgOff forState:UIControlStateNormal];
    }
}

-(void)dealloc{
     //(imgOn);
     //(imgOff);
}

@end
