//
//  SNLiveSoundView.h
//  sohunews
//
//  Created by chenhong on 13-4-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSoundManager.h"

@class SNLiveContentObject;
@class SNWaitingActivityView;

@interface SNLiveSoundView : UIView {
    
    UIImageView *_speaker;
    UILabel *_statusLabel;
    UILabel *_durationLabel;
    SNWaitingActivityView *_indicator;
    UIImageView *_errorView;
    SNSoundStatusType _soundStatus;
    NSString *url;
    NSString *_commentID;
}

@property(nonatomic,strong)NSString *url;
@property(nonatomic,assign)int duration;
@property(nonatomic,copy)NSString *commentID;
@property(nonatomic,copy)NSString *liveId;

- (void)updateTheme;
- (void)setBackgroundWithImage:(UIImage *) backgroundImage;
- (void)stopSoundPlay;

- (void)setStatus:(SNSoundStatusType)status;
- (void)clickBtn;
- (void)onSoundDownloaded:(NSNotification*)notification;
- (void)onSoundPlayFinished:(NSNotification*)notification;

- (void)loadIfNeeded;

@end
