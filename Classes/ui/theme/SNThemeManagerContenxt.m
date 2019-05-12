//
//  SNThemeManagerContenxt.m
//  sohunews
//
//  Created by WongHandy on 10/2/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNThemeManagerContenxt.h"

@implementation SNThemeManagerContenxt

- (NSString *)imageNamePatterByScale {
    NSString *imageNamePattern = nil;
    if (_scale == SNThemeManagerContenxtScale3X) {//3倍屏
        imageNamePattern = @"%@@3x.%@";
    }
    else if (_scale == SNThemeManagerContenxtScaleiOS7) {//只是为了兼容iOS7
        imageNamePattern = @"%@@ios7@2x.%@";
    }
    else if (_scale == SNThemeManagerContenxtScale2X) {//2倍屏
        imageNamePattern = @"%@@2x.%@";
    }
    else if (_scale == SNThemeManagerContenxtScale1X) {//1倍屏
        imageNamePattern = @"%@.%@";
    }
    else {
        imageNamePattern = @"unknown%@.%@";//未知，这里只是为了程序逻辑的兼容性
    }
    return imageNamePattern;
}

- (void)downscale {
    if (_scale == SNThemeManagerContenxtScale3X) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _scale = SNThemeManagerContenxtScaleiOS7;
        } else {
            _scale = SNThemeManagerContenxtScale2X;
        }
    } else if (_scale == SNThemeManagerContenxtScaleiOS7) {
        _scale = SNThemeManagerContenxtScale2X;
    } else if (_scale == SNThemeManagerContenxtScale2X) {
        _scale = SNThemeManagerContenxtScale1X;
    }
}

@end
