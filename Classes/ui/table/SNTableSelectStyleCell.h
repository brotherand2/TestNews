//
//  SNTableSelectStyleCell.h
//  sohunews
//
//  Created by Cong Dan on 4/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTableSelectStyleCell : TTTableSubtitleItemCell
{
    UIImageView *_cellSelectedBg;
    
    NSString *_currentTheme;
}

- (BOOL)needsUpdateTheme;
-(void)updateTheme;

@end
