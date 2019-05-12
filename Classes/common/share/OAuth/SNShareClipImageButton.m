//
//  SNShareClipImageButton.m
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNShareClipImageButton.h"

@implementation SNShareClipImageButton
@synthesize enable = _enable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _sourceImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width - 8, frame.size.height - 8)];
        [_sourceImageView setDefaultImage:[UIImage imageNamed:@"news_default_image.png"]];
        _sourceImageView.contentMode = UIViewContentModeScaleAspectFill;
        _sourceImageView.clipsToBounds = YES;

        [self addSubview:_sourceImageView];
        
        _clipImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_image_outline.png"]];
        [self insertSubview:_clipImage belowSubview:_sourceImageView];
        _clipImage.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        _maskView = [[UIView alloc] initWithFrame:_sourceImageView.frame];
        _maskView.backgroundColor = [UIColor blackColor];
        [self addSubview:_maskView];
        _maskView.alpha = 0;
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews {
    
}

- (void)setImageUrl:(NSString *)imageUrl {
    if (![[TTURLCache sharedCache] imageForURL:imageUrl fromDisk:YES]) {
        // 本地没有缓存这张图片 暂时停用查看大图的功能
        self.enable = NO;
    }
    [_sourceImageView loadUrlPath:imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        if (image) {
            self.enable = YES;
        }
    }];
}

- (void)setImagePath:(NSString *)imagePath {
    if ([imagePath length] > 0) {
        self.enable = YES;
        _sourceImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
}

- (void)addTarget:(id)target selector:(SEL)selecor {
    _target = target;
    _fuction = selecor;
}

- (void)setEnable:(BOOL)enable {
    self.userInteractionEnabled = _enable = enable;
}

- (void)addTarget:(id)target selecor:(SEL)sel {
    _target = target;
    _fuction = sel;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _maskView.alpha = 0.3;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _maskView.alpha = 0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _maskView.alpha = 0;
    UITouch *tch = [touches anyObject];
    CGPoint pt = [tch locationInView:self];
    if (CGRectContainsPoint(self.bounds, pt)) {
        [self fireFunction];
    }
}

#pragma mark - private methods
- (void)fireFunction {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMethodSignature *signature = [[_target class] instanceMethodSignatureForSelector:_fuction];
    if ([_target respondsToSelector:_fuction]) {
        if ([signature numberOfArguments] == 2) {
            [_target performSelector:_fuction];
        }
        else if ([signature numberOfArguments] == 3) {
            [_target performSelector:_fuction withObject:self];
        }
    }
#pragma clang diagnostic pop
}

@end
