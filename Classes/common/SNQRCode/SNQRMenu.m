//
//  SNQRMenu.m
//  HZQRCodeDemo
//
//  Created by H on 15/11/4.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import "SNQRMenu.h"

@implementation SNQRMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self buildMenu];
        
    }
    
    return self;
}

- (BOOL)is6Plus{
    if ([UIScreen mainScreen].bounds.size.width > 750/2.f) {
        return YES;
    }else{
        return NO;
    }
}

- (CGFloat)buttonWidth {
    if ([self is6Plus]) {
        return 144/3.f;
    }
    return 96/2.f;
}

- (CGFloat)buttonLeftSpace {
    CGFloat space = 0.0;
    if ([self is6Plus]) {
        space = 360/3.f;
    }else{
        space = 208/2.f;
    }
    CGFloat buttonWidth = [self buttonWidth];
    return (self.width - buttonWidth * 2 - space)/2.f;
    
}

- (void)buildMenu {
    
    SNQRItem *otherItem = [SNQRItem buttonWithType:UIButtonTypeCustom];
    otherItem.frame = CGRectMake(0, 0, [self buttonWidth], [self buttonWidth]);
    [otherItem setImage:[UIImage themeImageNamed:@"icoscan_photo_v5.png"] forState:UIControlStateNormal];
    otherItem.type = QRItemType_Album;
    [self addSubview:otherItem];

    
    SNQRItem *qrItem = [SNQRItem buttonWithType:UIButtonTypeCustom];
    qrItem.frame = CGRectMake(0, 0, [self buttonWidth], [self buttonWidth]);
    [qrItem setImage:[UIImage themeImageNamed:@"icoscan_light_v5.png"] forState:UIControlStateNormal];
    [qrItem setImage:[UIImage themeImageNamed:@"icoscan_flashselected_v5.png"] forState:UIControlStateSelected];
    qrItem.left = otherItem.right + 60;
    qrItem.type = QRItemType_Lamp;
    self.lightBtn = qrItem;
    [self addSubview:qrItem];
    
    
    [qrItem addTarget:self action:@selector(qrScan:) forControlEvents:UIControlEventTouchUpInside];
    [otherItem addTarget:self action:@selector(qrScan:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Action

- (void)qrScan:(SNQRItem *)qrItem {
    
    if (self.didSelectedBlock) {
        
        self.didSelectedBlock(qrItem);
    }
}

@end
