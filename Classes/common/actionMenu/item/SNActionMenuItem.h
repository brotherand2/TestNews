//
//  SNActionMenuItem.h
//  sohunews
//
//  Created by Dan Cong on 2/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNActionMenuContent.h"

@interface SNActionMenuItem : NSObject
{
    NSString    *_title;
    UIImage     *_image;
    id           _target;
    SEL          _action;
    UIControl   *_containView;
    UIImageView *_imageView;
    UILabel     *_titleLabel;
}

@property (nonatomic) BOOL disable;
@property (nonatomic) NSInteger index;
@property (nonatomic) SNActionMenuOption type;
@property (nonatomic) SEL action;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) UIControl *containView;
@property (nonatomic, readonly) CGFloat sizeValue;

- (id)initWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type;

+ (id)itemWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type;

- (id)initWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type
            disable:(BOOL)disable;

+ (id)itemWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type
            disable:(BOOL)disable;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;


//lijian 2014.12.16 扩展方法，item没有按下效果，添加方法实现
- (void)addHightlightImage:(UIImage *)image;

@end
