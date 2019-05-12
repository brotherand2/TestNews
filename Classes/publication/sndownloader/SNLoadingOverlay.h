//
//  SNLoadingOverlay.h
//  sohunews
//
//  Created by handy wang on 8/25/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNWaitingActivityView;

@interface SNLoadingOverlay : UIView {

    SNWaitingActivityView *_loading;
    
    UIImageView *_logo;

}

@end