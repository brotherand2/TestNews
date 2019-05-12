//
//  SNNewsSectionTitleView.m
//  sohunews
//
//  Created by lhp on 11/13/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNNewsSectionTitleView.h"
#import "NSCellLayout.h"

@interface SNNewsSectionTitleView ()

@end

@implementation SNNewsSectionTitleView

- (id)initWithFrame:(CGRect)frame title:(NSString *) title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -2, frame.size.width, NEWS_SECTION_HEIGHT)];
        backgroundView.image = [UIImage themeImageNamed:@"timeline_section_bg.png"];
        [self addSubview:backgroundView];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 100, 15)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:10.0];
        titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)updateTheme {
    backgroundView.image = [UIImage themeImageNamed:@"timeline_section_bg.png"];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
     //(backgroundView);
}

@end
