//
//  SNSubscribeAlertView.h
//  sohunews
//
//  Created by Chen Hong on 12-12-3.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNAlertBaseView.h"

@interface SNSubscribeAlertView : SNAlertBaseView {
    BOOL _isChecked;
}

@property(nonatomic,assign)BOOL isChecked;

@end
