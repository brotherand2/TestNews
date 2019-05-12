//
//  SNTableSelectStyleCell2.h
//  sohunews
//
//  Created by Cong Dan on 4/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTableSelectStyleCell2 :TTTableViewCell
{
    NSString *_currentTheme;
    BOOL _showSlectedBg;
}

@property(nonatomic, assign) BOOL showSlectedBg;

- (BOOL)needsUpdateTheme;
- (void)updateTheme;

@end
