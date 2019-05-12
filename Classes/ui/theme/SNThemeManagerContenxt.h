//
//  SNThemeManagerContenxt.h
//  sohunews
//
//  Created by WongHandy on 10/2/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

static CGFloat SNThemeManagerContenxtScale3X = 3.0;
static CGFloat SNThemeManagerContenxtScaleiOS7 = 2.5;
static CGFloat SNThemeManagerContenxtScale2X = 2.0;
static CGFloat SNThemeManagerContenxtScale1X = 1.0;

@interface SNThemeManagerContenxt : NSObject
@property(nonatomic, copy) NSString *themeImageName;
@property(nonatomic, strong) NSArray *themeImageNameComponents;
@property(nonatomic, copy) NSString *imageName;
@property(nonatomic, strong) NSArray *imageNameComponents;
@property(nonatomic, assign) CGFloat scale;

- (NSString *)imageNamePatterByScale;
- (void)downscale;
@end
