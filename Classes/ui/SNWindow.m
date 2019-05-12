//
//  SNWindow.m
//  sohunews
//
//  Created by kuanxi zhu on 12/26/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWindow.h"
#import "SNViewBorder.h"
#import "SNTapIndicator.h"

@implementation SNWindow

- (void)sendEvent:(UIEvent *)event {
    if (_listenScreenTouch) {
        if (event.type == UIEventTypeTouches) {//发送一个名为‘nScreenTouch’（自定义）的事件
            [SNNotificationManager postNotification:[NSNotification notificationWithName:@"nScreenTouch" object:nil userInfo:[NSDictionary dictionaryWithObject:event forKey:@"data"]]];
        }
    }
    if ([SNPreference sharedInstance].debugModeEnabled) {
        if ([SNPreference sharedInstance].touchDetectEnabled) {
            UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
            if ( self == keyWindow )
            {
                if ( UIEventTypeTouches == event.type )
                {
                    NSSet * allTouches = [event allTouches];
                    if ( 1 == [allTouches count] )
                    {
                        UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
                        if ( 1 == [touch tapCount] )
                        {
                            if ( UITouchPhaseBegan == touch.phase )
                            {
                                SNDebugLog( @"view '%@', touch began\n%@", [[touch.view class] description], [touch.view description] );
                                
                                SNViewBorder * border = [[SNViewBorder alloc] init];
                                border.frame = touch.view.bounds;
                                [touch.view addSubview:border];
                                [border startAnimation];
                            }
                            else if ( UITouchPhaseEnded == touch.phase || UITouchPhaseCancelled == touch.phase )
                            {
                                SNDebugLog( @"view '%@', touch ended\n%@", [[touch.view class] description], [touch.view description] );
                                
                                SNTapIndicator * indicator = [[SNTapIndicator alloc] init];
                                indicator.frame = CGRectMake( 0, 0, 50.0f, 50.0f );
                                indicator.center = [touch locationInView:keyWindow];
                                [keyWindow addSubview:indicator];
                                [indicator startAnimation];
                            }
                        }
                    }
                }
            }
        }
    }
    
    [super sendEvent:event];
}

@end
