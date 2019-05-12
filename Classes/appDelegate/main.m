//  main.m
//  sohunews
//
//  Created by zhu kuanxi on 5/16/11.
//  Copyright 2011 sohu. All rights reserved.
//

#import <UIKit/UIKit.h>

CFAbsoluteTime StartTime;

int main(int argc, char *argv[]) {
    StartTime = CFAbsoluteTimeGetCurrent();
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([sohunewsAppDelegate class]));
    }
}
