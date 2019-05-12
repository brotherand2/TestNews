//
//  SNTagView.m
//  sohunews
//
//  Created by qi pei on 7/21/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTagView.h"
#import "SNTagButton.h"
#import "UIColor+ColorUtils.h"
#import "SNAppConfigManager.h"

#define TAG_BUTTON_MARGIN               (9)
#define TAG_BUTTON_ROW_MARGIN           (7)
#define TAG_BUTTON_LEFT_RIGHT_PADING    (10)
#define TAG_BUTTON_HEIGHT               (50/2)
#define TAG_LINE_MARGIN                 (10)

#define TAG_FONT_SIZE                   (12.5)

#define LEFT_RIGHT_MARGIN               (10)
#define TOP_MARGIN                      (26)
#define BOTTOM_MARGIN                   (20)

@implementation SNTagView

@synthesize tags, tagDelegate, tagMargin=_tagMargin, tagBtnHeight=_tagBtnHeight, tagFontSize=_tagFontSize;

- (id)init {
    self = [super init];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.scrollsToTop = NO;
        _topMargin = TOP_MARGIN;
        _tagBtnHeight = TAG_BUTTON_HEIGHT;
        _tagFontSize = TAG_FONT_SIZE;
    }
    return self;
}

- (void)fillTags:(NSMutableArray *)allTag {
    self.tags = allTag;
    [self addTagsToView];
}

- (void)updateTheme {    
    [self customTagBtnsStyle];
}

- (void)customTagBtnsStyle {
    UIImage *bgImage = [UIImage imageNamed:@"tag_bg.png"];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    } else {
        bgImage = [bgImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    }

    UIColor *normalColor =  [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagNormalTextColor]];
    UIColor *selectedColor =  [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagSelectedTextColor]];
    for (SNTagButton *tBtn in _allBtns) {
        [tBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
        [tBtn setBackgroundImage:bgImage forState:UIControlStateHighlighted];
        [tBtn setTitleColor:normalColor forState:UIControlStateNormal];
        [tBtn setTitleColor:selectedColor forState:UIControlStateHighlighted];
        [tBtn setTitleColor:selectedColor forState:UIControlStateSelected];
    }
}

- (SNTagButton *)createTagButton:(SNTagItem *)tagItem {
    return [SNTagButton buttonWithType:UIButtonTypeCustom];
}

- (void)addTagsToView {
    [self removeAllSubviews];
    
    if (_allBtns) {
         //(_allBtns);
    }
    _allBtns = [NSMutableArray array];
    
    SNTagButton *lastTagBtn   = nil;
    //tag最大长度
    //int maxTagWidth = (CGRectGetWidth(self.frame) - LEFT_RIGHT_MARGIN*2 - TAG_BUTTON_MARGIN);
    int totalWidth  = CGRectGetWidth(self.frame) - LEFT_RIGHT_MARGIN*2;
    int line = 1;
    if (tags) {
        for (int i = 0; i < [tags count]; i++) {
            SNTagItem *tag = [tags objectAtIndex:i];
            SNTagButton *tBtn = [self createTagButton:tag];
            [_allBtns addObject:tBtn];
            tBtn.tagItem = tag;
            tBtn.exclusiveTouch = YES;
            [tBtn.titleLabel setFont:[UIFont systemFontOfSize:_tagFontSize]];
            [tBtn setTitle:tag.tagName forState:UIControlStateNormal];
            [tBtn.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            tBtn.titleEdgeInsets = UIEdgeInsetsMake(5.5,10,5.5,10);
            [self addSubview:tBtn];  
            [tBtn addTarget:self action:@selector(tagBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            CGSize tagSize = CGSizeMake(tBtn.tagWidth, _tagBtnHeight);
            if (tagSize.width > totalWidth) {
                tagSize = CGSizeMake(totalWidth, _tagBtnHeight);
            }
            if (!lastTagBtn) {
                tBtn.frame = CGRectMake(LEFT_RIGHT_MARGIN, _topMargin, tagSize.width, _tagBtnHeight);
            } else {
                CGFloat restLength = totalWidth - lastTagBtn.origin.x - CGRectGetWidth(lastTagBtn.frame) - TAG_BUTTON_MARGIN;
                if (restLength >= tagSize.width) { //剩余长度能够容纳下当前tag
                    tBtn.frame = CGRectMake(lastTagBtn.origin.x + CGRectGetWidth(lastTagBtn.frame) + TAG_BUTTON_MARGIN, 
                                            lastTagBtn.origin.y, 
                                            tagSize.width, 
                                            _tagBtnHeight);
                } else {//剩余长度不能够容纳下当前tag，将当前tag放入下一行
                    tBtn.frame = CGRectMake(LEFT_RIGHT_MARGIN, 
                                            lastTagBtn.origin.y + CGRectGetHeight(lastTagBtn.frame) + TAG_BUTTON_ROW_MARGIN, 
                                            tagSize.width, 
                                            _tagBtnHeight);
                    line ++;
                }
            }
            lastTagBtn = tBtn;
            
            if (line >= 8 && [[SNAppConfigManager sharedInstance] searchSogouButtonShow]) {
                break;
            }
        }
        
        [self customTagBtnsStyle];
    }
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(lastTagBtn.frame) + BOTTOM_MARGIN);
    CGFloat height=CGRectGetMaxY(lastTagBtn.frame)+BOTTOM_MARGIN;
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (void)tagBtnClicked:(id)sender {
    SNTagButton *tBtn = (SNTagButton *)sender;
    if (tagDelegate && [tagDelegate respondsToSelector:@selector(selectedTag:)]) {
        [tagDelegate selectedTag:tBtn.tagItem];
    }
}

- (void)dealloc {
    if (_allBtns) {
         //(_allBtns);
    }
     //(tags);
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([tagDelegate respondsToSelector:@selector(didTouchBeganInTagView)]) {
        [tagDelegate didTouchBeganInTagView];
    }
}

@end
