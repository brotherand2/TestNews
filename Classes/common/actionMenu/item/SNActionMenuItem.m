//
//  SNActionMenuItem.m
//  sohunews
//
//  Created by Dan Cong on 2/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNActionMenuItem.h"

@implementation SNActionMenuItem


+ (id)itemWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type
{
    return [[SNActionMenuItem alloc] initWithTitle:title image:image type:type];
}

- (id)initWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type
{
    return [self initWithTitle:title image:image type:type disable:NO];
}


+ (id)itemWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type
            disable:(BOOL)disable
{
    return [[SNActionMenuItem alloc] initWithTitle:title image:image type:type disable:disable];
}

- (id)initWithTitle:(NSString *)title
              image:(UIImage *)image
               type:(SNActionMenuOption)type
            disable:(BOOL)disable
{
    if (self = [super init]) {
        
        _type = type;
        _disable = disable;
        _title = [NSString stringWithFormat:@"%@", title];
        _image = [UIImage imageWithCGImage:image.CGImage];
        
        _containView = [[UIControl alloc] initWithFrame:CGRectZero];
        _containView.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] initWithImage:image];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color];;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        _titleLabel.text = title;
        
        [_containView addSubview:_imageView];
        [_containView addSubview:_titleLabel];
        
        [_containView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)addHightlightImage:(UIImage *)image
{
    if(nil == _imageView){
        return;
    }
    
    _imageView.highlightedImage = image;
}

- (NSInteger)index
{
    return _containView.tag;
}

- (void)setIndex:(NSInteger)index
{
    _containView.tag = index;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    if (!_disable) {
        [_containView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        //lijian 2014.12.16 增加按下效果
        [_containView addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [_containView addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
        [_containView addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpOutside];
    }
}

//lijian 2014.12.16 增加按下效果
//-----------------------------
- (void)touchDown
{
    _imageView.highlighted = YES;
}
- (void)touchUp
{
    _imageView.highlighted = NO;
}
//-----------------------------

- (void)layoutSubviews {
    _imageView.frame = CGRectMake(0, 0, _containView.width, _containView.width);
    _titleLabel.frame = CGRectMake(0, _imageView.bottom, _imageView.width, _containView.height - _containView.width);
}

- (void)dealloc
{
    _title = nil;
    _image = nil;
    _target = nil;
    
    [_containView removeObserver:self forKeyPath:@"frame"];
    _containView = nil;
    
    
    _imageView = nil;
    _titleLabel = nil;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self layoutSubviews];
}

@end
