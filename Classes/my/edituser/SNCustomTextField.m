//
//  SNCustomTextField.m
//  sohunews
//
//  Created by yangln on 14-10-2.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCustomTextField.h"
#import "UIColor+ColorUtils.h"

@implementation SNCustomTextField

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
    }
    return self;
}

-(void)setPlaceholder:(NSString *)placeholder_{
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:placeholder_];
    [placeholder addAttribute:NSForegroundColorAttributeName
                        value:SNUICOLOR(kThemeText4Color)
                        range:NSMakeRange(0, placeholder_.length)];
    self.attributedPlaceholder = placeholder;
}

////reWrite function
//- (void)drawPlaceholderInRect:(CGRect)rect {
//    [SNUICOLOR(kThemeText4Color) setFill];
//    [self.placeholder drawInRect:rect withFont:self.font];
//}

@end
