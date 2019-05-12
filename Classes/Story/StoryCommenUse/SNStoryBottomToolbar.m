//
//  SNStoryBottomToolbar.m
//  FacebookThree20
//
//  Created by chuanwenwang on 16/10/11.
//  Copyright © 2016年 chuanwenwang. All rights reserved.
//

#import "SNStoryBottomToolbar.h"
#import "UIImage+Story.h"
#import "UIColor+StoryColor.h"

#define EdgeInsetsMake                (UIEdgeInsetsMake(2, 1, 2, 1))
#define StoryBottomToolbarAlpha       0.95
#define TopEdgeShadowLeftOffset       0.0
#define StoryBottomToolbarLineGap     1.0

@interface SNStoryBottomToolbar() {
    NSMutableArray *buttons;
    UIImageView *_backgroundView;
    UIImageView *_topEdgeShadow;
    StoryToolbarAlignType _alignType;
}
@end

@implementation SNStoryBottomToolbar
@synthesize leftButton, rightButton;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		
		//校正动画时底部露出1px空隙.
		CGRect f = self.frame;
		f.origin.y += StoryBottomToolbarLineGap;
		self.frame = f;
        self.backgroundColor = [UIColor colorFromKey:@"kThemeBg4Color"];
        self.alpha = StoryBottomToolbarAlpha;
        _alignType = StoryToolbarAlignCenter;
        
        //Top edge shadow
        UIEdgeInsets edgeInsets = EdgeInsetsMake;
        UIImage *shadowImg = [[UIImage imageStoryNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        _topEdgeShadow = [[UIImageView alloc] initWithFrame:CGRectMake(TopEdgeShadowLeftOffset, -shadowImg.size.height, self.frame.size.width, shadowImg.size.height/2)];
        _topEdgeShadow.image = shadowImg;
        [self addSubview:_topEdgeShadow];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme:)
                                                     //name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateTheme {
    self.backgroundColor = [UIColor colorFromKey:@"kThemeBg4Color"];
}

@end
