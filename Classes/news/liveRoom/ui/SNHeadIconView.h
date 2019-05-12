//
//  SNLiveHeadIconView.h
//  sohunews
//
//  Created by chenhong on 13-4-23.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"

#define kDftImageKeyFemale  @"female_default_icon.png"
#define kDftImageKeyMale    @"login_user_defaultIcon.png"
#define kHeadIconKeyPid     @"kHeadIconKeyPid"

// 头像View需要特殊处理
@interface SNHeadIconImageView : SNWebImageView
@end

@interface SNHeadIconView : UIView {
    SNHeadIconImageView *_icon;
    NSString *_passport;
    int _gender;
    id _target;
    SEL _selector;
    
    NSCache *_dftImageMedCache;
}

@property (nonatomic, strong) SNHeadIconImageView *icon;
@property (nonatomic, assign) int gender;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, strong) NSString *userPid;

- (void)reload;
- (void)setIconUrl:(NSString *)url passport:(NSString *)passport
            gender:(int)gender;
- (void)setTarget:(id)target tapSelector:(SEL)selector;
- (void)setDefaultImage:(UIImage *)image;
- (void)updateTheme;
//chengweibin add for usercenter add friend
- (void)resetDefaultImage:(UIImage *)image;
@end

@interface SNLiveHeadIconView : SNHeadIconView
@end
