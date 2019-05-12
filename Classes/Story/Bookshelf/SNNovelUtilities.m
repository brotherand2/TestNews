//
//  SNNovelUtilities.m
//  sohunews
//
//  Created by qz on 17/04/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNNovelUtilities.h"

@implementation SNNovelUtilities

+ (NSInteger)bookNumbersOfSingleShelfRow{
    return 3;
}

+ (CGFloat)shelfImageHeightWidthRatio{
    return (252.0/204);
}

+ (CGFloat)shelfImageWidth{
    
    CGFloat originX = 11;
    CGFloat padding = 47.0/2;//两个图之间的间距
    
    return ([UIScreen mainScreen].bounds.size.width - ([SNNovelUtilities bookNumbersOfSingleShelfRow]-1)*padding - 2*originX)/[SNNovelUtilities bookNumbersOfSingleShelfRow];
}

+ (CGFloat)shelfCellHeight{
    return [SNNovelUtilities shelfImageWidth] * [SNNovelUtilities shelfImageHeightWidthRatio] + 94;
}

+ (NSInteger)downloadChapterNumsWhenReadBooks{
    return 10;
}

+ (NSString *)shelfDataTitle{
    return @"书架入口";
}
@end
