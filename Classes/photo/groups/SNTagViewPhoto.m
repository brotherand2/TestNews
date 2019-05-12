//
//  SNTagView.m
//  sohunews
//
//  Created by qi pei on 7/21/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTagViewPhoto.h"

#define MAX_HEIGHT                      (300)

@implementation SNTagViewPhoto

- (id)init {
    self = [super init];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = YES;
        NSString *bgFileName = [[SNThemeManager sharedThemeManager] themeFileName:@"tag_view_bg.jpg"];
        UIImage *bgImage = [[UIImage imageNamed:bgFileName] scaledImage];
        self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        self.scrollsToTop = NO;
    }
    return self;
}

- (void)updateTheme {
    [super updateTheme];
    
    NSString *bgFileName = [[SNThemeManager sharedThemeManager] themeFileName:@"tag_view_bg.jpg"];
    UIImage *viewBgImage = [[UIImage imageNamed:bgFileName] scaledImage];
    self.backgroundColor = [UIColor colorWithPatternImage:viewBgImage];
}

- (void)addTagsToView {
    [super addTagsToView];
    //    CGFloat height=CGRectGetMaxY(lastTagBtn.frame)+BOTTOM_MARGIN;
    //    if (height>MAX_HEIGHT) {
    //        height=MAX_HEIGHT;
    //    }
    //    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    if (self.height > MAX_HEIGHT) {
        self.height = MAX_HEIGHT;
    }
}

@end
