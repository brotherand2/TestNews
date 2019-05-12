//
//  SNVideosTableBaseCell.h
//  sohunews
//
//  Created by chenhong on 13-9-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideosTableViewController.h"
#import "SNVideoObjects.h"

@interface SNVideosTableBaseCell : UITableViewCell {
    UIImageView *_cellSelectedBg;
    NSString *_currentTheme;
}
@property (nonatomic, weak)id delegate;
@property (nonatomic, strong)SNVideoData *object;
@property (nonatomic, weak)SNVideosTableViewController *videosTableViewController;

+ (CGFloat)height;
- (void)playVideoIfNeeded;
- (void)playVideoIfNeededIn2G3G;
- (void)stopVideoPlayIfPlaying;

- (BOOL)needsUpdateTheme;
- (void)updateTheme;
@end
