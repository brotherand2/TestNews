//
//  SNQRItem.m
//  HZQRCodeDemo
//
//  Created by H on 15/11/5.
//  Copyright © 2015年 Hz. All rights reserved.
//

#import "SNQRItem.h"

@interface SNQRItem ()

@property (nonatomic, copy) NSString * imgname;

@end

@implementation SNQRItem

- (instancetype)initWithFrame:(CGRect)frame
                       titile:(NSString *)titile{
    
    self =  [SNQRItem buttonWithType:UIButtonTypeCustom];
    if (self) {
        
        [self setTitle:titile forState:UIControlStateNormal];
        self.frame = frame;
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)imageName{
    self =  [SNQRItem buttonWithType:UIButtonTypeSystem];
    if (self) {
        self.imgname = imageName;
        [self setBackgroundImage:[UIImage themeImageNamed:imageName] forState:UIControlStateNormal];
//        [self setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[self processSelectedImageName:imageName]]] forState:UIControlStateSelected];
        self.frame = frame;
    }

    return self;
}

- (NSString *)processSelectedImageName:(NSString *)imageName {
    NSString * __imgName = nil;
    if ([imageName containsString:@"_v5"]) {
        __imgName = [[imageName componentsSeparatedByString:@"_v5"] firstObject];
        __imgName = [NSString stringWithFormat:@"%@selected_v5.png",__imgName];
    }
    return __imgName;
}

- (void)setDidSelected:(BOOL)didSelected {
    if (_didSelected == didSelected) {
        return;
    }
    _didSelected = didSelected;
    if (didSelected) {
        [self setBackgroundImage:[UIImage themeImageNamed:[NSString stringWithFormat:@"%@",[self processSelectedImageName:self.imgname]]] forState:UIControlStateNormal];
    }else{
        [self setBackgroundImage:[UIImage themeImageNamed:self.imgname] forState:UIControlStateNormal];
    }
}

@end
