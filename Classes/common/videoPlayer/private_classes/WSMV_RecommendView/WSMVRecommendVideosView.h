//
//  WSRecommendVideosView.h
//  WeSee
//
//  Created by handy wang on 9/11/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SNVideoData;

@protocol WSRecommendVideosViewDelegate
- (void)didHideRecommendVideosView;
- (NSString *)playingVID;
- (void)switchToPlayRecommendVideo:(SNVideoData *)video inRecommendVideos:(NSArray *)recommendVideos;
- (NSArray *)recommendVideos:(BOOL)more;
@end

@interface WSMVRecommendVideosView : UIControl<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak)id delegate;
@property (nonatomic, strong)NSMutableArray *recommendVideos;

- (id)initWithDelegate:(id)delegate;
- (void)appendRecommendVideos:(NSArray *)recommendVideos;
- (void)replaceAllRecommendVieos:(NSArray *)videos;
- (void)clearRecommendVideos;
- (void)reloadData;
- (void)dismissIfNeeded;
- (void)refreshEmptyNoticeIfNeed;
@end

//////////////////////////////////////TableViewCell////////////////////////////////////////////
@interface WSRecommendVideoCell : UITableViewCell
@property (nonatomic, strong)SNVideoData   *data;

- (void)setData:(SNVideoData *)data playingVID:(NSString *)playingVID;
- (void)setSelected;
- (void)setUnselected;
@end
