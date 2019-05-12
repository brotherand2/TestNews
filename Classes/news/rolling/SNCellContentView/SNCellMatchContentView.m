//
//  SNCellMatchContentView.m
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNCellMatchContentView.h"
#import "NSCellLayout.h"
#import "UIFont+Theme.h"

@interface SNCellMatchContentView ()

@end

#define kTeamImageViewTop       10
#define kTeamImageViewLeft      (54/2)
#define kTeamImageViewWidth     ([[SNDevice sharedInstance] isPlus]?40:30)
#define kTeamImageCoverWidth    34

#define kLeftTeamNameRect      (CGRectMake(0,61,100,13))
#define kMatchNameRect         (CGRectMake(100,61,100,10))

@implementation SNCellMatchContentView

@synthesize hostTeamName;
@synthesize visitorTeamName;
@synthesize matchName;
@synthesize liveStatus;
@synthesize hostTotal;
@synthesize visitorTotal;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = themeImageAlphaValue();
        [self initTeamImageView];
    }
    return self;
}

- (void)initTeamImageView
{
    CGRect hostRect = CGRectMake(0, 0, kTeamImageViewWidth, kTeamImageViewWidth);
    hostTeamIcon = [[SNImageView alloc] initWithFrame:hostRect];
    hostTeamIcon.backgroundColor = [UIColor whiteColor];
    hostTeamIcon.centerY = self.height/2;
    hostTeamIcon.right = self.width/2 - 120/2;
    [hostTeamIcon setImageCoverWithImage:[UIImage imageNamed:@"icohome_livebg_v5.png"]];
    [self addSubview:hostTeamIcon];
    
    CGRect visitorRect = CGRectMake(0, 0, kTeamImageViewWidth, kTeamImageViewWidth);
    visitorTeamIcon = [[SNImageView alloc] initWithFrame:visitorRect];
    visitorTeamIcon.backgroundColor = [UIColor whiteColor];
    visitorTeamIcon.centerY = self.height/2;
    visitorTeamIcon.left = self.width/2 + 120/2;
    [visitorTeamIcon setImageCoverWithImage:[UIImage imageNamed:@"icohome_livebg_v5.png"]];
    [self addSubview:visitorTeamIcon];
}

- (void)updateWithHostTeamUrl:(NSString *) leftUrl visitorTeamUrl:(NSString *) rightUrl
{
    [hostTeamIcon loadImageWithUrl:leftUrl defaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder1]];
    [visitorTeamIcon loadImageWithUrl:rightUrl defaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder1]];
    [self updateTheme];
}

- (BOOL)beginLive
{
    BOOL begin = NO;
    if (self.liveStatus && ![self.liveStatus isEqualToString:@""]) {
        int liveNum = [self.liveStatus intValue];
        switch (liveNum) {
            case 1:
                begin = NO;
                break;
            case 2:
            case 3:
                begin = YES;
                break;
            default:
                begin = NO;
                break;
        }
    }
    return begin;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *textColor = [UIColor whiteColor];
    
    int left = self.width/2 - 10;
    int top_y = 20;
    int vsToTotal_x = 6;
    UIDevicePlatform plat = [[SNDevice sharedInstance] devicePlat];
    switch (plat) {
        case UIDevice6PlusiPhone:
        case UIDevice7PlusiPhone:
        case UIDevice8PlusiPhone:
            top_y = 28;
            break;
        case UIDevice6iPhone:
        case UIDevice7iPhone:
        case UIDevice8iPhone:
            top_y = 24;
            break;
        default:
            break;
    }
    
    float vsFontSize = [UIFont fontSizeWithType:UIFontSizeTypeC];
    CGRect vsRect = CGRectMake(left, top_y+5, 24, vsFontSize+1);
    [@"VS" textDrawInRect:vsRect
                 withFont:[UIFont systemFontOfSizeType:UIFontSizeTypeC]
            lineBreakMode:NSLineBreakByTruncatingTail
                alignment:NSTextAlignmentCenter
                textColor:textColor];
    
    UIFont *totalFont = [UIFont systemFontOfSizeType:UIFontSizeTypeF];
    float titleFontSize = [UIFont fontSizeWithType:UIFontSizeTypeF];
    if (self.hostTotal.length > 0) {
        CGSize hostTotalSize = [self.hostTotal sizeWithFont:totalFont];
        int hostLeft = left - vsToTotal_x - hostTotalSize.width;
        CGRect hostTotalRect = CGRectMake(hostLeft, top_y, hostTotalSize.width, titleFontSize+1);
        [self.hostTotal textDrawInRect:hostTotalRect
                              withFont:totalFont
                         lineBreakMode:NSLineBreakByTruncatingTail
                             alignment:NSTextAlignmentRight
                             textColor:textColor];
        
        hostTeamIcon.right = hostLeft - vsToTotal_x + 4.0;
    }
    
    if (self.visitorTotal.length > 0) {
        CGSize visitorTotalSize = [self.visitorTotal sizeWithFont:totalFont];
        CGRect hostTotalRect = CGRectMake(left+24+vsToTotal_x, top_y, visitorTotalSize.width, titleFontSize+1);
        [self.visitorTotal textDrawInRect:hostTotalRect
                                 withFont:totalFont
                            lineBreakMode:NSLineBreakByTruncatingTail
                                alignment:NSTextAlignmentLeft
                                textColor:textColor];
        
        visitorTeamIcon.left = left + visitorTotalSize.width + vsToTotal_x + 25.0;

    }
    
    UIFont *teamNameFont = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    float teamFontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
    if ([SNDevice sharedInstance].isPhone6) {
        teamNameFont = [UIFont systemFontOfSizeType:UIFontSizeTypeC];
        teamFontSize = [UIFont fontSizeWithType:UIFontSizeTypeC];
    }
    
    if (self.hostTeamName.length > 0) {
        int teamNameWidth = hostTeamIcon.left - vsToTotal_x;
        CGRect leftTeamRect = CGRectMake(5, top_y+5, teamNameWidth-5, teamFontSize+2);
        [self.hostTeamName textDrawInRect:leftTeamRect
                                 withFont:teamNameFont
                            lineBreakMode:NSLineBreakByTruncatingTail
                                alignment:NSTextAlignmentRight
                                textColor:textColor];
    }
    
    if (self.visitorTeamName.length > 0) {
        CGSize visitorNameSize = [self.visitorTeamName sizeWithFont:teamNameFont];
        int left = visitorTeamIcon.right + vsToTotal_x;
        if (kAppScreenWidth == 320.0) {
            left -= 2.0;
        }
        CGFloat teamNameWidth = self.width - left - 2;
        teamNameWidth = left + visitorNameSize.width > self.width ? teamNameWidth : visitorNameSize.width;
        
        CGRect kRightTeamNameRect = CGRectMake(left,top_y+5,teamNameWidth,teamFontSize+2);
        [self.visitorTeamName textDrawInRect:kRightTeamNameRect
                                    withFont:teamNameFont
                               lineBreakMode:NSLineBreakByTruncatingTail
                                   alignment:NSTextAlignmentLeft
                                   textColor:textColor];
    }
}

- (void)updateTheme
{
    self.alpha = themeImageAlphaValue();
    [hostTeamIcon updateDefaultImage:[UIImage themeImageNamed:@"defaultImage_icon.png"]];
    [visitorTeamIcon updateDefaultImage:[UIImage themeImageNamed:@"defaultImage_icon.png"]];
    [self setNeedsDisplay];
}

- (void)dealloc
{
}

@end
