//
//  SNFeedBackTextModel.m
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackTextModel.h"

@implementation SNFeedBackTextModel

+ (CGFloat)calRowHeightWithModel:(SNFeedBackTextModel *)model {
//    if (model.row == 0) {
//        return 276;
//    }
//    
    CGFloat height = 0;
    
    if (!model.isHideDate) {
        
        height += kFBDateTopMargin + 11.0f + kFBNameTopMargin;
    }
    height += kFBDateTopMargin + 11.0f + 4.0f + kFBBubblrBottomMargin * 4;
    CGFloat maxWidth = kAppScreenWidth - kFBIconLeftMargin * 2 - kFBIconWidth - kFBNameLeftMargin - kFBTextLeftMargin * 2;
    CGSize titleSize = [self sizeWithText:model.fbText font:[UIFont systemFontOfSize:kThemeFontSizeD] maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
    height += titleSize.height;
    return height;
}

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize {
    
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.fbText forKey:@"text"];
    [aCoder encodeInteger:self.fbType forKey:@"type"];
 
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.fbText = [aDecoder decodeObjectForKey:@"text"];
        self.fbType = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}



@end
