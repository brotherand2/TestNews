//
//  SNNewsShareDrawBoardSlider.m
//  testSlider
//
//  Created by wang shun on 2017/7/14.
//  Copyright © 2017年 wang shun. All rights reserved.
//

#import "SNNewsShareDrawBoardSlider.h"
#import "UIColor+ColorChange.h"

@interface SNNewsShareDrawBoardSlider ()
{

}
@property (nonatomic,strong) UIView* clickView;
@property (nonatomic,strong) UIView* sliderView;

@end

@implementation SNNewsShareDrawBoardSlider

- (instancetype)initWithFrame:(CGRect)frame WithBgColor:(UIColor*)bgColor{
    if (self = [super initWithFrame:frame]) {
        self.bgColor = bgColor;
        [self setup];
    }
    return self;
}

- (void)setup{
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-8)/2.0, self.frame.size.width,8)];
    [view setBackgroundColor:self.bgColor];
    [self addSubview:view];
    self.sliderView = view;
    
    view.layer.cornerRadius  = 4;
    view.layer.masksToBounds = YES;
    
    CGFloat w = self.frame.size.width/12.0;
    
    for (int i = 0; i< 12; i++) {
        UIView* v1 = [[UIView alloc] initWithFrame:CGRectMake(w*i, 0, w, 8)];
        v1.backgroundColor = [self getColor:i];
        [view addSubview:v1];
    }
    
    self.clickView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height/2.0)-6, 12, 12)];
    self.clickView.layer.masksToBounds = YES;
    self.clickView.layer.cornerRadius  = 6;
    self.clickView.backgroundColor     = [UIColor redColor];
    [self addSubview:self.clickView];
    self.clickView.layer.borderColor = self.bgColor.CGColor;
    self.clickView.layer.borderWidth = 1;
    
}

- (UIColor*)getColor:(NSInteger)n{

    NSArray* arr = @[@"#ee2f10",@"#ffbb48",@"#ffeb00",@"#c2ff2f",@"#03b10a",@"#25d2ff",@"#287bfe",@"#0037c8",@"#945afc",@"#ff99ff",@"#fd6991",@"#f925bc"];
    if (n<arr.count) {
        NSString* color_str = [arr objectAtIndex:n];
        UIColor* color = [UIColor colorWithHexString:color_str];
        return color;
    }
    else{
        int i = n%4;
        NSString* color_str = [arr objectAtIndex:i];
        UIColor* color = [UIColor colorWithHexString:color_str];
        return color;
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBroardStartTouch:)]) {
        [self.delegate drawBroardStartTouch:nil];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    [self clickViewPosition:point];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    [self clickViewPosition:point];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBroardEndTouch:)]) {
        [self.delegate drawBroardEndTouch:nil];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    [self clickViewPosition:point];
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBroardEndTouch:)]) {
        [self.delegate drawBroardEndTouch:nil];
    }
    
}

- (void)clickViewPosition:(CGPoint)point{
    CGFloat w = self.clickView.frame.size.width/2.0;
    if (point.x<w) {
        self.clickView.center = CGPointMake(w, self.clickView.center.y);
        UIColor* color = [self getColor:0];
        self.clickView.backgroundColor = color;
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedColor:WithPoint:WithNumber:)]) {
            [self.delegate selectedColor:color WithPoint:self.clickView.center WithNumber:0];
        }
    }
    else if (point.x>(self.frame.size.width-w)){
        self.clickView.center = CGPointMake(self.frame.size.width-w, self.clickView.center.y);
        UIColor* color = [self getColor:11];
        self.clickView.backgroundColor = color;
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedColor:WithPoint:WithNumber:)]) {
            [self.delegate selectedColor:color WithPoint:self.clickView.center WithNumber:11];
        }
    }
    else{
        self.clickView.center = CGPointMake(point.x, self.clickView.center.y);
        
        double width = self.frame.size.width/12.0;
        int f = (double)self.clickView.center.x / width;
        UIColor* color = [self getColor:f];
        if (color) {
            self.clickView.backgroundColor = color;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectedColor:WithPoint:WithNumber:)]) {
                [self.delegate selectedColor:color WithPoint:point WithNumber:f];
            }
        }
    }
    

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
