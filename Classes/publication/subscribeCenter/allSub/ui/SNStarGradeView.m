//
//  SNStarGradeView.m
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNStarGradeView.h"

@implementation SNStarGradeView
@synthesize style = _style;
@synthesize canEdit = _canEdit;
@synthesize grade = _grade;

- (id)init {
    self = [self initWithStyle:SNStarGradeViewStyleSmall canEdit:NO];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithStyle:SNStarGradeViewStyleSmall canEdit:NO];
    if (self) {
    }
    return self;
}

- (id)initWithStyle:(SNStarGradeViewStyle)style canEdit:(BOOL)canEdit {
    CGRect frame = CGRectZero;
    CGFloat space = 0;
    UIImage *starImage = nil;
    
    if (style == SNStarGradeViewStyleSmall) {
        frame = CGRectMake(0, 0, kGradeViewWidthSmall, kGradeViewHeightSmall);
        space = kGradeViewSpaceSmall;
        starImage = [UIImage themeImageNamed:@"subcenter_empty_star_small.png"];
    }
    else if (style == SNStarGradeViewStyleBig) {
        frame = CGRectMake(0, 0, kGradeViewWidthBig, kGradeViewHeightBig);
        space = kGradeViewSpaceBig;
        starImage = [UIImage themeImageNamed:@"subcenter_empty_star_big.png"];
    }
    else if (style == SNStarGradeViewStyleLarge) {
        frame = CGRectMake(0, 0, kGradeViewWidthLarge, kGradeViewHeightLarge);
        space = kGradeViewSpaceLarge;
        starImage = [UIImage themeImageNamed:@"subcenter_empty_star_large.png"];
    }
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _style = style;
        _canEdit = canEdit;
        self.userInteractionEnabled = _canEdit;
        self.isAccessibilityElement = !_canEdit;
        
        _startsButtonsArray = [[NSMutableArray alloc] initWithCapacity:5];
        // add stars
        //CGRect starFrame = CGRectMake(0, 0, self.width, self.height);
        CGRect starFrame = CGRectMake(0, 0, starImage.size.width, starImage.size.height);
        
        for (int i = 0; i < 5; ++i) {
            UIButton *startBtn = [[UIButton alloc] initWithFrame:starFrame];
            [startBtn setImage:starImage forState:UIControlStateNormal];
            [startBtn setImage:starImage forState:UIControlStateHighlighted];
            [startBtn setImage:starImage forState:UIControlStateDisabled];
            startBtn.accessibilityLabel = [NSString stringWithFormat:@"评价星级：第%d星", i+1];
            startBtn.tag = i;
            [startBtn addTarget:self action:@selector(btnSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:startBtn];
            [_startsButtonsArray addObject:startBtn];
            
            starFrame.origin.x += starFrame.size.width + space;
        }
    }
    
    return self;
}

- (void)dealloc {
     //(_startsButtonsArray);
}

- (void)setFrame:(CGRect)frame {
    CGRect reFrame = CGRectMake(frame.origin.x, frame.origin.y, self.width, self.height);
    [super setFrame:reFrame];
}

- (void)setEditable:(BOOL)canEdit {
    _canEdit = canEdit;
    self.isAccessibilityElement = !_canEdit;
//    for (UIButton *btn in _startsButtonsArray) {
//        btn.enabled = _canEdit;
//    }
    self.userInteractionEnabled = _canEdit;
}

- (void)setGrade:(CGFloat)grade {
    _grade = grade;
    
    if (_grade > 5.0) {
        _grade = 5.0;
    }
    if (_grade < 0) {
        _grade = 0;
    }
    self.isAccessibilityElement = !_canEdit;
    if (!_canEdit) {
        self.accessibilityLabel = [NSString stringWithFormat:@"评价等级：%g颗星", _grade];
    }
    
    [self resetAllBtns];
}

- (void)resetAllBtns {
    UIImage *starImage = nil;
    UIImage *emptyStar = nil;
    
    if (_style == SNStarGradeViewStyleSmall) {
        starImage = [UIImage themeImageNamed:@"subcenter_star_small.png"];
        emptyStar = [UIImage themeImageNamed:@"subcenter_empty_star_small.png"];
    }
    else if (_style == SNStarGradeViewStyleBig) {
        starImage = [UIImage themeImageNamed:@"subcenter_star_big.png"];
        emptyStar = [UIImage themeImageNamed:@"subcenter_empty_star_big.png"];
    }
    else if (_style == SNStarGradeViewStyleLarge) {
        starImage = [UIImage themeImageNamed:@"subcenter_star_large.png"];
        emptyStar = [UIImage themeImageNamed:@"subcenter_empty_star_large.png"];
    }
    
    // clean old grade
    for (UIButton *btn in _startsButtonsArray) {
        [btn setImage:emptyStar forState:UIControlStateNormal];
        [btn setImage:emptyStar forState:UIControlStateHighlighted];
        [btn setImage:emptyStar forState:UIControlStateDisabled];
    }
    
    int redNum = (int)_grade;
    int index = 0;
    
    while (index < redNum) {
        UIButton *btn = [_startsButtonsArray objectAtIndex:index];
        [btn setImage:starImage forState:UIControlStateNormal];
        [btn setImage:starImage forState:UIControlStateHighlighted];
        [btn setImage:emptyStar forState:UIControlStateDisabled];
        index++;
    }
    
    if (index == 5) {
        index--;
    }
    
    UIButton *partBtn = [_startsButtonsArray objectAtIndex:index];
    
    if (_maskStarButton) {
        [_maskStarButton removeFromSuperview];
        _maskStarButton = nil;
    }
    
    CGFloat persent = _grade - redNum;
    if(persent > 0) {
        if (!_maskStarButton) {
            _maskStarButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, partBtn.width * persent, partBtn.height)];
            _maskStarButton.clipsToBounds = YES;
            _maskStarButton.contentMode = UIViewContentModeTopLeft;
            _maskStarButton.image = starImage;
            
            [partBtn addSubview:_maskStarButton];
        }
    }
}

- (void)btnSelected:(UIButton *)btn {
    if (_canEdit) {
        NSInteger tag = btn.tag + 1;
        [self setGrade:tag];
    }
}

@end
