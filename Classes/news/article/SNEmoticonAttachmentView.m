//
//  SNEmoticonTextView.m
//  sohunews
//
//  Created by jialei on 14-5-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNEmoticonAttachmentView.h"
#import "SNEmoticonObject.h"

@implementation SNEmoticonAttachmentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithEmoticonObject:(SNEmoticonObject *)emoticon
{
    if (self = [super init]) {
        self.emoticon = emoticon;
    }
    
    return self;
}

-(CGRect)cellRect{
    return _cellRect;
}

- (UIView *)attachmentView{
    return self;
}

- (CGSize) attachmentSize{
    if (!CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        return self.frame.size;
    }
    else {
        return self.emoticon.emoticonImage.size;
    }
}

- (void)attachmentDrawInRect: (CGRect)cellFrame{
    _cellRect = cellFrame;
    if (!self.emoticon.emoticonImage)
        return;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawImage(ctx, cellFrame, self.emoticon.emoticonImage.CGImage);
}

- (CGPoint)cellBaselineOffset
{
    return CGPointMake(0, -2.0);
}

@end
