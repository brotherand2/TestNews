//
//  SNShareClipImageButton.h
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"

@interface SNShareClipImageButton : UIView{
    UIImageView *_clipImage;
    SNWebImageView *_sourceImageView;
    UIView *_maskView;
    
    id _target;
    SEL _fuction;
    BOOL _enable;
}

@property(nonatomic, assign) BOOL enable;

- (void)setImageUrl:(NSString *)imageUrl;
- (void)setImagePath:(NSString *)imagePath;
- (void)addTarget:(id)target selector:(SEL)selecor;

@end
