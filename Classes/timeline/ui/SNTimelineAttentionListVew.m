//
//  SNTimelineAttentionListVew.m
//  sohunews
//
//  Created by jialei on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTimelineAttentionListVew.h"
#import "SNHeadIconView.h"
#import "SNTimelineConfigs.h"
#import "SNTimelineTrendObjects.h"
#import "SNUserHelper.h"

#define kTLMaxAttentionListNum  10
#define kTLAttentionHeadIconBaseTag     100
#define kDftImageKeyFemale  @"female_default_icon.png"
#define kDftImageKeyMale    @"login_user_defaultIcon.png"

@interface SNTimelineAttentionListVew()
{
    UIImage *_femaleImage;
    UIImage *_maleImage;
}

@end

@implementation SNTimelineAttentionListVew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.width = TTApplicationFrame().size.width;
        
        int index = 0;
        int xOffsetIndex = 0;
        CGFloat height = 0;
//        height += kTLOriginalContentFromTopMargin;
        _femaleImage = [UIImage themeImageNamed:kDftImageKeyFemale];
        _maleImage = [UIImage themeImageNamed:kDftImageKeyMale];
        
        //目前只支持显示两行五列，提高效率写死位置
        while (index < kTLMaxAttentionListNum) {
            if (index > 0 && (index % kTLOriginalPeopleViewLineNum) == 0) {
                height += kTLOriginalContentFromTopMargin + kTLOriginalPeopleViewHeadIconSize;
                xOffsetIndex = 0;
            }
            
            CGFloat x = kTLOriginalContentTextSideMargin + xOffsetIndex * (kTLOriginalPeopleViewHeadIconSize + kTLOriginalContentTextSideMargin);
            CGRect userIconFrame = CGRectMake(x,
                                              kTLOriginalContentFromTopMargin + height,
                                              kTLOriginalPeopleViewHeadIconSize,
                                              kTLOriginalPeopleViewHeadIconSize);
    
            SNHeadIconView *userHeadImageView = [[SNHeadIconView alloc]initWithFrame:userIconFrame];
            userHeadImageView.tag = kTLAttentionHeadIconBaseTag + index;
            
            [self addSubview:userHeadImageView];
            
            [userHeadImageView release];
            
            index++;
            xOffsetIndex++;
        }
    }
    return self;
}

- (void)dealloc
{
    TT_RELEASE_SAFELY(_attListData);
    [super dealloc];
}

- (void)setAttListData:(NSArray *)array
{
    [_attListData release];
    _attListData = [array retain];
    int index;
    int count = array.count;
    for(index = 0; index < kTLMaxAttentionListNum; index++) {
        SNHeadIconView *imageView = (SNHeadIconView *)[self viewWithTag:index + kTLAttentionHeadIconBaseTag];
        if (index < count) {
            SNTimelineTrendTopObject *top = [array objectAtIndex:index];
            [imageView setIconUrl:top.headUrl passport:nil gender:top.gender];
            [imageView setTarget:self tapSelector:@selector(enterUserCenter:)];
            imageView.userPid = top.pid;
            BOOL bNightMode = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight];
            imageView.alpha = bNightMode ? 0.7 : 1;
            imageView.hidden = NO;
        }
        else {
            imageView.hidden = YES;
        }
    }
}

#pragma mark - action
- (void)enterUserCenter:(NSMutableDictionary *)dic
{
    NSString *pid = [dic objectForKey:kHeadIconKeyPid];
    if (pid.length > 0) {
            [SNUserHelper openUserWithPassport:nil
                                     spaceLink:nil
                                     linkStyle:nil
                                           pid:pid];
    }
}

@end
