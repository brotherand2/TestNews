//
//  SNLiveHeadIconView.m
//  sohunews
//
//  Created by chenhong on 13-4-23.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNHeadIconView.h"
#import "SNUserManager.h"

@implementation SNHeadIconImageView
@end

@implementation SNHeadIconView
@synthesize icon =_icon;
@synthesize gender = _gender;
@synthesize cachePath = _cachePath;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //前景
        _icon = [[SNHeadIconImageView alloc] initWithFrame:self.bounds];
        _icon.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_icon];

        //内存中保存默认图
        _dftImageMedCache = [[NSCache alloc] init];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGes];
        
        // 统一加个圆角 by jojo
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2;
    }
    return self;
}

- (void)updateTheme {
    [_dftImageMedCache removeAllObjects];
    _icon.defaultImage = [self getDftImageFromMem];
    [self reload];
}

- (void)reload {
    _icon.urlPath = nil;
    _icon.urlPath = self.cachePath;
}

- (void)setIconUrl:(NSString *)url
          passport:(NSString *)passport
            gender:(int)gender {
    if (_passport != passport) {
        _passport = passport;
    }

    _gender = gender;
    _icon.defaultImage = [self getDftImageFromMem];
    
    if (![url isEqualToString:self.cachePath]) {
        _icon.urlPath = nil;
    }
    
    _icon.urlPath = url;
    self.cachePath = url;
}

- (void)setTarget:(id)target tapSelector:(SEL)selector {
    _target = target;
    _selector = selector;
}

- (void)setDefaultImage:(UIImage *)image {
    _icon.defaultImage = image;
}

- (UIImage *)getDftImageFromMem {
    UIImage *image = [UIImage themeImageNamed:@"ico_avatar_v5.png"];
    return image;
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    if (_target && _selector) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (self.userPid.length > 0) {
            [dic setObject:self.userPid forKey:kHeadIconKeyPid];
        }
        if ([_target respondsToSelector:_selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_target performSelector:_selector withObject:dic];
#pragma clang diagnostic pop
        }
    }
}

- (void)resetDefaultImage:(UIImage *)image {
    _icon.defaultImage = image;
    _icon.urlPath = nil;
    self.cachePath = nil;
}

@end

#pragma mark - 
@implementation SNLiveHeadIconView

- (void)setIconUrl:(NSString *)url
          passport:(NSString *)passport
            gender:(int)gender {
    if (_passport != passport) {
        _passport = passport;
    }
    
    _gender = gender;
    
    if (![url isEqualToString:self.cachePath]) {
        _icon.urlPath = nil;
    }
    
    _icon.urlPath = url;
    self.cachePath = url;
}

- (void)updateTheme {
    [self reload];
}

@end
