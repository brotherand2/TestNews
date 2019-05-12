//
//  SNLiveFocusCell.m
//  sohunews
//
//  Created by yanchen wang on 12-6-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveFocusCell.h"
#import "UIColor+ColorUtils.h"
#import "CacheObjects.h"



@implementation SNLiveFocusCell
@synthesize liveItem = _liveItem;

- (void)dealloc {
     //(_liveItem);
     //(_liveStatusIcon);
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    self.liveItem = object;
    UIImage *defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
    NSString *imageUrl = [self headlinePicUrl];
    BOOL showVideo = [self headlineHasVideo];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger nonePictureMode = [[userDefaults objectForKey:kNonePictureModeKey] intValue];
    if (nonePictureMode == kPicModeWiFi && [SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        [self.headlineView updateImageWithUrl:nil defaultImage:defaultImage showVideo:showVideo];
    }
    else {
        [self.headlineView updateImageWithUrl:imageUrl defaultImage:defaultImage showVideo:showVideo];
    }
    _titleLabel.font = [SNUtility getNewsTitleFont];
    _titleLabel.text = [self headlineTitle];
    [self initLiveStatusIcon];
}

#pragma mark ---------- methods to override for subclass

- (NSString *)headlinePicUrl {
    if (_liveItem.focusGameItems.count > 0) {
        LivingGameItem *gameItem = [self.liveItem.focusGameItems objectAtIndex:0];
        return gameItem.livePic;
    }
    return nil;
}

- (NSString *)headlineTitle {
    if (_liveItem.focusGameItems.count > 0) {
        LivingGameItem *gameItem = [self.liveItem.focusGameItems objectAtIndex:0];
        return gameItem.title;
    }
    return nil;
}

- (BOOL)headlineHasVideo {
    return NO;
}

- (void)initLiveStatusIcon {
    if (!_liveStatusIcon) {
        _liveStatusIcon = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"live_tagb.png"]];
        [self.headlineView addSubview:_liveStatusIcon];
    }
    
    [self setStatusIcon];
    
    _liveStatusIcon.bottom = _titleLabel.top - 4;
    _liveStatusIcon.left = _titleLabel.left;
}

- (void)setStatusIcon {
    if (_liveItem.focusGameItems.count > 0) {
        LivingGameItem *gameItem = [self.liveItem.focusGameItems objectAtIndex:0];
        // 比赛状态 1-预告 2-直播中 3-直播结束
        if ([gameItem.status intValue] == 1) {
            _liveStatusIcon.image = [UIImage themeImageNamed:@"live_tagc.png"];
        } else if ([gameItem.status intValue] == 2) {
            _liveStatusIcon.image = [UIImage themeImageNamed:@"live_tagb.png"];
        } else if ([gameItem.status intValue] == 3) {
            _liveStatusIcon.image = [UIImage themeImageNamed:@"live_tagd.png"];
        } else {
            _liveStatusIcon.image = nil;
        }
    }
}

- (void)updateTheme {
    [super updateTheme];
    [self setStatusIcon];
    
    [self.headlineView updateTheme];
    [self.headlineView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder5]];

}

- (void)openNews:(UITapGestureRecognizer *)tap
{
    [[NSUserDefaults standardUserDefaults] setDouble:100.0 forKey:kRememberCellOriginYInScreen];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SNUtility shouldUseSpreadAnimation:YES];
    LivingGameItem *gameItem = [self.liveItem.focusGameItems objectAtIndex:0];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:gameItem forKey:kLiveGameItem];
    [userInfo setObject:kChannelEditionNews forKey:kNewsFrom];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://live"] applyAnimated:YES] applyQuery:userInfo];
    [[TTNavigator navigator] openURLAction:urlAction];
}

@end
